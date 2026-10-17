<?php

namespace App\Http\Controllers\Patient;

use App\Http\Controllers\Controller;
use App\Models\FinanceClient;
use App\Services\FinanceService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InvoiceController extends Controller
{
    public function __construct(private FinanceService $finance) {}

    /**
     * GET /patient/invoices
     * The patient's accounts with each therapist: balance, invoices, payments.
     */
    public function index(Request $request): JsonResponse
    {
        $clients = FinanceClient::with(['therapist', 'invoices.client', 'payments.client'])
            ->where('patient_id', $request->user()->patient->id)
            ->get();

        $accounts = $clients->map(function (FinanceClient $c) {
            $paid = (float) $c->payments->sum('amount');
            $invoiced = (float) $c->invoices->sum(fn ($i) => $i->total);

            return [
                'therapist_id'   => $c->therapist_id,
                'therapist_name' => $c->therapist?->full_name,
                'therapist_avatar' => $c->therapist?->avatar,
                'invoices' => $this->finance->allocate($c->invoices, $paid)
                    ->map(fn ($r) => FinanceService::formatInvoice($r['invoice'], $r['paid'], $r['due'], $r['status']))
                    ->sortByDesc('issued_at')->values(),
                'payments' => $c->payments->sortByDesc('paid_at')
                    ->map(fn ($p) => FinanceService::formatPayment($p))->values(),
            ] + FinanceService::balance($invoiced, $paid);
        })
            ->filter(fn ($a) => count($a['invoices']) > 0 || count($a['payments']) > 0)
            ->sortByDesc('due')
            ->values();

        // Credit with one therapist does not offset what is owed to another.
        return response()->json([
            'summary'  => [
                'invoiced' => round((float) $accounts->sum('invoiced'), 2),
                'paid'     => round((float) $accounts->sum('paid'), 2),
                'due'      => round((float) $accounts->sum('due'), 2),
            ],
            'accounts' => $accounts,
        ]);
    }
}
