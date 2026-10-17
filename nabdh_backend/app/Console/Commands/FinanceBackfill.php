<?php

namespace App\Console\Commands;

use App\Models\Appointment;
use App\Models\Invoice;
use App\Services\FinanceService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

/**
 * One-off for appointments booked before the finance module:
 *   1. fills appointments.price from the therapist's current prices
 *   2. issues an invoice for every completed appointment that has none
 * Safe to re-run; sends no notifications.
 */
class FinanceBackfill extends Command
{
    protected $signature   = 'nabdh:finance-backfill {--dry-run : عرض ما سيتم دون حفظ}';
    protected $description = 'تعبئة أسعار المواعيد القديمة وإنشاء فواتير للجلسات المكتملة';

    public function handle(FinanceService $finance): int
    {
        $dry = (bool) $this->option('dry-run');
        $priced = 0; $invoiced = 0; $skipped = 0;

        Appointment::with('therapist')->whereNull('price')->chunkById(200, function ($rows) use ($finance, $dry, &$priced) {
            foreach ($rows as $a) {
                $price = $finance->priceFor($a);
                if ($price === null) continue;
                if (!$dry) $a->update(['price' => $price]);
                $priced++;
            }
        });

        $invoicedIds = Invoice::withTrashed()->whereNotNull('appointment_id')->pluck('appointment_id')->flip();

        Appointment::with(['therapist', 'patient.user'])->where('status', 'completed')
            ->orderBy('scheduled_at')
            ->chunkById(200, function ($rows) use ($finance, $dry, $invoicedIds, &$invoiced, &$skipped) {
                foreach ($rows as $a) {
                    if (isset($invoicedIds[$a->id])) continue;
                    $amount = $a->price !== null ? (float) $a->price : $finance->priceFor($a);
                    if (!$amount || !$a->patient) { $skipped++; continue; }

                    if (!$dry) {
                        DB::transaction(function () use ($finance, $a, $amount) {
                            $client = $finance->clientForPatient($a->therapist_id, $a->patient);
                            $type = $a->type === 'online' ? 'أونلاين' : 'حضورية';
                            Invoice::create([
                                'therapist_id'   => $a->therapist_id,
                                'client_id'      => $client->id,
                                'appointment_id' => $a->id,
                                'number'         => $finance->nextInvoiceNumber($a->therapist_id),
                                'issued_at'      => $a->scheduled_at->toDateString(),
                                'amount'         => $amount,
                                'discount'       => 0,
                                'description'    => "جلسة {$type}" . ($a->is_for_other && $a->other_name ? " — {$a->other_name}" : ''),
                            ]);
                        });
                    }
                    $invoiced++;
                }
            });

        $this->info(($dry ? '[تجربة] ' : '') . "أسعار مواعيد: {$priced} · فواتير جديدة: {$invoiced} · بلا سعر (تُركت): {$skipped}");
        return self::SUCCESS;
    }
}
