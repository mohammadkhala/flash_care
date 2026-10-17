<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use App\Models\Appointment;
use App\Models\Conversation;
use App\Models\Expense;
use App\Models\FinanceClient;
use App\Models\Invoice;
use App\Models\Patient;
use App\Models\Payment;
use App\Services\FcmService;
use App\Services\FinanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;

class FinanceController extends Controller
{
    public function __construct(
        private FinanceService $finance,
        private FcmService $fcmService,
    ) {}

    private function therapistId(Request $request): int
    {
        return $request->user()->therapist->id;
    }

    /** Period from ?from=&to= (Y-m-d); defaults to the current month. */
    private function period(Request $request): array
    {
        $request->validate([
            'from' => 'nullable|date',
            'to'   => 'nullable|date|after_or_equal:from',
        ]);
        $from = $request->filled('from') ? Carbon::parse($request->from)->startOfDay() : now()->startOfMonth();
        $to   = $request->filled('to') ? Carbon::parse($request->to)->endOfDay() : now()->endOfMonth();
        return [$from, $to];
    }

    private function ownClient(Request $request, FinanceClient $client): void
    {
        abort_if($client->therapist_id !== $this->therapistId($request), 403);
    }

    // ── Summary ───────────────────────────────────────────────

    public function summary(Request $request): JsonResponse
    {
        $tid = $this->therapistId($request);
        [$from, $to] = $this->period($request);

        $totals = $this->finance->totalsByClient($tid);
        $due = $totals->sum(fn ($t) => max(0, $t['invoiced'] - $t['paid']));

        $invoiced = (float) Invoice::where('therapist_id', $tid)
            ->whereBetween('issued_at', [$from, $to])->sum(DB::raw('amount - discount'));
        $paid = (float) Payment::where('therapist_id', $tid)
            ->whereBetween('paid_at', [$from, $to])->sum('amount');
        $expenses = (float) Expense::where('therapist_id', $tid)
            ->whereBetween('spent_at', [$from, $to])->sum('amount');

        $byCategory = Expense::where('therapist_id', $tid)
            ->whereBetween('spent_at', [$from, $to])
            ->groupBy('category')
            ->selectRaw('category, SUM(amount) AS sum_total')
            ->pluck('sum_total', 'category')
            ->map(fn ($v) => round((float) $v, 2));

        return response()->json([
            'from'                 => $from->toDateString(),
            'to'                   => $to->toDateString(),
            'total_due'            => round($due, 2),
            'invoiced'             => round($invoiced, 2),
            'paid'                 => round($paid, 2),
            'expenses'             => round($expenses, 2),
            'net'                  => round($paid - $expenses, 2),
            'clients_count'        => FinanceClient::where('therapist_id', $tid)->count(),
            // Always a JSON object (an empty collection would serialize as []).
            'expenses_by_category' => (object) $byCategory->all(),
        ]);
    }

    // ── Clients (patients' financial accounts) ───────────────

    public function clients(Request $request): JsonResponse
    {
        $request->validate([
            'search' => 'nullable|string|max:100',
            'status' => 'nullable|in:paid,partial,unpaid',
        ]);
        $tid = $this->therapistId($request);

        $clients = FinanceClient::where('therapist_id', $tid)
            ->when($request->filled('search'), function ($q) use ($request) {
                $s = trim($request->search);
                $code = (int) preg_replace('/\D+/', '', $s);
                $q->where(function ($w) use ($s, $code) {
                    $w->where('name', 'like', "%{$s}%")->orWhere('phone', 'like', "%{$s}%");
                    if ($code > 0) $w->orWhere('code', $code);
                });
            })
            ->orderBy('name')
            ->get();

        $totals = $this->finance->totalsByClient($tid, $clients->pluck('id')->all());

        $rows = $clients->map(fn (FinanceClient $c) => $this->formatClient($c, $totals[$c->id] ?? null))
            ->when($request->filled('status'), fn ($rows) => $rows->where('status', $request->status))
            ->sortByDesc('due')
            ->values();

        return response()->json($rows);
    }

    private function formatClient(FinanceClient $c, ?array $t): array
    {
        return [
            'id'         => $c->id,
            'code'       => $c->code_label,
            'name'       => $c->name,
            'phone'      => $c->phone,
            'notes'      => $c->notes,
            'patient_id' => $c->patient_id,
            'is_walk_in' => $c->patient_id === null,
        ] + FinanceService::balance($t['invoiced'] ?? 0, $t['paid'] ?? 0);
    }

