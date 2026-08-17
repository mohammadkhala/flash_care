<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Therapist;
use Illuminate\View\View;

class MapController extends Controller
{
    public function index(): View
    {
        // Load ALL therapists — coordinates are optional (JS will geocode cities)
        $therapists = Therapist::with(['user', 'specializations', 'clinics'])
            ->get()
            ->map(function ($t) {
                // Collect all clinics (with or without coordinates)
                $clinics = $t->clinics->map(fn($c) => [
                    'name'    => $c->name,
                    'address' => $c->address,
                    'city'    => $c->city,
                    'lat'     => $c->latitude  ? (float) $c->latitude  : null,
                    'lng'     => $c->longitude ? (float) $c->longitude : null,
                ])->values();

                // If no clinics, use therapist's own city field as a fallback
                if ($clinics->isEmpty()) {
                    $city = $t->city ?? null;
                    if ($city) {
                        $clinics = collect([[
                            'name'    => 'عيادة ' . $t->full_name,
                            'address' => $city,
                            'city'    => $city,
                            'lat'     => null,
                            'lng'     => null,
                        ]]);
                    }
                }

                return [
                    'id'              => $t->id,
                    'name'            => $t->full_name,
                    'avatar'          => $t->avatar,
                    'status'          => $t->status,
                    'city'            => $t->clinics->first()?->city ?? $t->city ?? '—',
                    'rating'          => round($t->rating_average ?? 0, 1),
                    'specializations' => $t->specializations->pluck('name_ar')->implode('، '),
                    'clinics'         => $clinics,
                ];
            })
            ->values();

        // Stats per city
        $cityCounts = $therapists
            ->groupBy('city')
            ->map(fn($g) => $g->count())
            ->sortByDesc(fn($c) => $c);

        return view('admin.map.index', compact('therapists', 'cityCounts'));
    }
}
