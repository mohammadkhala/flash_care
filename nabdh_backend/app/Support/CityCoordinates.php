<?php

namespace App\Support;

/**
 * City-centre coordinates for Palestine and the surrounding region.
 *
 * Therapists frequently fill in a city but never a precise location, which used
 * to leave them invisible on the patient map. Resolving a city to its centre
 * gives every therapist a usable position; an explicitly-set latitude/longitude
 * always takes precedence over this fallback.
 */
class CityCoordinates
{
    /** @var array<string, array{lat: float, lng: float}> */
    private const CITIES = [
        // ── West Bank ────────────────────────────────────────────
        'القدس'        => ['lat' => 31.7683, 'lng' => 35.2137],
        'رام الله'     => ['lat' => 31.8996, 'lng' => 35.2042],
        'البيرة'       => ['lat' => 31.9067, 'lng' => 35.2172],
        'نابلس'        => ['lat' => 32.2211, 'lng' => 35.2544],
        'الخليل'       => ['lat' => 31.5326, 'lng' => 35.0998],
        'بيت لحم'      => ['lat' => 31.7054, 'lng' => 35.2024],
        'بيت جالا'     => ['lat' => 31.7156, 'lng' => 35.1875],
        'بيت ساحور'    => ['lat' => 31.6969, 'lng' => 35.2258],
        'جنين'         => ['lat' => 32.4607, 'lng' => 35.2966],
        'طولكرم'       => ['lat' => 32.3100, 'lng' => 35.0295],
        'قلقيلية'      => ['lat' => 32.1875, 'lng' => 34.9706],
        'أريحا'        => ['lat' => 31.8561, 'lng' => 35.4617],
        'طوباس'        => ['lat' => 32.3209, 'lng' => 35.3726],
        'سلفيت'        => ['lat' => 32.0833, 'lng' => 35.1747],
        'دورا'         => ['lat' => 31.5089, 'lng' => 35.0286],
        'يطا'          => ['lat' => 31.4489, 'lng' => 35.0894],
        'حلحول'        => ['lat' => 31.5806, 'lng' => 35.1006],
        'بيت أمر'      => ['lat' => 31.6089, 'lng' => 35.1050],
        'العيزرية'     => ['lat' => 31.7714, 'lng' => 35.2622],
        'أبو ديس'      => ['lat' => 31.7625, 'lng' => 35.2611],
        'قباطية'       => ['lat' => 32.4111, 'lng' => 35.2811],
        'عنبتا'        => ['lat' => 32.3103, 'lng' => 35.1136],
        'ترقوميا'      => ['lat' => 31.5717, 'lng' => 35.0169],

        // ── Gaza Strip ───────────────────────────────────────────
        'غزة'          => ['lat' => 31.5017, 'lng' => 34.4668],
        'خان يونس'     => ['lat' => 31.3452, 'lng' => 34.3028],
        'رفح'          => ['lat' => 31.2965, 'lng' => 34.2531],
        'دير البلح'    => ['lat' => 31.4183, 'lng' => 34.3511],
        'جباليا'       => ['lat' => 31.5272, 'lng' => 34.4831],
        'بيت لاهيا'    => ['lat' => 31.5500, 'lng' => 34.5000],
        'بيت حانون'    => ['lat' => 31.5386, 'lng' => 34.5386],
        'النصيرات'     => ['lat' => 31.4472, 'lng' => 34.3906],

        // ── Arab cities inside Israel (+972) ─────────────────────
        'حيفا'         => ['lat' => 32.7940, 'lng' => 34.9896],
        'تل أبيب'      => ['lat' => 32.0853, 'lng' => 34.7818],
        'يافا'         => ['lat' => 32.0522, 'lng' => 34.7508],
        'الناصرة'      => ['lat' => 32.7021, 'lng' => 35.2978],
        'عكا'          => ['lat' => 32.9281, 'lng' => 35.0818],
        'أم الفحم'     => ['lat' => 32.5197, 'lng' => 35.1519],
        'اللد'         => ['lat' => 31.9515, 'lng' => 34.8951],
        'الرملة'       => ['lat' => 31.9288, 'lng' => 34.8667],
        'بئر السبع'    => ['lat' => 31.2530, 'lng' => 34.7915],
        'الطيبة'       => ['lat' => 32.2661, 'lng' => 35.0086],
        'سخنين'        => ['lat' => 32.8644, 'lng' => 35.3003],
        'شفاعمرو'      => ['lat' => 32.8056, 'lng' => 35.1697],
        'باقة الغربية' => ['lat' => 32.4186, 'lng' => 35.0369],
        'كفر قاسم'     => ['lat' => 32.1147, 'lng' => 34.9772],
        'عرابة'        => ['lat' => 32.8511, 'lng' => 35.3389],
        'طمرة'         => ['lat' => 32.8531, 'lng' => 35.1978],
        'مجد الكروم'   => ['lat' => 32.9203, 'lng' => 35.2411],
        'كفر ياسيف'    => ['lat' => 32.9550, 'lng' => 35.1622],
        'طبريا'        => ['lat' => 32.7922, 'lng' => 35.5312],
        'صفد'          => ['lat' => 32.9646, 'lng' => 35.4960],
        'الرينة'       => ['lat' => 32.7231, 'lng' => 35.3161],
        'كفر كنا'      => ['lat' => 32.7472, 'lng' => 35.3392],
        'دير حنا'      => ['lat' => 32.8622, 'lng' => 35.3703],
        'يركا'         => ['lat' => 32.9614, 'lng' => 35.1889],
        'الرهط'        => ['lat' => 31.3919, 'lng' => 34.7550],
        'رهط'          => ['lat' => 31.3919, 'lng' => 34.7550],

        // ── Regional ─────────────────────────────────────────────
        'عمان'         => ['lat' => 31.9539, 'lng' => 35.9106],
        'بيروت'        => ['lat' => 33.8938, 'lng' => 35.5018],
    ];