    /** Patients of this therapist (appointments or chats) for the client picker. */
    public function myPatients(Request $request): JsonResponse
    {
        $tid = $this->therapistId($request);

        $ids = Appointment::where('therapist_id', $tid)->pluck('patient_id')
            ->merge(Conversation::where('therapist_id', $tid)->whereNotNull('patient_id')->pluck('patient_id'))
            ->unique()->values();

        $clientByPatient = FinanceClient::where('therapist_id', $tid)->whereNotNull('patient_id')
            ->pluck('id', 'patient_id');

        $patients = Patient::whereIn('id', $ids)->orderBy('full_name')->get(['id', 'full_name', 'avatar'])
            ->map(fn ($p) => [
                'id'        => $p->id,
                'full_name' => $p->full_name,
                'avatar'    => $p->avatar,
                'client_id' => $clientByPatient[$p->id] ?? null,
            ]);

        return response()->json($patients);
    }

    /** Body: { patient_id } for an app patient, or { name, phone?, notes? } for a walk-in. */
    public function storeClient(Request $request): JsonResponse
    {
        $request->validate([
            'patient_id' => 'nullable|exists:patients,id',
            'name'       => 'required_without:patient_id|nullable|string|max:255',
            'phone'      => 'nullable|string|max:30',
            'notes'      => 'nullable|string|max:1000',
        ]);
        $tid = $this->therapistId($request);

        if ($request->filled('patient_id')) {
            $client = $this->finance->clientForPatient($tid, Patient::with('user')->findOrFail($request->patient_id));
        } else {
            $client = DB::transaction(fn () => FinanceClient::create([
                'therapist_id' => $tid,
                'code'         => $this->finance->nextClientCode($tid),
                'name'         => $request->name,
                'phone'        => $request->phone,
                'notes'        => $request->notes,
            ]));
        }

        $t = $this->finance->totalsByClient($tid, [$client->id]);
        return response()->json($this->formatClient($client, $t[$client->id] ?? null), 201);
    }

    public function updateClient(Request $request, FinanceClient $client): JsonResponse
    {
        $this->ownClient($request, $client);
        $request->validate([
            'name'  => 'sometimes|required|string|max:255',
            'phone' => 'nullable|string|max:30',
            'notes' => 'nullable|string|max:1000',
        ]);

        // App patients keep their registered name.
        $fields = $client->patient_id ? ['phone', 'notes'] : ['name', 'phone', 'notes'];
        $client->update($request->only($fields));

        $t = $this->finance->totalsByClient($client->therapist_id, [$client->id]);
        return response()->json($this->formatClient($client, $t[$client->id] ?? null));
    }

    public function destroyClient(Request $request, FinanceClient $client): JsonResponse
    {
        $this->ownClient($request, $client);
        abort_if(
            $client->invoices()->exists() || $client->payments()->exists(),
            422,
            'لا يمكن حذف حساب له فواتير أو دفعات. احذفها أولاً.'
        );
        $client->delete();
        return response()->json(['ok' => true]);
    }

    /** Full account: balance, invoices (with paid/due), payments. */
    public function showClient(Request $request, FinanceClient $client): JsonResponse
    {
        $this->ownClient($request, $client);
        $tid = $client->therapist_id;

        $invoices = $client->invoices()->with('client')->get();
        $payments = $client->payments()->with('client')->orderByDesc('paid_at')->orderByDesc('id')->get();
        $paid = (float) $payments->sum('amount');
        $invoiced = (float) $invoices->sum(fn ($i) => $i->total);

        $allocated = $this->finance->allocate($invoices, $paid)
            ->map(fn ($r) => FinanceService::formatInvoice($r['invoice'], $r['paid'], $r['due'], $r['status']))
            ->sortByDesc('issued_at')->values();

        return response()->json([
            'client'   => $this->formatClient($client, ['invoiced' => $invoiced, 'paid' => $paid]),
            'invoices' => $allocated,
            'payments' => $payments->map(fn ($p) => FinanceService::formatPayment($p))->values(),
        ]);
    }

    // ── Invoices ──────────────────────────────────────────────

    public function invoices(Request $request): JsonResponse
    {
        $request->validate([
            'search' => 'nullable|string|max:100',
            'status' => 'nullable|in:paid,partial,unpaid',
        ]);
        $tid = $this->therapistId($request);
        [$from, $to] = $this->period($request);

        $invoices = Invoice::with('client')->where('therapist_id', $tid)
            ->whereBetween('issued_at', [$from, $to])
            ->when($request->filled('search'), function ($q) use ($request) {
                $s = trim($request->search);
                $num = (int) preg_replace('/\D+/', '', $s);
                $q->where(function ($w) use ($s, $num) {
                    $w->whereHas('client', fn ($c) => $c->where('name', 'like', "%{$s}%"))
                      ->orWhere('description', 'like', "%{$s}%");
                    if ($num > 0) $w->orWhere('number', $num);
                });
            })
            ->orderByDesc('issued_at')->orderByDesc('id')
            ->get();

        $rows = $this->finance->invoicesWithStatus($tid, $invoices)
            ->when($request->filled('status'), fn ($rows) => $rows->where('status', $request->status))
            ->values();

        return response()->json($rows);
    }

