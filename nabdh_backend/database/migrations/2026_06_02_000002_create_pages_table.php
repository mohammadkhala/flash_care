<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pages', function (Blueprint $table) {
            $table->id();
            $table->string('slug')->unique();   // terms | privacy
            $table->string('title_ar');
            $table->string('title_en')->nullable();
            $table->string('title_he')->nullable();
            $table->longText('content_ar');
            $table->longText('content_en')->nullable();
            $table->longText('content_he')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        DB::table('pages')->insert([
            [
                'slug'       => 'terms',
                'title_ar'   => 'شروط الاستخدام',
                'title_en'   => 'Terms of Service',
                'title_he'   => 'תנאי שימוש',
                'content_ar' => '<h2>شروط استخدام تطبيق نبض</h2>
<p>بالاستخدام هذا التطبيق فإنك توافق على الشروط والأحكام التالية:</p>
<h3>1. القبول بالشروط</h3>
<p>يُعد استخدامك لتطبيق نبض قبولاً صريحاً منك لهذه الشروط والأحكام.</p>
<h3>2. الخدمات المقدمة</h3>
<p>يوفر التطبيق منصة للتواصل بين المرضى والأخصائيين الصحيين.</p>
<h3>3. المسؤولية</h3>
<p>لا يتحمل التطبيق مسؤولية القرارات الطبية المتخذة بناءً على المحتوى المقدم.</p>
<h3>4. الخصوصية</h3>
<p>نلتزم بحماية بياناتك الشخصية وفق سياسة الخصوصية المعتمدة.</p>',
                'content_en' => '<h2>NABD Terms of Service</h2>
<p>By using this application, you agree to the following terms and conditions.</p>
<h3>1. Acceptance of Terms</h3>
<p>Your use of NABD constitutes your express acceptance of these terms.</p>
<h3>2. Services Provided</h3>
<p>The application provides a platform for communication between patients and healthcare specialists.</p>
<h3>3. Liability</h3>
<p>The application is not responsible for medical decisions made based on provided content.</p>
<h3>4. Privacy</h3>
<p>We are committed to protecting your personal data in accordance with our privacy policy.</p>',
                'content_he' => '<h2>תנאי שימוש של NABD</h2>
<p>בשימוש באפליקציה זו, אתה מסכים לתנאים ולהגבלות הבאים.</p>
<h3>1. קבלת התנאים</h3>
<p>השימוש שלך ב-NABD מהווה הסכמה מפורשת לתנאים אלה.</p>',
                'is_active'  => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'slug'       => 'privacy',
                'title_ar'   => 'سياسة الخصوصية',
                'title_en'   => 'Privacy Policy',
                'title_he'   => 'מדיניות פרטיות',
                'content_ar' => '<h2>سياسة الخصوصية</h2>
<p>نحن في نبض نأخذ خصوصيتك على محمل الجد. تشرح هذه السياسة كيفية جمع بياناتك واستخدامها وحمايتها.</p>
<h3>1. البيانات التي نجمعها</h3>
<ul>
<li>الاسم الكامل ورقم الهاتف</li>
<li>المعلومات الصحية التي تشاركها طوعاً</li>
<li>بيانات الاستخدام والتفاعل مع التطبيق</li>
</ul>
<h3>2. كيف نستخدم بياناتك</h3>
<p>نستخدم بياناتك لتقديم الخدمة وتحسينها وضمان التواصل الفعال مع الأخصائيين.</p>
<h3>3. الأمان</h3>
<p>نستخدم تشفيراً متقدماً لحماية بياناتك من الوصول غير المصرح به.</p>
<h3>4. حقوقك</h3>
<p>يحق لك طلب حذف بياناتك في أي وقت عبر التواصل معنا.</p>',
                'content_en' => '<h2>Privacy Policy</h2>
<p>At NABD, we take your privacy seriously. This policy explains how your data is collected, used, and protected.</p>
<h3>1. Data We Collect</h3>
<ul>
<li>Full name and phone number</li>
<li>Health information you voluntarily share</li>
<li>Usage data and app interactions</li>
</ul>
<h3>2. How We Use Your Data</h3>
<p>We use your data to provide and improve our services.</p>
<h3>3. Security</h3>
<p>We use advanced encryption to protect your data from unauthorized access.</p>
<h3>4. Your Rights</h3>
<p>You have the right to request deletion of your data at any time.</p>',
                'content_he' => '<h2>מדיניות פרטיות</h2>
<p>ב-NABD, אנו מייחסים חשיבות רבה לפרטיותך.</p>
<h3>1. נתונים שאנו אוספים</h3>
<ul>
<li>שם מלא ומספר טלפון</li>
<li>מידע בריאותי שאתה משתף מרצונך</li>
</ul>',
                'is_active'  => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }

    public function down(): void
    {
        Schema::dropIfExists('pages');
    }
};