    /** Fallback used when a city is unknown: roughly the centre of the West Bank. */
    public const DEFAULT = ['lat' => 31.9522, 'lng' => 35.2332];

    /**
     * Resolve a free-text city name to coordinates, or null when unrecognised.
     *
     * Matching tolerates the common variations therapists type: a leading "ال",
     * surrounding whitespace, and the interchangeable أ/إ/آ/ا and ة/ه forms.
     *
     * @return array{lat: float, lng: float}|null
     */
    public static function lookup(?string $city): ?array
    {
        if ($city === null || trim($city) === '') {
            return null;
        }

        $needle     = self::normalise($city);
        $needleTight = str_replace(' ', '', $needle);

        foreach (self::CITIES as $name => $coords) {
            $candidate = self::normalise($name);
            if ($candidate === $needle || str_replace(' ', '', $candidate) === $needleTight) {
                return $coords;
            }
        }

        // Fall back to a containment match so "مستشفى رام الله" still resolves.
        foreach (self::CITIES as $name => $coords) {
            $candidate = str_replace(' ', '', self::normalise($name));
            if ($candidate !== '' && str_contains($needleTight, $candidate)) {
                return $coords;
            }
        }

        return null;
    }

    /** Strip the diacritic/prefix variations that break exact string matching. */
    private static function normalise(string $value): string
    {
        $value = trim($value);
        $value = str_replace(['أ', 'إ', 'آ'], 'ا', $value);
        $value = str_replace('ة', 'ه', $value);
        $value = str_replace('ى', 'ي', $value);
        $value = preg_replace('/\s+/u', ' ', $value) ?? $value;
        $value = preg_replace('/^ال/u', '', $value) ?? $value;

        return trim($value);
    }

    /** @return array<string, array{lat: float, lng: float}> */
    public static function all(): array
    {
        return self::CITIES;
    }
}
