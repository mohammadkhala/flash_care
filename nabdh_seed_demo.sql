-- =============================================================
-- NABDH — Demo Seed Data (for production testing)
-- All passwords: Test@1234
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================================
-- 1. USERS  (2 admin already in production.sql, IDs start at 2)
-- =============================================================
INSERT INTO `users` (`id`, `phone`, `phone_country_code`, `type`, `password`, `is_active`, `phone_verified_at`, `created_at`, `updated_at`) VALUES
-- Therapists
(2,  '591111111', '+970', 'therapist', '$2y$12$7VmQWBCWY.gMUbofEZJjsOYU6BgyeRzs7qd4wLnDEvEcynh26MWu6', 1, NOW(), NOW(), NOW()),
(3,  '592222222', '+970', 'therapist', '$2y$12$7VmQWBCWY.gMUbofEZJjsOYU6BgyeRzs7qd4wLnDEvEcynh26MWu6', 1, NOW(), NOW(), NOW()),
(4,  '593333333', '+970', 'therapist', '$2y$12$7VmQWBCWY.gMUbofEZJjsOYU6BgyeRzs7qd4wLnDEvEcynh26MWu6', 1, NOW(), NOW(), NOW()),
(5,  '594444444', '+970', 'therapist', '$2y$12$7VmQWBCWY.gMUbofEZJjsOYU6BgyeRzs7qd4wLnDEvEcynh26MWu6', 1, NOW(), NOW(), NOW()),
(6,  '595555555', '+970', 'therapist', '$2y$12$7VmQWBCWY.gMUbofEZJjsOYU6BgyeRzs7qd4wLnDEvEcynh26MWu6', 1, NOW(), NOW(), NOW()),
-- Patients
(7,  '596666666', '+970', 'patient',   '$2y$12$7VmQWBCWY.gMUbofEZJjsOYU6BgyeRzs7qd4wLnDEvEcynh26MWu6', 1, NOW(), NOW(), NOW()),
(8,  '597777777', '+970', 'patient',   '$2y$12$7VmQWBCWY.gMUbofEZJjsOYU6BgyeRzs7qd4wLnDEvEcynh26MWu6', 1, NOW(), NOW(), NOW()),
(9,  '598888888', '+970', 'patient',   '$2y$12$7VmQWBCWY.gMUbofEZJjsOYU6BgyeRzs7qd4wLnDEvEcynh26MWu6', 1, NOW(), NOW(), NOW());

-- =============================================================
-- 2. THERAPISTS
-- =============================================================
INSERT INTO `therapists` (`id`, `user_id`, `full_name`, `full_name_en`, `bio`, `bio_en`, `years_experience`, `title`, `gender`, `city`, `degree`, `is_approved`, `is_verified`, `approved_at`, `accepts_online`, `accepts_in_person`, `online_session_price`, `in_person_session_price`, `session_duration`, `rating_average`, `rating_count`, `total_patients`, `total_sessions`, `is_featured`, `created_at`, `updated_at`) VALUES
(1, 2,
 'د. أحمد محمود النجار',
 'Dr. Ahmad Mahmoud Al-Najjar',
 'أخصائي علاج طبيعي عظام ومفاصل بخبرة 10 سنوات، متخصص في علاج آلام الظهر والركبة وإعادة التأهيل بعد العمليات.',
 'Orthopedic physical therapist with 10 years of experience, specializing in back and knee pain treatment and post-surgical rehabilitation.',
 10, 'أخصائي علاج طبيعي', 'male', 'رام الله', 'بكالوريوس علاج طبيعي - جامعة بيرزيت',
 1, 1, NOW(), 1, 1, 60.00, 80.00, 60, 4.80, 24, 45, 120, 1, NOW(), NOW()),

