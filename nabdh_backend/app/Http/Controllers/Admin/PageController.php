<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Page;
use Illuminate\Http\Request;

class PageController extends Controller
{
    public function index()
    {
        $pages = Page::all();
        return view('admin.pages.index', compact('pages'));
    }

    public function edit(string $slug)
    {
        $page = Page::where('slug', $slug)->firstOrFail();
        return view('admin.pages.edit', compact('page'));
    }

    public function update(Request $request, string $slug)
    {
        $page = Page::where('slug', $slug)->firstOrFail();
        $request->validate([
            'title_ar'   => 'required|string|max:200',
            'title_en'   => 'nullable|string|max:200',
            'title_he'   => 'nullable|string|max:200',
            'content_ar' => 'required|string',
            'content_en' => 'nullable|string',
            'content_he' => 'nullable|string',
        ]);
        $page->update($request->only([
            'title_ar','title_en','title_he',
            'content_ar','content_en','content_he','is_active',
        ]));
        return back()->with('success', 'تم حفظ الصفحة بنجاح ✓');
    }
}
