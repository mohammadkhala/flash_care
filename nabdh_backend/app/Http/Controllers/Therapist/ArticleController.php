<?php

namespace App\Http\Controllers\Therapist;

use App\Http\Controllers\Controller;
use App\Models\Article;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ArticleController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $articles = Article::where('therapist_id', $request->user()->therapist->id)
            ->latest()
            ->paginate(20);
        return response()->json($articles);
    }

    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'title'        => 'required|string|max:200',
            'content'      => 'required|string',
            'category'     => 'nullable|string|max:100',
            'is_published' => 'boolean',
            'cover_image'  => 'nullable|image|max:5120',
        ]);

        $data = $request->only(['title', 'content', 'category', 'is_published']);

        if ($request->hasFile('cover_image')) {
            $data['cover_image'] = $request->file('cover_image')->store('articles', 'public');
        }

        $article = Article::create(array_merge($data, [
            'therapist_id' => $request->user()->therapist->id,
        ]));

        return response()->json(['article' => $article], 201);
    }

    public function update(Request $request, Article $article): JsonResponse
    {
        abort_if($article->therapist_id !== $request->user()->therapist->id, 403);

        $request->validate([
            'title'        => 'sometimes|string|max:200',
            'content'      => 'sometimes|string',
            'category'     => 'nullable|string|max:100',
            'is_published' => 'boolean',
            'cover_image'  => 'nullable|image|max:5120',
        ]);

        $data = $request->only(['title', 'content', 'category', 'is_published']);

        if ($request->hasFile('cover_image')) {
            if ($article->cover_image) Storage::disk('public')->delete($article->cover_image);
            $data['cover_image'] = $request->file('cover_image')->store('articles', 'public');
        }

        $article->update($data);
        return response()->json(['article' => $article]);
    }

    public function uploadCover(Request $request): JsonResponse
    {
        $request->validate(['cover' => 'required|image|max:5120']);
        $path = $request->file('cover')->store('articles/covers', 'public');
        return response()->json([
            'cover_path' => $path,
            'cover_url'  => Storage::disk('public')->url($path),
        ]);
    }

    public function destroy(Article $article): JsonResponse
    {
        abort_if($article->therapist_id !== request()->user()->therapist->id, 403);
        if ($article->cover_image) Storage::disk('public')->delete($article->cover_image);
        $article->delete();
        return response()->json(['message' => 'تم حذف المقال']);
    }
}
