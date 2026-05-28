<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Specialization;
use Illuminate\Http\Request;

class SpecializationController extends Controller
{
    public function index()
    {
        $specializations = Specialization::withCount('therapists')->get();
        return view('admin.specializations.index', compact('specializations'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name_ar' => 'required|string|max:100',
            'name_en' => 'required|string|max:100',
        ]);

        Specialization::create($request->only('name_ar', 'name_en'));
        return back()->with('success', 'تمت إضافة التخصص');
    }

    public function update(Request $request, Specialization $specialization)
    {
        $request->validate([
            'name_ar' => 'required|string|max:100',
            'name_en' => 'required|string|max:100',
        ]);

        $specialization->update($request->only('name_ar', 'name_en'));
        return back()->with('success', 'تم تحديث التخصص');
    }

    public function toggleActive(Specialization $specialization)
    {
        $specialization->update(['is_active' => !$specialization->is_active]);
        return back();
    }
}