    private function invoiceRules(Request $request, bool $creating): array
    {
        return [
            'client_id'      => [$creating ? 'required' : 'sometimes', Rule::exists('finance_clients', 'id')
                ->where('therapist_id', $this->therapistId($request))->whereNull('deleted_at')],
            'appointment_id' => ['nullable', Rule::exists('appointments', 'id')
                ->where('therapist_id', $this->therapistId($request))],
            'issued_at'      => [$creating ? 'required' : 'sometimes', 'date'],
            'amount'         => [$creating ? 'required' : 'sometimes', 'numeric', 'min:0', 'max:9999999'],
            'discount'       => ['nullable', 'numeric', 'min:0', 'lte:amount'],
            'description'    => ['nullable', 'string', 'max:255'],
            'notes'          => ['nullable', 'string', 'max:1000'],
        ];
    }

    public function storeInvoice(Request $request): JsonResponse
    {
        $request->validate($this->invoiceRules($request, true));
        $tid = $this->therapistId($request);

        $invoice = DB::transaction(fn () => Invoice::create([
            'therapist_id'   => $tid,
            'client_id'      => $request->client_id,
            'appointment_id' => $request->appointment_id,
            'number'         => $this->finance->nextInvoiceNumber($tid),
            'issued_at'      => $request->issued_at,
            'amount'         => $request->amount,
            'discount'       => $request->input('discount', 0) ?? 0,
            'description'    => $request->description,
            'notes'          => $request->notes,
        ]));

        $this->notifyPatient($invoice->client, 'فاتورة جديدة',
            "أصدر {$request->user()->therapist->full_name} فاتورة {$invoice->number_label} بقيمة {$invoice->total} ₪",
            'new_invoice');

        return response()->json($this->finance->invoicesWithStatus($tid, collect([$invoice]))->first(), 201);
    }

    public function updateInvoice(Request $request, Invoice $invoice): JsonResponse
    {
        abort_if($invoice->therapist_id !== $this->therapistId($request), 403);
        $rules = $this->invoiceRules($request, false);
        $rules['discount'] = ['nullable', 'numeric', 'min:0',
            'max:' . (float) $request->input('amount', $invoice->amount)];
        $request->validate($rules);

        $invoice->update($request->only([
            'client_id', 'appointment_id', 'issued_at', 'amount', 'discount', 'description', 'notes',
        ]));

        return response()->json($this->finance->invoicesWithStatus($invoice->therapist_id, collect([$invoice->fresh()]))->first());
    }

    public function destroyInvoice(Request $request, Invoice $invoice): JsonResponse
    {
        abort_if($invoice->therapist_id !== $this->therapistId($request), 403);
        $invoice->delete();
        return response()->json(['ok' => true]);
    }

    // ── Payments ──────────────────────────────────────────────

    public function payments(Request $request): JsonResponse
    {
        $request->validate(['search' => 'nullable|string|max:100']);
        $tid = $this->therapistId($request);
        [$from, $to] = $this->period($request);

        $payments = Payment::with('client')->where('therapist_id', $tid)
            ->whereBetween('paid_at', [$from, $to])
            ->when($request->filled('search'), fn ($q) => $q->whereHas('client',
                fn ($c) => $c->where('name', 'like', '%' . trim($request->search) . '%')))
            ->orderByDesc('paid_at')->orderByDesc('id')
            ->get();

        return response()->json($payments->map(fn ($p) => FinanceService::formatPayment($p))->values());
    }

    private function paymentRules(Request $request, bool $creating): array
    {
        $req = $creating ? 'required' : 'sometimes';
        return [
            'client_id' => [$req, Rule::exists('finance_clients', 'id')
                ->where('therapist_id', $this->therapistId($request))->whereNull('deleted_at')],
            'amount'    => [$req, 'numeric', 'gt:0', 'max:9999999'],
            'method'    => ['nullable', Rule::in(Payment::METHODS)],
            'paid_at'   => [$req, 'date'],
            'notes'     => ['nullable', 'string', 'max:1000'],
        ];
    }