(2, 3,
 'د. سارة عمر الخضري',
 'Dr. Sara Omar Al-Khadri',
 'أخصائية علاج طبيعي أعصاب، خبرة 7 سنوات في علاج الشلل الرعاش ومتلازمة النفق الرسغي وإعادة تأهيل السكتة الدماغية.',
 'Neurological physiotherapist with 7 years of experience in treating Parkinson''s disease, carpal tunnel syndrome and stroke rehabilitation.',
 7, 'أخصائية علاج طبيعي أعصاب', 'female', 'نابلس', 'ماجستير علاج طبيعي أعصاب - جامعة القدس',
 1, 1, NOW(), 1, 1, 70.00, 90.00, 60, 4.90, 18, 32, 89, 1, NOW(), NOW()),

(3, 4,
 'د. محمد خالد البرغوثي',
 'Dr. Mohammad Khalid Al-Barghouthi',
 'أخصائي علاج طبيعي رياضي، عمل مع نوادٍ رياضية متعددة وأعاد تأهيل عشرات الرياضيين من إصابات الملاعب.',
 'Sports physical therapist who has worked with multiple sports clubs and rehabilitated dozens of athletes from field injuries.',
 5, 'أخصائي علاج رياضي', 'male', 'الخليل', 'بكالوريوس علاج طبيعي - جامعة الخليل',
 1, 0, NOW(), 0, 1, NULL, 65.00, 45, 4.60, 10, 20, 58, 0, NOW(), NOW()),

(4, 5,
 'د. منى حسين أبو عمر',
 'Dr. Mona Hussein Abu Omar',
 'أخصائية علاج وظيفي، متخصصة في مساعدة المرضى على استعادة الأنشطة اليومية بعد الإصابات والعمليات.',
 'Occupational therapist specialized in helping patients regain daily activities after injuries and surgeries.',
 8, 'أخصائية علاج وظيفي', 'female', 'غزة', 'بكالوريوس علاج وظيفي - الجامعة الإسلامية',
 1, 1, NOW(), 1, 0, 55.00, NULL, 60, 4.70, 15, 28, 76, 0, NOW(), NOW()),

(5, 6,
 'د. يوسف إبراهيم الشيخ',
 'Dr. Yusuf Ibrahim Al-Sheikh',
 'أخصائي علاج طبيعي أطفال، يعمل مع الأطفال ذوي الاحتياجات الخاصة وحالات التأخر الحركي.',
 'Pediatric physical therapist working with special needs children and motor development delays.',
 6, 'أخصائي علاج طبيعي أطفال', 'male', 'جنين', 'بكالوريوس علاج طبيعي أطفال - جامعة النجاح',
 0, 0, NULL, 1, 1, 50.00, 70.00, 60, 0.00, 0, 0, 0, 0, NOW(), NOW());

-- =============================================================
-- 3. PATIENTS
-- =============================================================
INSERT INTO `patients` (`id`, `user_id`, `full_name`, `date_of_birth`, `gender`, `city`, `medical_history`, `created_at`, `updated_at`) VALUES
(1, 7, 'رنا سامي حسين',   '1995-03-15', 'female', 'رام الله', 'تعاني من آلام مزمنة في الظهر السفلي نتيجة الجلوس الطويل أمام الحاسوب.', NOW(), NOW()),
(2, 8, 'تامر وليد عوض',   '1988-07-22', 'male',   'نابلس',    'أجرى عملية استبدال رباط الركبة الأمامي قبل 3 أشهر، يحتاج إعادة تأهيل.', NOW(), NOW()),
(3, 9, 'هالة رائد مصطفى', '2001-11-08', 'female', 'الخليل',   'طالبة جامعية، تعاني من آلام في الرقبة والكتفين.', NOW(), NOW());

-- =============================================================
-- 4. THERAPIST SPECIALIZATIONS
-- =============================================================
INSERT INTO `therapist_specializations` (`therapist_id`, `specialization_id`, `created_at`, `updated_at`) VALUES
(1, 2, NOW(), NOW()),  -- أحمد: عظام ومفاصل
(1, 9, NOW(), NOW()),  -- أحمد: إعادة تأهيل بعد جراحة
(2, 3, NOW(), NOW()),  -- سارة: أعصاب
(3, 4, NOW(), NOW()),  -- محمد: رياضي
(3, 9, NOW(), NOW()),  -- محمد: إعادة تأهيل بعد جراحة
(4, 7, NOW(), NOW()),  -- منى: علاج وظيفي
(5, 8, NOW(), NOW());  -- يوسف: أطفال

