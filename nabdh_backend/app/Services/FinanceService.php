<?php

namespace App\Services;

use App\Models\Appointment;
use App\Models\FinanceClient;
use App\Models\Invoice;
use App\Models\Patient;
use App\Models\Payment;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

/**
 * Balances are never stored: a client's due = Σ invoice totals − Σ payments.
 * Per-invoice paid/status allocates the client's payments to invoices oldest first.
 */
class FinanceService
{
    public function clientForPatient(int $therapistId, Patient $patient): FinanceClient
    {
        return DB::transaction(function () use ($therapistId, $patient) {
            $existing = FinanceClient::where('therapist_id', $therapistId)
                ->where('patient_id', $patient->id)
                ->lockForUpdate()
                ->first();
            if ($existing) return $existing;

            return FinanceClient::create([
                'therapist_id' => $therapistId,
                'patient_id'   => $patient->id,
                'code'         => $this->nextClientCode($therapistId),
                'name'         => $patient->full_name,
                'phone'        => $patient->user?->phone
                    ? $patient->user->phone_country_code . $patient->user->phone
                    : null,
            ]);
        });
    }

    public function nextClientCode(int $therapistId): int
    {
        return (int) FinanceClient::withTrashed()->where('therapist_id', $therapistId)
            ->lockForUpdate()->max('code') + 1;
    }

    public function nextInvoiceNumber(int $therapistId): int
    {
        return (int) Invoice::withTrashed()->where('therapist_id', $therapistId)
            ->lockForUpdate()->max('number') + 1;
    }

    /** Session price for an appointment from the therapist's current prices. */
    public function priceFor(Appointment $appointment): ?float
    {
        $t = $appointment->therapist;
        if (!$t) return null;
        $price = $appointment->type === 'online' ? $t->online_session_price : $t->in_person_session_price;
        return $price !== null ? (float) $price : null;
    }

    /**
     * Invoiced / paid totals per client id (all time).
     * @return Collection<int, array{invoiced: float, paid: float}>
     */
    public function totalsByClient(int $therapistId, ?array $clientIds = null): Collection
    {
        $inv = Invoice::where('therapist_id', $therapistId)
            ->when($clientIds !== null, fn ($q) => $q->whereIn('client_id', $clientIds))
            ->groupBy('client_id')
            ->selectRaw('client_id, SUM(amount - discount) AS sum_total')
            ->pluck('sum_total', 'client_id');

        $pay = Payment::where('therapist_id', $therapistId)
            ->when($clientIds !== null, fn ($q) => $q->whereIn('client_id', $clientIds))
            ->groupBy('client_id')
            ->selectRaw('client_id, SUM(amount) AS sum_total')
            ->pluck('sum_total', 'client_id');

        return $inv->keys()->merge($pay->keys())->unique()->mapWithKeys(fn ($id) => [
            (int) $id => [
                'invoiced' => round((float) ($inv[$id] ?? 0), 2),
                'paid'     => round((float) ($pay[$id] ?? 0), 2),
            ],
        ]);
    }

    public static function status(float $invoiced, float $paid): string
    {
        if ($invoiced <= 0 && $paid <= 0) return 'none';
        if ($paid + 0.005 >= $invoiced) return 'paid';
        return $paid > 0 ? 'partial' : 'unpaid';
    }

    /** Balance block shared by list rows and account screens. */
    public static function balance(float $invoiced, float $paid): array
    {
        return [
            'invoiced' => round($invoiced, 2),
            'paid'     => round($paid, 2),
            'due'      => round(max(0, $invoiced - $paid), 2),
            'credit'   => round(max(0, $paid - $invoiced), 2),
            'status'   => self::status($invoiced, $paid),
        ];
    }

    /**
     * Invoices of one client with paid/due/status per invoice (FIFO allocation).
     * @param Collection<int, Invoice> $invoices all invoices of the client
     */
    public function allocate(Collection $invoices, float $totalPaid): Collection
    {
        $left = $totalPaid;
        return $invoices->sortBy([['issued_at', 'asc'], ['id', 'asc']])->values()
            ->map(function (Invoice $inv) use (&$left) {
                $total = $inv->total;
                $paid  = round(min($total, max(0, $left)), 2);
                $left -= $paid;
                return ['invoice' => $inv, 'paid' => $paid, 'due' => round($total - $paid, 2),
                        'status' => $total <= 0 ? 'paid' : self::status($total, $paid)];
            });
    }

    public static function formatInvoice(Invoice $inv, float $paid, float $due, string $status): array
    {
        return [
            'id'             => $inv->id,
            'number'         => $inv->number,
            'number_label'   => $inv->number_label,
            'client_id'      => $inv->client_id,
            'client_name'    => $inv->client?->name,
            'client_code'    => $inv->client?->code_label,
            'appointment_id' => $inv->appointment_id,
            'issued_at'      => $inv->issued_at?->toDateString(),
            'amount'         => (float) $inv->amount,
            'discount'       => (float) $inv->discount,
            'total'          => $inv->total,
            'paid'           => $paid,
            'due'            => $due,
            'status'         => $status,
            'description'    => $inv->description,
            'notes'          => $inv->notes,
        ];
    }

    public static function formatPayment(Payment $p): array
    {
        return [
            'id'          => $p->id,
            'client_id'   => $p->client_id,
            'client_name' => $p->client?->name,
            'client_code' => $p->client?->code_label,
            'amount'      => (float) $p->amount,
            'method'      => $p->method,
            'paid_at'     => $p->paid_at?->toDateString(),
            'notes'       => $p->notes,
        ];
    }

    /** Invoices of the given clients, formatted with FIFO paid/due/status. */
    public function invoicesWithStatus(int $therapistId, Collection $invoices): Collection
    {
        if ($invoices->isEmpty()) return collect();

        $clientIds = $invoices->pluck('client_id')->unique()->values()->all();
        $all = Invoice::with('client')->where('therapist_id', $therapistId)
            ->whereIn('client_id', $clientIds)->get()->groupBy('client_id');
        $paid = $this->totalsByClient($therapistId, $clientIds);

        $byId = collect();
        foreach ($all as $clientId => $list) {
            foreach ($this->allocate($list, $paid[$clientId]['paid'] ?? 0) as $row) {
                $byId[$row['invoice']->id] = $row;
            }
        }

        return $invoices->map(function (Invoice $inv) use ($byId) {
            $row = $byId[$inv->id];
            return self::formatInvoice($row['invoice'], $row['paid'], $row['due'], $row['status']);
        });
    }
}
