<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('app_settings', function (Blueprint $table) {
            $table->id();
            $table->string('key')->unique();
            $table->text('value')->nullable();
            $table->string('label')->nullable();       // Human-readable label for admin UI
            $table->string('type')->default('text');   // text | boolean | textarea
            $table->string('group')->default('general');
            $table->timestamps();
        });

        // Seed default settings
        $defaults = [
            ['key' => 'whatsapp_support',   'value' => '',       'label' => 'رقم واتساب الدعم',        'type' => 'text',    'group' => 'support'],
            ['key' => 'whatsapp_message',   'value' => 'مرحباً، أحتاج مساعدة', 'label' => 'رسالة واتساب الافتراضية', 'type' => 'text', 'group' => 'support'],
            ['key' => 'maintenance_mode',   'value' => '0',      'label' => 'وضع الصيانة',             'type' => 'boolean', 'group' => 'general'],
            ['key' => 'maintenance_message','value' => 'التطبيق تحت الصيانة، يرجى المحاولة لاحقاً', 'label' => 'رسالة الصيانة', 'type' => 'textarea', 'group' => 'general'],
            ['key' => 'announcement_text',  'value' => '',       'label' => 'إشعار عام (بانر)',         'type' => 'textarea','group' => 'general'],
            ['key' => 'announcement_active','value' => '0',      'label' => 'تفعيل البانر',             'type' => 'boolean', 'group' => 'general'],
            ['key' => 'min_app_version',    'value' => '1.0.0',  'label' => 'أقل إصدار مدعوم',         'type' => 'text',    'group' => 'general'],
            ['key' => 'app_store_url',      'value' => '',       'label' => 'رابط App Store',           'type' => 'text',    'group' => 'general'],
            ['key' => 'play_store_url',     'value' => '',       'label' => 'رابط Play Store',          'type' => 'text',    'group' => 'general'],
        ];

        DB::table('app_settings')->insert(
            array_map(fn($r) => array_merge($r, [
                'created_at' => now(), 'updated_at' => now(),
            ]), $defaults)
        );
    }

    public function down(): void
    {
        Schema::dropIfExists('app_settings');
    }
};