-- =============================================================
-- 5. THERAPIST SCHEDULES (0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu)
-- =============================================================
INSERT INTO `therapist_schedules` (`therapist_id`, `type`, `day_of_week`, `start_time`, `end_time`, `slot_duration`, `is_active`, `created_at`, `updated_at`) VALUES
-- أحمد: حضوري + أونلاين، الأحد-الخميس
(1, 'in_person', 0, '09:00:00', '13:00:00', 60, 1, NOW(), NOW()),
(1, 'in_person', 1, '09:00:00', '13:00:00', 60, 1, NOW(), NOW()),
(1, 'in_person', 2, '09:00:00', '13:00:00', 60, 1, NOW(), NOW()),
(1, 'in_person', 3, '09:00:00', '13:00:00', 60, 1, NOW(), NOW()),
(1, 'in_person', 4, '09:00:00', '12:00:00', 60, 1, NOW(), NOW()),
(1, 'online',    1, '16:00:00', '20:00:00', 60, 1, NOW(), NOW()),
(1, 'online',    3, '16:00:00', '20:00:00', 60, 1, NOW(), NOW()),
-- سارة: أونلاين فقط، أيام متعددة
(2, 'in_person', 0, '10:00:00', '14:00:00', 60, 1, NOW(), NOW()),
(2, 'in_person', 2, '10:00:00', '14:00:00', 60, 1, NOW(), NOW()),
(2, 'in_person', 4, '10:00:00', '13:00:00', 60, 1, NOW(), NOW()),
(2, 'online',    0, '17:00:00', '21:00:00', 60, 1, NOW(), NOW()),
(2, 'online',    2, '17:00:00', '21:00:00', 60, 1, NOW(), NOW()),
-- محمد: حضوري فقط
(3, 'in_person', 0, '08:00:00', '12:00:00', 45, 1, NOW(), NOW()),
(3, 'in_person', 1, '08:00:00', '12:00:00', 45, 1, NOW(), NOW()),
(3, 'in_person', 3, '08:00:00', '12:00:00', 45, 1, NOW(), NOW()),
(3, 'in_person', 4, '08:00:00', '11:00:00', 45, 1, NOW(), NOW()),
-- منى: أونلاين
(4, 'online',    1, '09:00:00', '13:00:00', 60, 1, NOW(), NOW()),
(4, 'online',    2, '09:00:00', '13:00:00', 60, 1, NOW(), NOW()),
(4, 'online',    4, '09:00:00', '12:00:00', 60, 1, NOW(), NOW());

-- =============================================================
-- 6. APPOINTMENTS
-- =============================================================
INSERT INTO `appointments` (`id`, `therapist_id`, `patient_id`, `scheduled_at`, `duration`, `type`, `status`, `patient_notes`, `created_at`, `updated_at`) VALUES
(1, 1, 1, DATE_ADD(NOW(), INTERVAL 2 DAY),    60, 'in_person', 'confirmed',  'أشعر بألم في أسفل الظهر يمتد إلى الساق اليسرى.',        NOW(), NOW()),
(2, 2, 2, DATE_ADD(NOW(), INTERVAL 1 DAY),    60, 'online',    'confirmed',  'جلسة متابعة ما بعد العملية.',                             NOW(), NOW()),
(3, 1, 3, DATE_ADD(NOW(), INTERVAL 5 DAY),    60, 'in_person', 'pending',    'ألم في الرقبة والكتف الأيمن.',                            NOW(), NOW()),
(4, 2, 1, DATE_SUB(NOW(), INTERVAL 7 DAY),    60, 'online',    'completed',  NULL,                                                       NOW(), NOW()),
(5, 3, 2, DATE_SUB(NOW(), INTERVAL 14 DAY),   45, 'in_person', 'completed',  'تعب في الركبة بعد التمارين.',                             NOW(), NOW()),
(6, 1, 2, DATE_SUB(NOW(), INTERVAL 3 DAY),    60, 'in_person', 'completed',  NULL,                                                       NOW(), NOW()),
(7, 4, 1, DATE_ADD(NOW(), INTERVAL 3 DAY),    60, 'online',    'confirmed',  'أحتاج تمارين لتقوية عضلات الظهر للعمل من المنزل.',       NOW(), NOW()),
(8, 2, 3, DATE_SUB(NOW(), INTERVAL 30 DAY),   60, 'in_person', 'cancelled_by_patient', 'لم أتمكن من الحضور.', NOW(), NOW());