    public function storePayment(Request $request): JsonResponse
    {
        $request->validate($this->paymentRules($request, true));

        $payment = Payment::create([
            'therapist_id' => $this->therapistId($request),
            'client_id'    => $request->client_id,
            'amount'       => $request->amount,
            'method'       => $request->input('method') ?? 'cash',
            'paid_at'      => $request->paid_at,
            'notes'        => $request->notes,
        ]);

        $this->notifyPatient($payment->client, 'تم تسجيل دفعة',
            "سجّل {$request->user()->therapist->full_name} دفعة بقيمة {$payment->amount} ₪",
            'new_payment');

        return response()->json(FinanceService::formatPayment($payment->load('client')), 201);
    }

    public function updatePayment(Request $request, Payment $payment): JsonResponse
    {
        abort_if($payment->therapist_id !== $this->therapistId($request), 403);
        $request->validate($this->paymentRules($request, false));
        $payment->update($request->only(['client_id', 'amount', 'method', 'paid_at', 'notes']));
        return response()->json(FinanceService::formatPayment($payment->fresh('client')));
    }

    public function destroyPayment(Request $request, Payment $payment): JsonResponse
    {
        abort_if($payment->therapist_id !== $this->therapistId($request), 403);
        $payment->delete();
        return response()->json(['ok' => true]);
    }

    // ── Expenses ──────────────────────────────────────────────

    public function expenses(Request $request): JsonResponse
    {
        $request->validate(['category' => ['nullable', Rule::in(Expense::CATEGORIES)]]);
        [$from, $to] = $this->period($request);

        $expenses = Expense::where('therapist_id', $this->therapistId($request))
            ->whereBetween('spent_at', [$from, $to])
            ->when($request->filled('category'), fn ($q) => $q->where('category', $request->category))
            ->orderByDesc('spent_at')->orderByDesc('id')
            ->get();

        return response()->json($expenses->map(fn ($e) => $this->formatExpense($e))->values());
    }

    private function formatExpense(Expense $e): array
    {
        return [
            'id'          => $e->id,
            'category'    => $e->category,
            'amount'      => (float) $e->amount,
            'spent_at'    => $e->spent_at?->toDateString(),
            'description' => $e->description,
            'receipt_url' => $e->receipt_path ? Storage::disk('public')->url($e->receipt_path) : null,
        ];
    }

    private function expenseRules(bool $creating): array
    {
        $req = $creating ? 'required' : 'sometimes';
        return [
            'category'       => [$req, Rule::in(Expense::CATEGORIES)],
            'amount'         => [$req, 'numeric', 'gt:0', 'max:9999999'],
            'spent_at'       => [$req, 'date'],
            'description'    => ['nullable', 'string', 'max:255'],
            'receipt'        => ['nullable', 'image', 'max:5120'],
            'remove_receipt' => ['nullable', 'boolean'],
        ];
    }

    public function storeExpense(Request $request): JsonResponse
    {
        $request->validate($this->expenseRules(true));
        $tid = $this->therapistId($request);

        $expense = Expense::create([
            'therapist_id' => $tid,
            'category'     => $request->category,
            'amount'       => $request->amount,
            'spent_at'     => $request->spent_at,
            'description'  => $request->description,
            'receipt_path' => $request->file('receipt')?->store("expense_receipts/{$tid}", 'public'),
        ]);

        return response()->json($this->formatExpense($expense), 201);
    }

    public function updateExpense(Request $request, Expense $expense): JsonResponse
    {
        abort_if($expense->therapist_id !== $this->therapistId($request), 403);
        $request->validate($this->expenseRules(false));

        $data = $request->only(['category', 'amount', 'spent_at', 'description']);
        if ($request->hasFile('receipt') || $request->boolean('remove_receipt')) {
            if ($expense->receipt_path) Storage::disk('public')->delete($expense->receipt_path);
            $data['receipt_path'] = $request->file('receipt')
                ?->store("expense_receipts/{$expense->therapist_id}", 'public');
        }
        $expense->update($data);

        return response()->json($this->formatExpense($expense));
    }

    public function destroyExpense(Request $request, Expense $expense): JsonResponse
    {
        abort_if($expense->therapist_id !== $this->therapistId($request), 403);
        $expense->delete();
        return response()->json(['ok' => true]);
    }

    // ── Helpers ───────────────────────────────────────────────

    private function notifyPatient(?FinanceClient $client, string $title, string $body, string $type): void
    {
        $user = $client?->patient_id ? $client->patient?->user : null;
        if (!$user) return;
        try {
            $this->fcmService->send($user, $title, $body, ['type' => $type], $type);
        } catch (\Throwable) {}
    }
}