-- =============================================================
-- 7. REVIEWS
-- =============================================================
INSERT INTO `reviews` (`therapist_id`, `patient_id`, `appointment_id`, `rating`, `comment`, `is_visible`, `published_at`, `created_at`, `updated_at`) VALUES
(2, 1, 4, 5, 'دكتورة سارة ممتازة، شرحت كل شيء بوضوح وأحسست بتحسن كبير بعد أول جلسة.',       1, NOW(), NOW(), NOW()),
(3, 2, 5, 4, 'دكتور محمد محترف جداً، لكن العيادة تحتاج تنظيماً أفضل في المواعيد.',           1, NOW(), NOW(), NOW()),
(1, 2, 6, 5, 'دكتور أحمد من أفضل المعالجين، صبور ومتمكن. أنصح به بشدة لمشاكل الركبة.',      1, NOW(), NOW(), NOW());

-- تحديث معدلات التقييم
UPDATE `therapists` SET `rating_average` = 5.00, `rating_count` = 1  WHERE `id` = 2;
UPDATE `therapists` SET `rating_average` = 4.60, `rating_count` = 10 WHERE `id` = 3;
UPDATE `therapists` SET `rating_average` = 4.80, `rating_count` = 24 WHERE `id` = 1;

-- =============================================================
-- 8. HOME PROGRAMS
-- =============================================================
INSERT INTO `home_programs` (`id`, `therapist_id`, `patient_id`, `appointment_id`, `title`, `description`, `start_date`, `end_date`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 6, 'برنامج تقوية عضلات الظهر',
 'برنامج تمارين يومية لتقوية العضلات الداعمة للعمود الفقري وتخفيف آلام أسفل الظهر.',
 CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), 1, NOW(), NOW()),

(2, 2, 2, 4, 'برنامج إعادة تأهيل الركبة',
 'تمارين تدريجية لاستعادة قوة ومرونة الركبة بعد عملية الرباط الصليبي الأمامي.',
 CURDATE(), DATE_ADD(CURDATE(), INTERVAL 45 DAY), 1, NOW(), NOW());

-- =============================================================
-- 9. PROGRAM EXERCISES
-- =============================================================
INSERT INTO `program_exercises` (`home_program_id`, `title`, `description`, `sets`, `reps`, `duration_seconds`, `frequency`, `media_type`, `order`, `created_at`, `updated_at`) VALUES
-- برنامج الظهر
(1, 'تمرين الجسر (Bridge)',
 'استلقِ على ظهرك وثنِ ركبتيك، ارفع الحوض لأعلى حتى يستقيم الجسم، اثبت 3 ثواني ثم انزل ببطء.',
 3, 15, NULL, 'يومياً', 'none', 1, NOW(), NOW()),

(1, 'تمرين الطائر والكلب (Bird-Dog)',
 'على أربع، مد الذراع اليمنى والساق اليسرى في آنٍ واحد، اثبت 5 ثواني ثم كرر بالجهة الأخرى.',
 3, 10, NULL, 'يومياً', 'none', 2, NOW(), NOW()),

(1, 'تمرين اللوح (Plank)',
 'استند على مرفقيك وأطراف قدميك مع إبقاء الجسم مستقيماً. ابقَ في الوضع المحدد.',
 3, NULL, 30, 'يومياً', 'none', 3, NOW(), NOW()),

(1, 'تمديد عضلة القطني (Cat-Cow Stretch)',
 'على أربع، تناوب بين تقعير الظهر للأعلى (القطة) وتقعيره للأسفل (البقرة) ببطء.',
 2, 10, NULL, 'مرتين يومياً', 'none', 4, NOW(), NOW()),

-- برنامج الركبة
(2, 'رفع الساق المستقيمة (SLR)',
 'استلقِ على ظهرك، شدّ عضلة الفخذ وارفع الساق المصابة حتى مستوى الركبة الأخرى، اثبت ثانيتين.',
 3, 15, NULL, 'يومياً', 'none', 1, NOW(), NOW()),

(2, 'تمارين القرفصاء الجزئي (Mini Squat)',
 'قف منتصباً، اثنِ الركبتين بزاوية 30 درجة فقط مع إبقاء الظهر مستقيماً.',
 3, 12, NULL, 'يومياً', 'none', 2, NOW(), NOW()),

(2, 'تمرين الحائط (Wall Slides)',
 'ضع ظهرك على الحائط وانزل ببطء حتى زاوية 45 درجة، اثبت 5 ثواني.',
 3, 10, NULL, 'يومياً', 'none', 3, NOW(), NOW()),

(2, 'تمديد عضلات الفخذ الخلفية (Hamstring Stretch)',
 'استلقِ واسحب ركبتك نحو صدرك، اثبت 20 ثانية، كرر 3 مرات لكل ساق.',
 3, NULL, 20, 'مرتين يومياً', 'none', 4, NOW(), NOW());

-- =============================================================
-- 10. REELS (approved demo content)
-- =============================================================
INSERT INTO `reels` (`therapist_id`, `title`, `description`, `video_url`, `thumbnail_url`, `duration_seconds`, `views`, `likes_count`, `comments_count`, `status`, `is_active`, `created_at`, `updated_at`) VALUES
(1,
 '3 تمارين لعلاج آلام أسفل الظهر',
 'شاهد معي أسهل 3 تمارين يمكنك عملها في المنزل لتخفيف آلام أسفل الظهر المزمنة. مناسبة لمن يجلس طويلاً أمام الشاشات.',
 'https://www.w3schools.com/html/mov_bbb.mp4',
 NULL,
 45, 320, 48, 7, 'approved', 1, NOW(), NOW()),

(2,
 'كيف تعرف أن عندك مشكلة في الأعصاب؟',
 'علامات تحذيرية قد تدل على وجود ضغط على الأعصاب — متى تزور أخصائي العلاج الطبيعي؟',
 'https://www.w3schools.com/html/mov_bbb.mp4',
 NULL,
 60, 185, 31, 4, 'approved', 1, NOW(), NOW()),

(3,
 'تمارين الإحماء قبل التدريب الرياضي',
 'لا تبدأ تدريبك بدون هذه التمارين! روتين إحماء كامل في 5 دقائق يحميك من الإصابات.',
 'https://www.w3schools.com/html/mov_bbb.mp4',
 NULL,
 55, 512, 89, 12, 'approved', 1, NOW(), NOW()),

(5,
 'تأخر المشي عند الأطفال — متى تقلق؟',
 'دكتور يوسف يشرح المراحل الطبيعية لتطور المشي عند الأطفال ومتى يجب استشارة أخصائي.',
 'https://www.w3schools.com/html/mov_bbb.mp4',
 NULL,
 72, 93, 14, 2, 'pending', 1, NOW(), NOW());

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================
-- Summary of demo accounts:
-- ─────────────────────────────────────────────────────────────
-- ADMIN:
--   phone: +970 599000000 | password: Admin@1234
--
-- THERAPISTS (all password: Test@1234):
--   +970 591111111 → د. أحمد النجار    (عظام، معتمد، مميز)
--   +970 592222222 → د. سارة الخضري   (أعصاب، معتمدة، مميزة)
--   +970 593333333 → د. محمد البرغوثي  (رياضي، معتمد)
--   +970 594444444 → د. منى أبو عمر    (وظيفي، معتمدة، أونلاين)
--   +970 595555555 → د. يوسف الشيخ    (أطفال، غير معتمد بعد)
--
-- PATIENTS (all password: Test@1234):
--   +970 596666666 → رنا حسين    (آلام ظهر)
--   +970 597777777 → تامر عوض    (إعادة تأهيل ركبة)
--   +970 598888888 → هالة مصطفى (آلام رقبة)
-- =============================================================
