-- نبض Database Backup 2026-06-02 05:45:51
SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `app_settings`;
CREATE TABLE `app_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `value` text DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `type` varchar(255) NOT NULL DEFAULT 'text',
  `group` varchar(255) NOT NULL DEFAULT 'general',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `app_settings_key_unique` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `app_settings` (`id`,`key`,`value`,`label`,`type`,`group`,`created_at`,`updated_at`) VALUES
('1','whatsapp_support','+972594513978','رقم واتساب الدعم','text','support','2026-06-01 15:55:16','2026-06-01 18:46:33'),
('2','whatsapp_message','مرحباً، أحتاج مساعدة','رسالة واتساب الافتراضية','text','support','2026-06-01 15:55:16','2026-06-01 18:46:33'),
('3','maintenance_mode','0','وضع الصيانة','boolean','general','2026-06-01 15:55:16','2026-06-01 18:46:33'),
('4','maintenance_message','التطبيق تحت الصيانة، يرجى المحاولة لاحقاً','رسالة الصيانة','textarea','general','2026-06-01 15:55:16','2026-06-01 18:46:33'),
('5','announcement_text','','إشعار عام (بانر)','textarea','general','2026-06-01 15:55:16','2026-06-01 18:46:33'),
('6','announcement_active','0','تفعيل البانر','boolean','general','2026-06-01 15:55:16','2026-06-01 18:46:33'),
('7','min_app_version','1.0.0','أقل إصدار مدعوم','text','general','2026-06-01 15:55:16','2026-06-01 18:46:33'),
('8','app_store_url','','رابط App Store','text','general','2026-06-01 15:55:16','2026-06-01 18:46:33'),
('9','play_store_url','','رابط Play Store','text','general','2026-06-01 15:55:16','2026-06-01 18:46:33');

DROP TABLE IF EXISTS `appointments`;
CREATE TABLE `appointments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `clinic_id` bigint(20) unsigned DEFAULT NULL,
  `scheduled_at` datetime NOT NULL,
  `duration` int(11) NOT NULL DEFAULT 60,
  `type` enum('in_person','online') NOT NULL DEFAULT 'in_person',
  `status` enum('pending','confirmed','cancelled_by_patient','cancelled_by_therapist','completed','no_show') NOT NULL DEFAULT 'pending',
  `cancellation_reason` varchar(255) DEFAULT NULL,
  `patient_notes` text DEFAULT NULL,
  `is_for_other` tinyint(1) NOT NULL DEFAULT 0,
  `other_name` varchar(255) DEFAULT NULL,
  `other_age` tinyint(3) unsigned DEFAULT NULL,
  `other_relation` varchar(255) DEFAULT NULL,
  `agora_channel` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `appointments_therapist_id_foreign` (`therapist_id`),
  KEY `appointments_patient_id_foreign` (`patient_id`),
  KEY `appointments_clinic_id_foreign` (`clinic_id`),
  CONSTRAINT `appointments_clinic_id_foreign` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`) ON DELETE SET NULL,
  CONSTRAINT `appointments_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `appointments_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `appointments` (`id`,`therapist_id`,`patient_id`,`clinic_id`,`scheduled_at`,`duration`,`type`,`status`,`cancellation_reason`,`patient_notes`,`is_for_other`,`other_name`,`other_age`,`other_relation`,`agora_channel`,`created_at`,`updated_at`) VALUES
('1','7','1',NULL,'2026-05-01 10:00:00','60','in_person','confirmed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('2','2','1',NULL,'2026-05-03 15:00:00','60','in_person','confirmed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('3','3','1',NULL,'2026-05-29 17:00:00','60','in_person','completed',NULL,NULL,'0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('4','9','1',NULL,'2026-05-25 13:00:00','60','online','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('5','8','2',NULL,'2026-03-31 11:00:00','60','online','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('6','9','2',NULL,'2026-04-22 10:00:00','60','online','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('7','9','2',NULL,'2026-04-02 11:00:00','60','online','confirmed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('8','8','2',NULL,'2026-05-10 16:00:00','60','in_person','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('9','5','3',NULL,'2026-04-01 13:00:00','60','online','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('10','3','3',NULL,'2026-05-16 12:00:00','60','online','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('11','2','4',NULL,'2026-05-20 16:00:00','60','in_person','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('12','4','4',NULL,'2026-03-28 11:00:00','60','online','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('13','4','5',NULL,'2026-04-24 13:00:00','60','online','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('14','6','5',NULL,'2026-05-09 12:00:00','60','in_person','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('15','6','5',NULL,'2026-04-24 17:00:00','60','in_person','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('16','3','5',NULL,'2026-04-15 13:00:00','60','online','completed',NULL,'ألم في الظهر والكتف','0',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('17','1','1','1','2026-06-01 09:00:00','60','in_person','confirmed',NULL,NULL,'0',NULL,NULL,NULL,NULL,'2026-05-28 12:58:42','2026-05-28 18:04:26'),
('18','6','1',NULL,'2026-06-02 10:00:00','60','in_person','pending',NULL,NULL,'0',NULL,NULL,NULL,NULL,'2026-05-28 14:02:05','2026-05-28 14:02:05'),
('19','1','1','1','2026-06-02 09:00:00','60','in_person','completed',NULL,NULL,'0',NULL,NULL,NULL,NULL,'2026-05-28 18:01:31','2026-05-28 18:14:16');

DROP TABLE IF EXISTS `articles`;
CREATE TABLE `articles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `cover_image` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `is_published` tinyint(1) NOT NULL DEFAULT 0,
  `views_count` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `articles_therapist_id_foreign` (`therapist_id`),
  CONSTRAINT `articles_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `assessments`;
CREATE TABLE `assessments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned DEFAULT NULL,
  `type` varchar(10) NOT NULL,
  `answers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`answers`)),
  `score` tinyint(3) unsigned NOT NULL,
  `severity` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `assessments_therapist_id_foreign` (`therapist_id`),
  CONSTRAINT `assessments_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `cache`;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `cache` (`key`,`value`,`expiration`) VALUES
('nbd-cache-fcm_access_token','s:1024:\"ya29.c.c0AZ4bNpYCLSlYX3EAKKKd2CFVHBlDRylBXiKsi0blXQiVk_y4rU1yaaaXetPEhQN9LHIcOIdqh-cGesug_KT62P-DVRk8j5czHb-2NXKo-1xOceIVmG2Wv0gdHohX8gjMn54fF51Q36IGWyyDnm2WsNrRuaAaH4jQp_XGLX0RrOIXsOY59mxMm3r4dfv6-HJVe9-1eqqz1Prpg9GcIygGQLCp9Fa73m9rZuhXx4ofXgda3CNZbvkeD1ejP5jSxGX7l9DSrelHUBnZeVfwX9C218Qjy5Isf8wvQrzyWYVjn0B0WCQEzx0UhL3ojRNnylyRd5N2vDTREgg6JWjj5WYrmWt6gFhPc5RdSBeuU4ajcQzWqIlaWcmD6QAlKQG387Cs6iu-FQUtZkU3mph3icqQqUjbzzcxOo9r0qhkrqmbfrVjBZOkOidYFOlRbb1rIaqw3_-o7ujeZrMnXFYZa0_lmhyOvM2Bm8a8Rgios3vsSw2QMvWWYevU4wWiB26qiteQiSOcrkW-l1J818bmWF8-VnbdeXcy9qaf4MhuqtejkyXwyOtaOupVk4iZW-R_O4lf9wjR26a2M-9WzF98x2V_nydYB9XZwU9ymR15g3tjxQQMz5jRialJwl1thx45Zwu_Jm3sc7mYX1bS6uR-_va9Xq4bOcBWm4p0ffF-2RB6j4d7zp2kdcpx1i05B9QUXi7a4oO_f9VhOg8d9hUMxuFpkZk2gp8kZy5xhjidwme74Iip39o60RZp7Vu7WyV9ygtRsa4zfZsb7JdMfsBOq-Uhd0Fx4-ypuUyYiOdQZQId6VYZUqFI1Id_sa5r3xVUvbmu5dOw2hkO-dkzgw5kM6589IUQQBkqXm6c8b8d7XJvMy7XWRW-XhdR-IY3-p-vphsbsv20_uF8g6IRk73zjMkFy_wyp6pptbbXMBSfofuMOlgfJMl6_0z6wMoZbkwtorZXtVjvSmkt_iux_0010YW9cU5UIu1WBn1WQqYnWVv5h1mFSBtzYj99sds\";','1780381358');

DROP TABLE IF EXISTS `cache_locks`;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `clinics`;
CREATE TABLE `clinics` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `city` varchar(255) NOT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `clinics_therapist_id_foreign` (`therapist_id`),
  CONSTRAINT `clinics_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `clinics` (`id`,`therapist_id`,`name`,`address`,`city`,`latitude`,`longitude`,`phone`,`is_active`,`created_at`,`updated_at`) VALUES
('1','1','عيادة محمد خلاف','شارع الوحدة','الخليل',NULL,NULL,NULL,'1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('2','2','عيادة د. سارة الأحمد','شارع الوحدة','رام الله',NULL,NULL,NULL,'1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('3','3','عيادة أ. يوسف ناصر','شارع الوحدة','نابلس',NULL,NULL,NULL,'1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('4','4','عيادة د. منى حسين','شارع الوحدة','الخليل',NULL,NULL,NULL,'1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('5','5','عيادة أ. خالد إبراهيم','شارع الوحدة','بيت لحم',NULL,NULL,NULL,'1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('6','6','عيادة د. رنا المصري','شارع الوحدة','رام الله',NULL,NULL,NULL,'1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('7','7','عيادة أ. عمر شحادة','شارع الوحدة','جنين',NULL,NULL,NULL,'1','2026-05-28 11:00:33','2026-05-28 11:00:33'),
('8','8','عيادة د. ليلى عبد الرحمن','شارع الوحدة','نابلس',NULL,NULL,NULL,'1','2026-05-28 11:00:33','2026-05-28 11:00:33'),
('9','9','عيادة أ. باسم قاسم','شارع الوحدة','القدس',NULL,NULL,NULL,'1','2026-05-28 11:00:33','2026-05-28 11:00:33');

DROP TABLE IF EXISTS `conversations`;
CREATE TABLE `conversations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `last_message_id` bigint(20) unsigned DEFAULT NULL,
  `last_message_at` timestamp NULL DEFAULT NULL,
  `therapist_unread` int(11) NOT NULL DEFAULT 0,
  `patient_unread` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `conversations_therapist_id_patient_id_unique` (`therapist_id`,`patient_id`),
  KEY `conversations_patient_id_foreign` (`patient_id`),
  KEY `conversations_last_message_id_foreign` (`last_message_id`),
  CONSTRAINT `conversations_last_message_id_foreign` FOREIGN KEY (`last_message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `conversations_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `conversations_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `conversations` (`id`,`therapist_id`,`patient_id`,`last_message_id`,`last_message_at`,`therapist_unread`,`patient_unread`,`created_at`,`updated_at`) VALUES
('1','1','6','2','2026-05-26 14:38:25','0','0','2026-05-26 14:38:22','2026-05-26 14:38:42'),
('2','3','1','6','2026-05-28 17:59:21','4','0','2026-05-28 10:20:15','2026-05-28 17:59:21'),
('3','1','1','11','2026-05-28 19:57:50','0','0','2026-05-28 17:59:26','2026-06-02 05:15:07'),
('4','6','6','12','2026-06-02 05:20:21','1','0','2026-06-02 05:20:21','2026-06-02 05:20:21');

DROP TABLE IF EXISTS `exercise_completions`;
CREATE TABLE `exercise_completions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `program_exercise_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `completed_date` date NOT NULL,
  `patient_note` text DEFAULT NULL,
  `pain_before` int(11) DEFAULT NULL,
  `pain_after` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `exercise_completions_program_exercise_id_foreign` (`program_exercise_id`),
  KEY `exercise_completions_patient_id_foreign` (`patient_id`),
  CONSTRAINT `exercise_completions_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `exercise_completions_program_exercise_id_foreign` FOREIGN KEY (`program_exercise_id`) REFERENCES `program_exercises` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `failed_jobs`;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `goal_progress_logs`;
CREATE TABLE `goal_progress_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `goal_id` bigint(20) unsigned NOT NULL,
  `progress` tinyint(3) unsigned NOT NULL,
  `notes` text DEFAULT NULL,
  `logged_by` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `goal_progress_logs_goal_id_foreign` (`goal_id`),
  KEY `goal_progress_logs_logged_by_foreign` (`logged_by`),
  CONSTRAINT `goal_progress_logs_goal_id_foreign` FOREIGN KEY (`goal_id`) REFERENCES `patient_goals` (`id`) ON DELETE CASCADE,
  CONSTRAINT `goal_progress_logs_logged_by_foreign` FOREIGN KEY (`logged_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `goal_progress_logs` (`id`,`goal_id`,`progress`,`notes`,`logged_by`,`created_at`) VALUES
('1','1','0',NULL,'2','2026-06-02 08:27:37'),
('2','1','20',NULL,'2','2026-06-02 08:36:04'),
('3','1','100',NULL,'2','2026-06-02 08:36:19'),
('4','2','40',NULL,'2','2026-06-02 08:40:54'),
('5','2','40',NULL,'2','2026-06-02 08:40:58');

DROP TABLE IF EXISTS `home_programs`;
CREATE TABLE `home_programs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `appointment_id` bigint(20) unsigned DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `start_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `home_programs_therapist_id_foreign` (`therapist_id`),
  KEY `home_programs_patient_id_foreign` (`patient_id`),
  KEY `home_programs_appointment_id_foreign` (`appointment_id`),
  CONSTRAINT `home_programs_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `home_programs_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `home_programs_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `home_programs` (`id`,`therapist_id`,`patient_id`,`appointment_id`,`title`,`description`,`start_date`,`end_date`,`is_active`,`created_at`,`updated_at`) VALUES
('1','1','6',NULL,'تقويم',NULL,'2026-05-28',NULL,'1','2026-05-28 19:06:28','2026-05-28 19:06:28'),
('2','1','1',NULL,'تقويم',NULL,'2026-05-28',NULL,'1','2026-05-28 19:15:34','2026-05-28 19:15:34');

DROP TABLE IF EXISTS `job_batches`;
CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `jobs`;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `messages`;
CREATE TABLE `messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint(20) unsigned NOT NULL,
  `sender_id` bigint(20) unsigned NOT NULL,
  `content` text DEFAULT NULL,
  `type` enum('text','image','file','voice','video','location') NOT NULL DEFAULT 'text',
  `media_url` varchar(255) DEFAULT NULL,
  `media_name` varchar(255) DEFAULT NULL,
  `media_size` int(11) DEFAULT NULL,
  `voice_duration` int(11) DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `messages_conversation_id_foreign` (`conversation_id`),
  KEY `messages_sender_id_foreign` (`sender_id`),
  CONSTRAINT `messages_conversation_id_foreign` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `messages_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `messages` (`id`,`conversation_id`,`sender_id`,`content`,`type`,`media_url`,`media_name`,`media_size`,`voice_duration`,`read_at`,`is_deleted`,`created_at`,`updated_at`) VALUES
('1','1','2','.','text',NULL,NULL,NULL,NULL,'2026-05-26 14:38:42','0','2026-05-26 14:38:22','2026-05-26 14:38:42'),
('2','1','2','..s','text',NULL,NULL,NULL,NULL,'2026-05-26 14:38:42','0','2026-05-26 14:38:25','2026-05-26 14:38:42'),
('3','2','14','.','text',NULL,NULL,NULL,NULL,NULL,'0','2026-05-28 10:20:15','2026-05-28 10:20:15'),
('4','2','14',NULL,'file','http://192.168.1.9:8000/storage/messages/1v2yv8nzI4D0goUpBMr9yTkIrnIvkBfItQFkprGl.jpg','Screenshot_٢٠٢٦٠٥٢٨_١٢٢٧٤٢.jpg',NULL,NULL,NULL,'0','2026-05-28 10:21:40','2026-05-28 10:21:40'),
('5','2','14','.','text',NULL,NULL,NULL,NULL,NULL,'0','2026-05-28 12:57:29','2026-05-28 12:57:29'),
('6','2','14','.','text',NULL,NULL,NULL,NULL,NULL,'0','2026-05-28 17:59:21','2026-05-28 17:59:21'),
('7','3','14','.','text',NULL,NULL,NULL,NULL,'2026-05-28 17:59:58','0','2026-05-28 17:59:26','2026-05-28 17:59:58'),
('8','3','2','..','text',NULL,NULL,NULL,NULL,'2026-05-28 19:16:37','0','2026-05-28 19:16:29','2026-05-28 19:16:37'),
('9','3','2','ظمؤي','text',NULL,NULL,NULL,NULL,'2026-05-28 19:16:37','0','2026-05-28 19:16:33','2026-05-28 19:16:37'),
('10','3','14','.','text',NULL,NULL,NULL,NULL,'2026-05-28 19:54:11','0','2026-05-28 19:52:52','2026-05-28 19:54:11'),
('11','3','14','مرحبا','text',NULL,NULL,NULL,NULL,'2026-06-02 05:15:07','0','2026-05-28 19:57:50','2026-06-02 05:15:07'),
('12','4','19','..','text',NULL,NULL,NULL,NULL,NULL,'0','2026-06-02 05:20:21','2026-06-02 05:20:21');

DROP TABLE IF EXISTS `migrations`;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `migrations` (`id`,`migration`,`batch`) VALUES
('1','0001_01_01_000000_create_users_table','1'),
('2','0001_01_01_000001_create_cache_table','1'),
('3','0001_01_01_000002_create_jobs_table','1'),
('4','2024_01_01_000001_create_users_table','1'),
('5','2024_01_01_000002_create_therapists_table','1'),
('6','2024_01_01_000003_create_patients_table','1'),
('7','2024_01_01_000004_create_specializations_table','1'),
('8','2024_01_01_000005_create_therapist_details_table','1'),
('9','2024_01_01_000006_create_clinics_and_schedules_table','1'),
('10','2024_01_01_000007_create_appointments_table','1'),
('11','2024_01_01_000008_create_home_programs_table','1'),
('12','2024_01_01_000009_create_messaging_table','1'),
('13','2024_01_01_000010_create_reviews_and_reels_table','1'),
('14','2024_01_01_000011_create_notifications_table','1'),
('15','2024_01_01_000001_create_nabdh_admin_tables','2'),
('16','2026_05_26_081449_create_personal_access_tokens_table','3'),
('17','2026_05_26_082107_add_degree_to_therapists_table','4'),
('18','2026_05_26_093538_create_articles_table','5'),
('19','2026_05_26_094841_create_assessments_table','6'),
('20','2026_05_26_130849_create_reel_comments_table','7'),
('21','2026_05_28_110037_add_family_booking_to_appointments','8'),
('22','2026_05_28_110038_create_patient_documents_table','8'),
('23','2026_06_01_145212_create_patient_goals_table','9'),
('24','2026_06_01_145213_create_goal_progress_logs_table','9'),
('25','2026_06_02_000001_create_app_settings_table','10'),
('26','2026_06_02_000002_create_pages_table','10'),
('27','2026_06_01_185208_create_therapist_documents_table','11'),
('28','2026_06_02_000001_add_location_to_messages_type_enum','12');

DROP TABLE IF EXISTS `outcome_measures`;
CREATE TABLE `outcome_measures` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name_ar` varchar(255) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `abbreviation` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`questions`)),
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `pages`;
CREATE TABLE `pages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) NOT NULL,
  `title_ar` varchar(255) NOT NULL,
  `title_en` varchar(255) DEFAULT NULL,
  `title_he` varchar(255) DEFAULT NULL,
  `content_ar` longtext NOT NULL,
  `content_en` longtext DEFAULT NULL,
  `content_he` longtext DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pages_slug_unique` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `pages` (`id`,`slug`,`title_ar`,`title_en`,`title_he`,`content_ar`,`content_en`,`content_he`,`is_active`,`created_at`,`updated_at`) VALUES
('1','terms','شروط الاستخدام','Terms of Service','תנאי שימוש','<h2>شروط استخدام تطبيق نبض</h2>\n<p>بالاستخدام هذا التطبيق فإنك توافق على الشروط والأحكام التالية:</p>\n<h3>1. القبول بالشروط</h3>\n<p>يُعد استخدامك لتطبيق نبض قبولاً صريحاً منك لهذه الشروط والأحكام.</p>\n<h3>2. الخدمات المقدمة</h3>\n<p>يوفر التطبيق منصة للتواصل بين المرضى والأخصائيين الصحيين.</p>\n<h3>3. المسؤولية</h3>\n<p>لا يتحمل التطبيق مسؤولية القرارات الطبية المتخذة بناءً على المحتوى المقدم.</p>\n<h3>4. الخصوصية</h3>\n<p>نلتزم بحماية بياناتك الشخصية وفق سياسة الخصوصية المعتمدة.</p>','<h2>NABD Terms of Service</h2>\n<p>By using this application, you agree to the following terms and conditions.</p>\n<h3>1. Acceptance of Terms</h3>\n<p>Your use of NABD constitutes your express acceptance of these terms.</p>\n<h3>2. Services Provided</h3>\n<p>The application provides a platform for communication between patients and healthcare specialists.</p>\n<h3>3. Liability</h3>\n<p>The application is not responsible for medical decisions made based on provided content.</p>\n<h3>4. Privacy</h3>\n<p>We are committed to protecting your personal data in accordance with our privacy policy.</p>','<h2>תנאי שימוש של NABD</h2>\n<p>בשימוש באפליקציה זו, אתה מסכים לתנאים ולהגבלות הבאים.</p>\n<h3>1. קבלת התנאים</h3>\n<p>השימוש שלך ב-NABD מהווה הסכמה מפורשת לתנאים אלה.</p>','1','2026-06-01 15:55:16','2026-06-01 15:55:16'),
('2','privacy','سياسة الخصوصية','Privacy Policy','מדיניות פרטיות','<h2>سياسة الخصوصية</h2>\n<p>نحن في نبض نأخذ خصوصيتك على محمل الجد. تشرح هذه السياسة كيفية جمع بياناتك واستخدامها وحمايتها.</p>\n<h3>1. البيانات التي نجمعها</h3>\n<ul>\n<li>الاسم الكامل ورقم الهاتف</li>\n<li>المعلومات الصحية التي تشاركها طوعاً</li>\n<li>بيانات الاستخدام والتفاعل مع التطبيق</li>\n</ul>\n<h3>2. كيف نستخدم بياناتك</h3>\n<p>نستخدم بياناتك لتقديم الخدمة وتحسينها وضمان التواصل الفعال مع الأخصائيين.</p>\n<h3>3. الأمان</h3>\n<p>نستخدم تشفيراً متقدماً لحماية بياناتك من الوصول غير المصرح به.</p>\n<h3>4. حقوقك</h3>\n<p>يحق لك طلب حذف بياناتك في أي وقت عبر التواصل معنا.</p>','<h2>Privacy Policy</h2>\n<p>At NABD, we take your privacy seriously. This policy explains how your data is collected, used, and protected.</p>\n<h3>1. Data We Collect</h3>\n<ul>\n<li>Full name and phone number</li>\n<li>Health information you voluntarily share</li>\n<li>Usage data and app interactions</li>\n</ul>\n<h3>2. How We Use Your Data</h3>\n<p>We use your data to provide and improve our services.</p>\n<h3>3. Security</h3>\n<p>We use advanced encryption to protect your data from unauthorized access.</p>\n<h3>4. Your Rights</h3>\n<p>You have the right to request deletion of your data at any time.</p>','<h2>מדיניות פרטיות</h2>\n<p>ב-NABD, אנו מייחסים חשיבות רבה לפרטיותך.</p>\n<h3>1. נתונים שאנו אוספים</h3>\n<ul>\n<li>שם מלא ומספר טלפון</li>\n<li>מידע בריאותי שאתה משתף מרצונך</li>\n</ul>','1','2026-06-01 15:55:16','2026-06-01 15:55:16');

DROP TABLE IF EXISTS `pain_diary`;
CREATE TABLE `pain_diary` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `date` date NOT NULL,
  `pain_scale` tinyint(4) NOT NULL,
  `body_part` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `pain_diary_patient_id_foreign` (`patient_id`),
  CONSTRAINT `pain_diary_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `patient_assessments`;
CREATE TABLE `patient_assessments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `appointment_id` bigint(20) unsigned DEFAULT NULL,
  `outcome_measure_id` bigint(20) unsigned NOT NULL,
  `answers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`answers`)),
  `score` decimal(5,2) DEFAULT NULL,
  `interpretation` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `patient_assessments_therapist_id_foreign` (`therapist_id`),
  KEY `patient_assessments_patient_id_foreign` (`patient_id`),
  KEY `patient_assessments_appointment_id_foreign` (`appointment_id`),
  KEY `patient_assessments_outcome_measure_id_foreign` (`outcome_measure_id`),
  CONSTRAINT `patient_assessments_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `patient_assessments_outcome_measure_id_foreign` FOREIGN KEY (`outcome_measure_id`) REFERENCES `outcome_measures` (`id`) ON DELETE CASCADE,
  CONSTRAINT `patient_assessments_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `patient_assessments_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `patient_documents`;
CREATE TABLE `patient_documents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `patient_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `type` enum('diagnosis','report','prescription','scan','lab','other') NOT NULL DEFAULT 'other',
  `file_url` varchar(1000) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `file_mime` varchar(255) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `doctor_name` varchar(255) DEFAULT NULL,
  `document_date` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `patient_documents_patient_id_foreign` (`patient_id`),
  CONSTRAINT `patient_documents_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `patient_goals`;
CREATE TABLE `patient_goals` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `appointment_id` bigint(20) unsigned DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `target_date` date NOT NULL,
  `extended_date` date DEFAULT NULL,
  `current_progress` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `status` enum('active','completed','cancelled') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `patient_goals_therapist_id_foreign` (`therapist_id`),
  KEY `patient_goals_patient_id_foreign` (`patient_id`),
  KEY `patient_goals_appointment_id_foreign` (`appointment_id`),
  CONSTRAINT `patient_goals_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `patient_goals_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `patient_goals_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `patient_goals` (`id`,`therapist_id`,`patient_id`,`appointment_id`,`title`,`description`,`target_date`,`extended_date`,`current_progress`,`status`,`created_at`,`updated_at`) VALUES
('1','1','1',NULL,'المشي','المشي بشكل طبيعي','2026-06-16',NULL,'100','completed','2026-06-02 05:15:47','2026-06-02 05:36:19'),
('2','1','1',NULL,'المشي',NULL,'2026-06-30',NULL,'40','active','2026-06-02 05:27:48','2026-06-02 05:40:54'),
('3','1','1',NULL,'المشي',NULL,'2026-06-30',NULL,'0','active','2026-06-02 05:35:58','2026-06-02 05:35:58');

DROP TABLE IF EXISTS `patients`;
CREATE TABLE `patients` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` enum('male','female') DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `medical_history` text DEFAULT NULL,
  `allergies` text DEFAULT NULL,
  `emergency_contact_name` varchar(255) DEFAULT NULL,
  `emergency_contact_phone` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `patients_user_id_foreign` (`user_id`),
  CONSTRAINT `patients_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `patients` (`id`,`user_id`,`full_name`,`avatar`,`date_of_birth`,`gender`,`city`,`medical_history`,`allergies`,`emergency_contact_name`,`emergency_contact_phone`,`created_at`,`updated_at`) VALUES
('1','14','أحمد حسين',NULL,NULL,'male','رام الله',NULL,NULL,NULL,NULL,'2026-05-26 14:05:08','2026-05-26 14:05:08'),
('2','15','فاطمة علي',NULL,NULL,'female','نابلس',NULL,NULL,NULL,NULL,'2026-05-26 14:05:08','2026-05-26 14:05:08'),
('3','16','محمود عمر',NULL,NULL,'male','الخليل',NULL,NULL,NULL,NULL,'2026-05-26 14:05:08','2026-05-26 14:05:08'),
('4','17','نور سالم',NULL,NULL,'female','بيت لحم',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('5','18','كريم داود',NULL,NULL,'male','جنين',NULL,NULL,NULL,NULL,'2026-05-26 14:05:09','2026-05-26 14:05:09'),
('6','19','محمد',NULL,NULL,'male','الخليل',NULL,NULL,NULL,NULL,'2026-05-26 14:28:33','2026-05-26 14:28:33');

DROP TABLE IF EXISTS `personal_access_tokens`;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `personal_access_tokens` (`id`,`tokenable_type`,`tokenable_id`,`name`,`token`,`abilities`,`last_used_at`,`expires_at`,`created_at`,`updated_at`) VALUES
('1','App\\Models\\User','2','nabdh-app','58ba18692f8d0b62977b1d9f5327b1b747f2b11be57d004f98040184216e5ad7','[\"*\"]',NULL,NULL,'2026-05-26 08:15:26','2026-05-26 08:15:26'),
('2','App\\Models\\User','2','nabdh-app','c67f514695425a30d0e73dc4360f71ee0decaa15c089ad9c181f8660a2a9b169','[\"*\"]',NULL,NULL,'2026-05-26 08:33:23','2026-05-26 08:33:23'),
('3','App\\Models\\User','2','nabdh-app','1dcec43cb54eb096e3a896acbfec8c0ab72ee419deda823301a3c78e9677b6bd','[\"*\"]',NULL,NULL,'2026-05-26 08:37:55','2026-05-26 08:37:55'),
('4','App\\Models\\User','2','nabdh-app','1cc7834ae781b43bda2e7ebce417bd5771fb007d82e5c3f4888feabf6cb4860c','[\"*\"]','2026-05-26 08:44:34',NULL,'2026-05-26 08:44:22','2026-05-26 08:44:34'),
('6','App\\Models\\User','2','nabdh-app','be0de74e3649467bb9edac5a4af2e602707001c7b3b9f1554967bd6a9632c4b5','[\"*\"]','2026-05-26 09:17:47',NULL,'2026-05-26 09:17:07','2026-05-26 09:17:47'),
('7','App\\Models\\User','2','nabdh-app','c11161444e546542f5e0e942fe46b637c95a9f347df61bc967d47ceae5e59c15','[\"*\"]','2026-05-26 09:23:13',NULL,'2026-05-26 09:22:19','2026-05-26 09:23:13'),
('8','App\\Models\\User','2','nabdh-app','09b14c6ff5042bb91e56d7adb7917d810101c86ae8aea993c6c506bb83d0e759','[\"*\"]','2026-05-26 09:27:00',NULL,'2026-05-26 09:25:58','2026-05-26 09:27:00'),
('9','App\\Models\\User','2','nabdh-app','aa2ddfdb5593947092adc5563ebff91d770bbf855cdb66fe3f50f6176464fa92','[\"*\"]',NULL,NULL,'2026-05-26 09:32:30','2026-05-26 09:32:30'),
('10','App\\Models\\User','2','nabdh-app','459072f594e23005c29bf450b7d63e5f88707cf94d1a83ed9c77633b67bb7a14','[\"*\"]','2026-05-26 09:53:40',NULL,'2026-05-26 09:51:43','2026-05-26 09:53:40'),
('11','App\\Models\\User','2','nabdh-app','9f5fd4e68dbf04edbb364c97442d7d8f21f5d7d11dd5ee48e77bafcc7df75283','[\"*\"]','2026-05-26 10:03:45',NULL,'2026-05-26 10:03:11','2026-05-26 10:03:45'),
('12','App\\Models\\User','2','nabdh-app','936fac04ad3f8bda8989137903732d7a973d0e57ad33aa25b15a2fa3426b7fcd','[\"*\"]','2026-05-26 10:09:35',NULL,'2026-05-26 10:07:49','2026-05-26 10:09:35'),
('13','App\\Models\\User','2','nabdh-app','3979191bab0e917751d2899c1630efe57c26ea6fbe8e7de76db6cfe709943166','[\"*\"]','2026-05-26 10:14:22',NULL,'2026-05-26 10:11:39','2026-05-26 10:14:22'),
('14','App\\Models\\User','2','nabdh-app','74e5d76794207fd18db6b86e68a93a55053f27f3420144daeb55d0179961b713','[\"*\"]','2026-05-26 10:18:05',NULL,'2026-05-26 10:17:59','2026-05-26 10:18:05'),
('15','App\\Models\\User','2','nabdh-app','3008d0392137bd89a4a25dceaecf28b435ad684b38d4ec7f06e43765f64bb6ae','[\"*\"]',NULL,NULL,'2026-05-26 10:44:29','2026-05-26 10:44:29'),
('16','App\\Models\\User','2','nabdh-app','7ee68170752388fdf2d37da08bd8b04366eaf0f9ed80a4c3addb67ea66402cb8','[\"*\"]',NULL,NULL,'2026-05-26 10:47:40','2026-05-26 10:47:40'),
('17','App\\Models\\User','2','nabdh-app','db63270c790d1c460ce7ace203783a57fcb0d8c47f5167c17a27df12d349e61f','[\"*\"]',NULL,NULL,'2026-05-26 10:47:47','2026-05-26 10:47:47'),
('18','App\\Models\\User','2','nabdh-app','f7f92b0efdc310e10f4e97e1817a63d4bfaca3fe78f893e711b453dce9c63877','[\"*\"]',NULL,NULL,'2026-05-26 10:48:08','2026-05-26 10:48:08'),
('19','App\\Models\\User','2','nabdh-app','7939cbe66d41b6f498d63c16b8cf6080b184810d5be60ff2d1298534362b207e','[\"*\"]','2026-05-26 10:53:14',NULL,'2026-05-26 10:49:52','2026-05-26 10:53:14'),
('20','App\\Models\\User','2','nabdh-app','31ecad9df8f585e7fa7bc711cadbb4f560d9356cbb21d8c33db23b43b881461b','[\"*\"]','2026-05-26 13:06:02',NULL,'2026-05-26 13:02:22','2026-05-26 13:06:02'),
('21','App\\Models\\User','2','nabdh-app','b1a283a61970dc4ed0b01ee736876a442d3e77ccc9542131b693fd3168c8f68c','[\"*\"]','2026-05-26 13:45:41',NULL,'2026-05-26 13:45:18','2026-05-26 13:45:41'),
('22','App\\Models\\User','2','nabdh-app','de30e40c1ac8881a7ac971082dbd447d2d7834a8dbde9764099f947b0b9aeb94','[\"*\"]','2026-05-26 14:04:43',NULL,'2026-05-26 13:58:22','2026-05-26 14:04:43'),
('24','App\\Models\\User','19','nabdh-app','ca572e9aa9f445823f7d0eabce011f32ac248904879468d7b9b473c2aa349266','[\"*\"]','2026-05-26 14:28:34',NULL,'2026-05-26 14:28:09','2026-05-26 14:28:34'),
('25','App\\Models\\User','19','nabdh-app','8e6f1e749f88deccc6e69fd79e173a9f5fd0e286ecef0d5c99fbaa734139f91b','[\"*\"]','2026-05-26 14:39:02',NULL,'2026-05-26 14:34:49','2026-05-26 14:39:02'),
('26','App\\Models\\User','2','nabdh-app','659993803a9035065b6c46f66c15742768f9aa57ff9f20dcd5a70208b50040e4','[\"*\"]','2026-05-26 14:38:46',NULL,'2026-05-26 14:38:12','2026-05-26 14:38:46'),
('27','App\\Models\\User','14','nabdh-app','5a2dde6e54a6bc388cdd79c83e8ed38ca6cac8c9c9520faca95a2fe3f8d71a45','[\"*\"]','2026-05-28 11:08:27',NULL,'2026-05-28 10:16:23','2026-05-28 11:08:27'),
('28','App\\Models\\User','14','nabdh-app','4c4395f17b7cc8da8a32b0af831cfa8fd31aefc3e601abae981e91b7c9bb0bd0','[\"*\"]','2026-05-28 13:03:10',NULL,'2026-05-28 12:56:53','2026-05-28 13:03:10'),
('29','App\\Models\\User','14','nabdh-app','10c23da789f75d0213f5caa09b4f5d237a14b9d19164e9c321f944083a60c3e0','[\"*\"]',NULL,NULL,'2026-05-28 12:57:00','2026-05-28 12:57:00'),
('30','App\\Models\\User','2','nabdh-app','cc3d227b6451d80e24562b54889125a0699c8aee1aa42793bee6a36d089eecb1','[\"*\"]','2026-05-28 13:02:46',NULL,'2026-05-28 12:59:35','2026-05-28 13:02:46'),
('31','App\\Models\\User','14','nabdh-app','12d9cf0c64ab635ba377c82745befa6222142b9f3aeb060203185cea90d13415','[\"*\"]','2026-05-28 14:11:14',NULL,'2026-05-28 14:00:55','2026-05-28 14:11:14'),
('32','App\\Models\\User','2','nabdh-app','5621f68cb8c5f072960dff81eed50a5076cc4117297930e804fc8c9f3a623579','[\"*\"]','2026-05-28 14:04:11',NULL,'2026-05-28 14:02:45','2026-05-28 14:04:11'),
('33','App\\Models\\User','2','nabdh-app','983d3c19fd829b2353f18e0510fe63375dc80a2da4a004c50730e4be6f0f3049','[\"*\"]','2026-05-28 18:04:55',NULL,'2026-05-28 17:57:33','2026-05-28 18:04:55'),
('34','App\\Models\\User','14','nabdh-app','de761ad5bb33819ad144b06d5dc64fff43e53f90ce7cb5db0633754d09961d9d','[\"*\"]','2026-05-28 18:04:49',NULL,'2026-05-28 17:58:43','2026-05-28 18:04:49'),
('35','App\\Models\\User','14','nabdh-app','e7cf4cef4d799d043fac50c6408cef1eda46eb20d9c6f399518009c6888dc9d0','[\"*\"]','2026-05-28 18:14:39',NULL,'2026-05-28 18:10:54','2026-05-28 18:14:39'),
('36','App\\Models\\User','2','nabdh-app','a842254d83d540311f7a298dbdc32cbca101a37e60da5e05940aae914cb2d9e7','[\"*\"]','2026-05-28 18:16:54',NULL,'2026-05-28 18:11:50','2026-05-28 18:16:54'),
('37','App\\Models\\User','14','nabdh-app','92ab90ac076c04a24314769b6f49a7462bbcf7e6c1a5224be8400d8c4e27e079','[\"*\"]','2026-05-28 18:51:57',NULL,'2026-05-28 18:51:26','2026-05-28 18:51:57'),
('38','App\\Models\\User','14','nabdh-app','787c1e6553e58101278edec53729c58b36abc0e433dcec60a92b9b8e324274e0','[\"*\"]','2026-05-28 19:07:40',NULL,'2026-05-28 19:04:09','2026-05-28 19:07:40'),
('39','App\\Models\\User','2','nabdh-app','35fdbffa30f2c6d6a4082b7b139b14e95d0539d82fd361e23ece66b81fceccd9','[\"*\"]','2026-05-28 19:06:32',NULL,'2026-05-28 19:04:43','2026-05-28 19:06:32'),
('40','App\\Models\\User','14','nabdh-app','8ac8570c3253d0708b010387131bd8aed3fb6a215cd123e5c4a99a7c68641f68','[\"*\"]','2026-05-28 19:22:12',NULL,'2026-05-28 19:12:28','2026-05-28 19:22:12'),
('41','App\\Models\\User','2','nabdh-app','b71f497b983919839f0e098efc40fa92652693a8894dce754e52f6305807f01a','[\"*\"]','2026-05-28 19:16:36',NULL,'2026-05-28 19:12:46','2026-05-28 19:16:36'),
('42','App\\Models\\User','14','nabdh-app','3da9ef9c2658f0378dd5b8c4bbd5850a2d9997788f24dfc21789fa1944212ca3','[\"*\"]','2026-05-28 19:45:59',NULL,'2026-05-28 19:45:18','2026-05-28 19:45:59'),
('43','App\\Models\\User','2','nabdh-app','2ce9933bd6e9d65b699088ac8aa687b52f7306c546c9d0101c36b20bd7bd18fe','[\"*\"]','2026-05-28 19:46:41',NULL,'2026-05-28 19:46:12','2026-05-28 19:46:41'),
('44','App\\Models\\User','14','nabdh-app','33a1341c00d958888bd6dfaa50b28a34fc16d44ed1f4dd7681fd426716979e45','[\"*\"]','2026-05-28 20:02:01',NULL,'2026-05-28 19:52:28','2026-05-28 20:02:01'),
('45','App\\Models\\User','2','nabdh-app','1288a88de21a993ef5ffee28c79e0d425626575044efd073d77b57115ab0db2d','[\"*\"]','2026-05-28 19:54:32',NULL,'2026-05-28 19:54:06','2026-05-28 19:54:32'),
('46','App\\Models\\User','19','nabdh-app','69d1c990c5f3a45aa6649da83337720c6946b6d4fac4432e1fab6b8fb41a8c76','[\"*\"]','2026-06-02 05:20:28',NULL,'2026-06-02 05:12:49','2026-06-02 05:20:28'),
('47','App\\Models\\User','2','nabdh-app','5c360d6d8b0f0cf3d11b0c0e94cd3a724fa121a3eef4156758e7811b3a36bb71','[\"*\"]','2026-06-02 05:16:49',NULL,'2026-06-02 05:14:59','2026-06-02 05:16:49'),
('48','App\\Models\\User','19','nabdh-app','dbd46ff433e9244f1cb5fa42eddd8ff0379a40ac4611e98f0b26f088cc604030','[\"*\"]','2026-06-02 05:26:44',NULL,'2026-06-02 05:26:43','2026-06-02 05:26:44'),
('49','App\\Models\\User','2','nabdh-app','269686df6210239fee96bf28ba56a4b60dd4413ef45989f222bfce015da2890f','[\"*\"]','2026-06-02 05:41:00',NULL,'2026-06-02 05:27:15','2026-06-02 05:41:00'),
('50','App\\Models\\User','19','nabdh-app','ef64c6f5744f8e55012363cb5da713b31bc08ce6669ff37ade9fe9cf08fb819f','[\"*\"]','2026-06-02 05:31:15',NULL,'2026-06-02 05:28:31','2026-06-02 05:31:15'),
('51','App\\Models\\User','19','nabdh-app','21a142093fa2444076805a128e021a202f5d9aae710e1e6b7f9feaf41904bd78','[\"*\"]','2026-06-02 05:37:19',NULL,'2026-06-02 05:36:51','2026-06-02 05:37:19');

DROP TABLE IF EXISTS `prescriptions`;
CREATE TABLE `prescriptions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `appointment_id` bigint(20) unsigned DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `notes` text DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `prescriptions_therapist_id_foreign` (`therapist_id`),
  KEY `prescriptions_patient_id_foreign` (`patient_id`),
  KEY `prescriptions_appointment_id_foreign` (`appointment_id`),
  CONSTRAINT `prescriptions_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `prescriptions_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `prescriptions_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `program_exercises`;
CREATE TABLE `program_exercises` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `home_program_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `sets` int(11) DEFAULT NULL,
  `reps` int(11) DEFAULT NULL,
  `duration_seconds` int(11) DEFAULT NULL,
  `frequency` varchar(255) DEFAULT NULL,
  `media_type` enum('none','image','video','file','link') NOT NULL DEFAULT 'none',
  `media_url` varchar(255) DEFAULT NULL,
  `media_thumbnail` varchar(255) DEFAULT NULL,
  `order` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `program_exercises_home_program_id_foreign` (`home_program_id`),
  CONSTRAINT `program_exercises_home_program_id_foreign` FOREIGN KEY (`home_program_id`) REFERENCES `home_programs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `program_exercises` (`id`,`home_program_id`,`title`,`description`,`sets`,`reps`,`duration_seconds`,`frequency`,`media_type`,`media_url`,`media_thumbnail`,`order`,`created_at`,`updated_at`) VALUES
('1','1','تقويم',NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'0','2026-05-28 19:06:28','2026-05-28 19:06:28'),
('2','2','تقويم',NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,'0','2026-05-28 19:15:34','2026-05-28 19:15:34');

DROP TABLE IF EXISTS `program_templates`;
CREATE TABLE `program_templates` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `program_templates_therapist_id_foreign` (`therapist_id`),
  CONSTRAINT `program_templates_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `push_notifications`;
CREATE TABLE `push_notifications` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `type` varchar(255) NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `read_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `push_notifications_user_id_foreign` (`user_id`),
  CONSTRAINT `push_notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `push_notifications` (`id`,`user_id`,`title`,`body`,`type`,`data`,`read_at`,`created_at`,`updated_at`) VALUES
('1','19','رسالة من محمد خلاف','.','new_message','{\"conversation_id\":\"1\"}',NULL,'2026-05-26 14:38:22','2026-05-26 14:38:22'),
('2','19','رسالة من محمد خلاف','..s','new_message','{\"conversation_id\":\"1\"}',NULL,'2026-05-26 14:38:25','2026-05-26 14:38:25'),
('3','7','رسالة من أحمد حسين','.','new_message','{\"conversation_id\":\"2\"}',NULL,'2026-05-28 10:20:15','2026-05-28 10:20:15'),
('4','7','رسالة من أحمد حسين','📎 مرفق','new_message','{\"conversation_id\":\"2\"}',NULL,'2026-05-28 10:21:40','2026-05-28 10:21:40'),
('5','7','رسالة من أحمد حسين','.','new_message','{\"conversation_id\":\"2\"}',NULL,'2026-05-28 12:57:30','2026-05-28 12:57:30'),
('6','2','موعد جديد','لديك طلب موعد جديد من أحمد حسين','new_appointment','{\"appointment_id\":\"17\"}','2026-05-28 14:02:50','2026-05-28 12:58:42','2026-05-28 14:02:50'),
('7','2','موعد جديد','قام أحمد حسين بحجز موعد جديد معك','new_appointment','{\"appointment_id\":\"17\"}','2026-05-28 14:02:50','2026-05-28 12:58:42','2026-05-28 14:02:50'),
('8','10','موعد جديد','لديك طلب موعد جديد من أحمد حسين','new_appointment','{\"appointment_id\":\"18\"}',NULL,'2026-05-28 14:02:05','2026-05-28 14:02:05'),
('9','10','موعد جديد','قام أحمد حسين بحجز موعد جديد معك','new_appointment','{\"appointment_id\":\"18\"}',NULL,'2026-05-28 14:02:05','2026-05-28 14:02:05'),
('10','7','رسالة من أحمد حسين','.','new_message','{\"conversation_id\":\"2\"}',NULL,'2026-05-28 17:59:21','2026-05-28 17:59:21'),
('11','2','رسالة من أحمد حسين','.','new_message','{\"conversation_id\":\"3\"}',NULL,'2026-05-28 17:59:27','2026-05-28 17:59:27'),
('12','2','موعد جديد','لديك طلب موعد جديد من أحمد حسين','new_appointment','{\"appointment_id\":\"19\"}',NULL,'2026-05-28 18:01:31','2026-05-28 18:01:31'),
('13','2','موعد جديد','قام أحمد حسين بحجز موعد جديد معك','new_appointment','{\"appointment_id\":\"19\"}',NULL,'2026-05-28 18:01:31','2026-05-28 18:01:31'),
('14','14','تم تأكيد موعدك','تم تأكيد موعدك مع محمد خلاف','appointment_confirmed','{\"appointment_id\":\"19\"}',NULL,'2026-05-28 18:04:19','2026-05-28 18:04:19'),
('15','14','تم تأكيد موعدك','تم تأكيد موعدك مع محمد خلاف','appointment_confirmed','{\"appointment_id\":\"17\"}',NULL,'2026-05-28 18:04:26','2026-05-28 18:04:26'),
('16','14','انتهت الجلسة','يرجى تقييم جلستك مع المعالج','session_completed','{\"appointment_id\":\"19\"}',NULL,'2026-05-28 18:14:16','2026-05-28 18:14:16'),
('17','19','برنامج منزلي جديد','أرسل لك معالجك برنامجاً منزلياً: تقويم','new_home_program','{\"program_id\":\"1\"}',NULL,'2026-05-28 19:06:28','2026-05-28 19:06:28'),
('18','14','برنامج منزلي جديد','أرسل لك معالجك برنامجاً منزلياً: تقويم','new_home_program','{\"program_id\":\"2\"}',NULL,'2026-05-28 19:15:34','2026-05-28 19:15:34'),
('19','14','رسالة من محمد خلاف','..','new_message','{\"conversation_id\":\"3\"}','2026-05-28 19:45:47','2026-05-28 19:16:29','2026-05-28 19:45:47'),
('20','14','رسالة من محمد خلاف','ظمؤي','new_message','{\"conversation_id\":\"3\"}','2026-05-28 19:45:47','2026-05-28 19:16:33','2026-05-28 19:45:47'),
('21','2','رسالة من أحمد حسين','.','new_message','{\"conversation_id\":\"3\"}',NULL,'2026-05-28 19:52:52','2026-05-28 19:52:52'),
('22','2','رسالة من أحمد حسين','مرحبا','new_message','{\"conversation_id\":\"3\"}',NULL,'2026-05-28 19:57:50','2026-05-28 19:57:50'),
('23','14','هدف علاجي جديد 🎯','أضاف محمد خلاف هدفاً جديداً: المشي','new_goal','{\"goal_id\":\"1\",\"type\":\"new_goal\"}',NULL,'2026-06-02 05:15:47','2026-06-02 05:15:47'),
('24','10','رسالة من محمد','..','new_message','{\"conversation_id\":\"4\"}',NULL,'2026-06-02 05:20:21','2026-06-02 05:20:21'),
('25','14','تحديث على هدفك 📈','هدف \"المشي\": 0% مكتمل','goal_progress','{\"goal_id\":\"1\",\"type\":\"goal_progress\"}',NULL,'2026-06-02 05:27:37','2026-06-02 05:27:37'),
('26','14','هدف علاجي جديد 🎯','أضاف محمد خلاف هدفاً جديداً: المشي','new_goal','{\"goal_id\":\"2\",\"type\":\"new_goal\"}',NULL,'2026-06-02 05:27:48','2026-06-02 05:27:48'),
('27','14','هدف علاجي جديد 🎯','أضاف محمد خلاف هدفاً جديداً: المشي','new_goal','{\"goal_id\":\"3\",\"type\":\"new_goal\"}',NULL,'2026-06-02 05:35:58','2026-06-02 05:35:58'),
('28','14','تحديث على هدفك 📈','هدف \"المشي\": 20% مكتمل','goal_progress','{\"goal_id\":\"1\",\"type\":\"goal_progress\"}',NULL,'2026-06-02 05:36:04','2026-06-02 05:36:04'),
('29','14','تحديث على هدفك 🏆','هدف \"المشي\": 100% مكتمل','goal_progress','{\"goal_id\":\"1\",\"type\":\"goal_progress\"}',NULL,'2026-06-02 05:36:19','2026-06-02 05:36:19'),
('30','14','تحديث على هدفك 📈','هدف \"المشي\": 40% مكتمل','goal_progress','{\"goal_id\":\"2\",\"type\":\"goal_progress\"}',NULL,'2026-06-02 05:40:54','2026-06-02 05:40:54'),
('31','14','تحديث على هدفك 📈','هدف \"المشي\": 40% مكتمل','goal_progress','{\"goal_id\":\"2\",\"type\":\"goal_progress\"}',NULL,'2026-06-02 05:40:58','2026-06-02 05:40:58');

DROP TABLE IF EXISTS `reel_comments`;
CREATE TABLE `reel_comments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `reel_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `body` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reel_comments_reel_id_foreign` (`reel_id`),
  KEY `reel_comments_user_id_foreign` (`user_id`),
  CONSTRAINT `reel_comments_reel_id_foreign` FOREIGN KEY (`reel_id`) REFERENCES `reels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reel_comments_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `reel_likes`;
CREATE TABLE `reel_likes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `reel_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reel_likes_reel_id_user_id_unique` (`reel_id`,`user_id`),
  KEY `reel_likes_user_id_foreign` (`user_id`),
  CONSTRAINT `reel_likes_reel_id_foreign` FOREIGN KEY (`reel_id`) REFERENCES `reels` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reel_likes_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `reel_likes` (`id`,`reel_id`,`user_id`,`created_at`,`updated_at`) VALUES
('3','11','14','2026-05-28 19:16:02','2026-05-28 19:16:02');

DROP TABLE IF EXISTS `reels`;
CREATE TABLE `reels` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `video_url` varchar(255) NOT NULL,
  `thumbnail_url` varchar(255) DEFAULT NULL,
  `duration_seconds` int(11) DEFAULT NULL,
  `views` int(11) NOT NULL DEFAULT 0,
  `likes_count` int(11) NOT NULL DEFAULT 0,
  `comments_count` int(11) NOT NULL DEFAULT 0,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `rejection_reason` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `reels_therapist_id_foreign` (`therapist_id`),
  CONSTRAINT `reels_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `reels` (`id`,`therapist_id`,`title`,`description`,`video_url`,`thumbnail_url`,`duration_seconds`,`views`,`likes_count`,`comments_count`,`status`,`rejection_reason`,`is_active`,`created_at`,`updated_at`) VALUES
('1','1','الحج',NULL,'reels/videos/K67tYdx4N6VXnhclotzMVqOGR5x8CE3mIjMKiuY5.mp4',NULL,NULL,'0','0','0','approved',NULL,'1','2026-05-26 10:08:12','2026-05-26 10:08:21'),
('2','1','حج',NULL,'reels/videos/acQ80EijhUpyP3FMQgP98OK1acVZROhBUnP0maye.mp4',NULL,NULL,'0','1','1','approved',NULL,'1','2026-05-26 10:14:13','2026-05-26 14:03:42'),
('3','2','تمارين تقوية أسفل الظهر','مجموعة تمارين فعالة لتقوية عضلات أسفل الظهر والحد من الآلام المزمنة','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',NULL,'185','386','68','2','approved',NULL,'1','2026-05-26 14:05:30','2026-05-26 14:05:30'),
('4','3','كيف تتعافى من إصابة الركبة؟','شرح مبسط لمراحل تعافي الركبة بعد الإصابة وأهم التمارين في كل مرحلة','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',NULL,'240','147','80','15','approved',NULL,'1','2026-05-26 14:05:30','2026-05-26 14:05:30'),
('5','4','تمارين الرقبة للمكتبيين','تمارين يومية لتخفيف آلام الرقبة الناتجة عن الجلوس الطويل أمام الكمبيوتر','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',NULL,'156','485','38','9','approved',NULL,'1','2026-05-26 14:05:30','2026-05-26 14:05:30'),
('6','5','إعادة تأهيل بعد عملية الغضروف','برنامج التأهيل الكامل بعد جراحة الغضروف - الأسبوع الأول','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',NULL,'312','375','61','15','approved',NULL,'1','2026-05-26 14:05:30','2026-05-26 14:05:30'),
('7','6','تمارين الكتف للرياضيين','تمارين تقوية وتمطيط الكتف للرياضيين والوقاية من الإصابات','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',NULL,'198','395','27','3','approved',NULL,'1','2026-05-26 14:05:30','2026-05-26 14:05:30'),
('8','7','علاج آلام القدم المسطحة','تمارين وإرشادات لتحسين تقوس القدم وتخفيف الآلام','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',NULL,'167','493','29','13','approved',NULL,'1','2026-05-26 14:05:30','2026-05-26 14:05:30'),
('9','8','تمارين التوازن لكبار السن','تمارين آمنة وفعالة لتحسين التوازن والوقاية من السقوط لدى كبار السن','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',NULL,'220','380','58','13','approved',NULL,'1','2026-05-26 14:05:30','2026-05-26 14:05:30'),
('10','9','تمارين تقوية عضلات الحوض','تمارين بيلاتيس لتقوية عضلات قاع الحوض وتحسين الثبات','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',NULL,'195','119','49','10','approved',NULL,'1','2026-05-26 14:05:30','2026-05-26 14:05:30'),
('11','1','حج',NULL,'reels/videos/zZSTWOBS4JvofDqDiLZWoOvKigPNVeXt7Ra38GbC.mp4',NULL,NULL,'0','1','0','approved',NULL,'1','2026-05-28 13:00:08','2026-05-28 19:16:02'),
('12','1','ننن',NULL,'reels/videos/7oxY89yYEcyQD8sxNrAgSz4oRLhhOtw7MxJHAEn3.mp4',NULL,NULL,'0','0','0','approved',NULL,'1','2026-05-28 18:02:53','2026-05-28 18:03:02'),
('13','1','عيد',NULL,'reels/videos/a7YDoJfHP4zpqpim4meI2XLIrcSypEpdLK3kay5v.mp4',NULL,NULL,'0','0','0','approved',NULL,'1','2026-05-28 18:13:37','2026-05-28 18:13:42');

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `patient_id` bigint(20) unsigned NOT NULL,
  `appointment_id` bigint(20) unsigned DEFAULT NULL,
  `rating` tinyint(4) NOT NULL,
  `comment` text DEFAULT NULL,
  `is_visible` tinyint(1) NOT NULL DEFAULT 1,
  `published_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `reviews_appointment_id_unique` (`appointment_id`),
  KEY `reviews_therapist_id_foreign` (`therapist_id`),
  KEY `reviews_patient_id_foreign` (`patient_id`),
  CONSTRAINT `reviews_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `reviews_patient_id_foreign` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE,
  CONSTRAINT `reviews_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `reviews` (`id`,`therapist_id`,`patient_id`,`appointment_id`,`rating`,`comment`,`is_visible`,`published_at`,`created_at`,`updated_at`) VALUES
('1','3','1','3','5','متعاون ومهني جداً','1','2026-05-04 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('2','9','1','4','5','جلسة ممتازة وأخصائي محترف','1','2026-05-02 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('3','8','2','5','4','جلسة ممتازة وأخصائي محترف','1','2026-05-21 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('4','9','2','6','4','خدمة ممتازة وبيئة مريحة','1','2026-05-04 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('5','8','2','8','4','تحسن كبير بعد الجلسات','1','2026-04-28 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('6','5','3','9','4','جلسة ممتازة وأخصائي محترف','1','2026-05-20 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('7','3','3','10','5','تحسن كبير بعد الجلسات','1','2026-05-03 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('8','2','4','11','4','جلسة ممتازة وأخصائي محترف','1','2026-05-20 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('9','4','4','12','4','نتائج رائعة، أنصح بشدة','1','2026-05-13 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('10','4','5','13','4','تحسن كبير بعد الجلسات','1','2026-05-15 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('11','6','5','14','5','جلسة ممتازة وأخصائي محترف','1','2026-05-04 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('12','6','5','15','4','خدمة ممتازة وبيئة مريحة','1','2026-05-23 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09'),
('13','3','5','16','5','تحسن كبير بعد الجلسات','1','2026-04-27 14:05:09','2026-05-26 14:05:09','2026-05-26 14:05:09');

DROP TABLE IF EXISTS `session_notes`;
CREATE TABLE `session_notes` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` bigint(20) unsigned NOT NULL,
  `subjective` text DEFAULT NULL,
  `objective` text DEFAULT NULL,
  `assessment` text DEFAULT NULL,
  `plan` text DEFAULT NULL,
  `pain_scale` int(11) DEFAULT NULL,
  `session_number` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `session_notes_appointment_id_foreign` (`appointment_id`),
  CONSTRAINT `session_notes_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `session_notes` (`id`,`appointment_id`,`subjective`,`objective`,`assessment`,`plan`,`pain_scale`,`session_number`,`created_at`,`updated_at`) VALUES
('1','19',NULL,NULL,NULL,NULL,'5',NULL,'2026-05-28 18:14:16','2026-05-28 18:14:24');

DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `sessions` (`id`,`user_id`,`ip_address`,`user_agent`,`payload`,`last_activity`) VALUES
('ARWlOzwnldQu38mhn6RTust40uX6agrX1OYDhMi3',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiV1NkbFlGR1dETU1hQmFZbVFUTjRTYWJCUGpoRWdFMTFqdDlrczg4eSI7czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7czo1OiJyb3V0ZSI7czo3OiJsYW5kaW5nIjt9fQ==','1780344531'),
('bxqwuF4g0NU2nCCtcaM5La0LcST3E0MBdgNJmGLK',NULL,'192.168.1.16','Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36','YTozOntzOjY6Il90b2tlbiI7czo0MDoiUkhOa1NiM1NZNXlxWXcyVm1XVm9Wand2SDJnUjZZVmJNSGV1RWQzayI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHA6Ly8xOTIuMTY4LjEuMTM6ODAwMCI7czo1OiJyb3V0ZSI7czo3OiJsYW5kaW5nIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==','1780344693'),
('OcFQsGZMvTqhpfdgO2FlrN5S352o7IQOxbEtPbVw',NULL,'192.168.1.13','curl/8.11.0','YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ0hoRWthUEZmaHo4Ykk3MG9IY1o0bFlRS0FJSVhMWXlPaGVQRE04OSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjQ6Imh0dHA6Ly8xOTIuMTY4LjEuMTM6ODAwMCI7czo1OiJyb3V0ZSI7czo3OiJsYW5kaW5nIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==','1780344501'),
('r6Uk1rvMLMjuuRvRRgeZarfrXq9I718o7jQDkvtf',NULL,'127.0.0.1','curl/8.11.0','YTozOntzOjY6Il90b2tlbiI7czo0MDoieFoxd3pMbGRpOHpoNGZ1aUJzNWRnM3g0Wm1CRHkxRTA5N21xMnVoeSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7czo1OiJyb3V0ZSI7czo3OiJsYW5kaW5nIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==','1780344500'),
('won8xLOXE36x4SgnvpP6WvUJAUpFTDu2VkwkjQz4','1','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoieGQwaUlmS0cwT3FyN3M5T2J0a0pqclFGQlA0emMxSGtBUGpQakdOViI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9hZG1pbiI7czo1OiJyb3V0ZSI7czoxNToiYWRtaW4uZGFzaGJvYXJkIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czozOiJ1cmwiO2E6MDp7fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==','1780378958');

DROP TABLE IF EXISTS `specializations`;
CREATE TABLE `specializations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name_ar` varchar(255) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `specializations` (`id`,`name_ar`,`name_en`,`icon`,`is_active`,`created_at`,`updated_at`) VALUES
('1','علاج طبيعي عام','General Physical Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('2','علاج عظام ومفاصل','Orthopedic Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('3','علاج أعصاب','Neurological Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('4','علاج رياضي','Sports Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('5','علاج العمود الفقري','Spine Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('6','علاج حوض وأرضية الحوض','Pelvic Floor Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('7','علاج وظيفي','Occupational Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('8','علاج أطفال','Pediatric Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('9','إعادة التأهيل بعد الجراحة','Post-Surgical Rehabilitation',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('10','علاج سرطان','Oncology Rehabilitation',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('11','علاج قلب وأوعية','Cardiopulmonary Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('12','علاج شيخوخة','Geriatric Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('13','دراما العلاج النفسي الحركي','Psychomotor Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51'),
('14','التأهيل اليدوي','Hand Therapy',NULL,'1','2026-05-25 15:19:51','2026-05-25 15:19:51');

DROP TABLE IF EXISTS `therapist_certifications`;
CREATE TABLE `therapist_certifications` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `issuing_organization` varchar(255) DEFAULT NULL,
  `issue_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `credential_id` varchar(255) DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `therapist_certifications_therapist_id_foreign` (`therapist_id`),
  CONSTRAINT `therapist_certifications_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `therapist_documents`;
CREATE TABLE `therapist_documents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `type` enum('license','id_card','certificate','other') NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `file_size` varchar(255) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `rejection_reason` varchar(255) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `therapist_documents_therapist_id_foreign` (`therapist_id`),
  CONSTRAINT `therapist_documents_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `therapist_educations`;
CREATE TABLE `therapist_educations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `degree` varchar(255) NOT NULL,
  `institution` varchar(255) NOT NULL,
  `field_of_study` varchar(255) DEFAULT NULL,
  `graduation_year` year(4) DEFAULT NULL,
  `certificate_file` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `therapist_educations_therapist_id_foreign` (`therapist_id`),
  CONSTRAINT `therapist_educations_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `therapist_languages`;
CREATE TABLE `therapist_languages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `language` varchar(255) NOT NULL,
  `proficiency` enum('basic','conversational','fluent','native') NOT NULL DEFAULT 'fluent',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `therapist_languages_therapist_id_foreign` (`therapist_id`),
  CONSTRAINT `therapist_languages_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `therapist_languages` (`id`,`therapist_id`,`language`,`proficiency`,`created_at`,`updated_at`) VALUES
('1','2','العربية','native','2026-05-26 14:04:32','2026-05-26 14:04:32'),
('2','2','الإنجليزية','fluent','2026-05-26 14:04:32','2026-05-26 14:04:32'),
('3','3','العربية','native','2026-05-26 14:04:32','2026-05-26 14:04:32'),
('4','3','الإنجليزية','fluent','2026-05-26 14:04:32','2026-05-26 14:04:32'),
('5','4','العربية','native','2026-05-26 14:04:33','2026-05-26 14:04:33'),
('6','4','الإنجليزية','fluent','2026-05-26 14:04:33','2026-05-26 14:04:33'),
('7','5','العربية','native','2026-05-26 14:04:33','2026-05-26 14:04:33'),
('8','5','الإنجليزية','fluent','2026-05-26 14:04:33','2026-05-26 14:04:33'),
('9','6','العربية','native','2026-05-26 14:04:33','2026-05-26 14:04:33'),
('10','6','الإنجليزية','fluent','2026-05-26 14:04:33','2026-05-26 14:04:33'),
('11','7','العربية','native','2026-05-26 14:04:34','2026-05-26 14:04:34'),
('12','7','الإنجليزية','fluent','2026-05-26 14:04:34','2026-05-26 14:04:34'),
('13','8','العربية','native','2026-05-26 14:04:34','2026-05-26 14:04:34'),
('14','8','الإنجليزية','fluent','2026-05-26 14:04:34','2026-05-26 14:04:34'),
('15','9','العربية','native','2026-05-26 14:04:34','2026-05-26 14:04:34'),
('16','9','الإنجليزية','fluent','2026-05-26 14:04:34','2026-05-26 14:04:34');

DROP TABLE IF EXISTS `therapist_schedules`;
CREATE TABLE `therapist_schedules` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `clinic_id` bigint(20) unsigned DEFAULT NULL,
  `type` enum('in_person','online') NOT NULL DEFAULT 'in_person',
  `day_of_week` tinyint(4) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `slot_duration` int(11) NOT NULL DEFAULT 60,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `therapist_schedules_therapist_id_foreign` (`therapist_id`),
  KEY `therapist_schedules_clinic_id_foreign` (`clinic_id`),
  CONSTRAINT `therapist_schedules_clinic_id_foreign` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`) ON DELETE SET NULL,
  CONSTRAINT `therapist_schedules_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `therapist_schedules` (`id`,`therapist_id`,`clinic_id`,`type`,`day_of_week`,`start_time`,`end_time`,`slot_duration`,`is_active`,`created_at`,`updated_at`) VALUES
('1','2',NULL,'in_person','4','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('2','2',NULL,'online','4','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('3','2',NULL,'in_person','0','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('4','2',NULL,'online','0','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('5','2',NULL,'in_person','2','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('6','2',NULL,'online','2','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('7','2',NULL,'online','1','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('8','2',NULL,'in_person','1','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('9','2',NULL,'in_person','3','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('10','2',NULL,'online','3','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('11','3',NULL,'online','0','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('12','3',NULL,'in_person','0','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('13','3',NULL,'in_person','1','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('14','3',NULL,'in_person','1','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('15','3',NULL,'online','4','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('16','3',NULL,'online','4','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('17','3',NULL,'in_person','2','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('18','3',NULL,'in_person','2','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('19','4',NULL,'in_person','4','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('20','4',NULL,'in_person','4','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('21','4',NULL,'in_person','3','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('22','4',NULL,'online','3','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('23','4',NULL,'in_person','2','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('24','4',NULL,'in_person','2','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('25','4',NULL,'online','1','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('26','4',NULL,'in_person','1','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('27','5',NULL,'online','0','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('28','5',NULL,'online','0','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('29','5',NULL,'online','3','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('30','5',NULL,'in_person','3','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('31','5',NULL,'online','1','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('32','5',NULL,'online','1','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('33','5',NULL,'online','4','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('34','5',NULL,'in_person','4','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('35','5',NULL,'in_person','2','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('36','5',NULL,'online','2','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('37','6',NULL,'online','4','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('38','6',NULL,'in_person','4','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('39','6',NULL,'online','1','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('40','6',NULL,'online','1','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('41','6',NULL,'in_person','2','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('42','6',NULL,'online','2','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('43','6',NULL,'online','3','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('44','6',NULL,'online','3','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('45','6',NULL,'online','0','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('46','6',NULL,'in_person','0','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('47','7',NULL,'online','2','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('48','7',NULL,'online','2','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('49','7',NULL,'in_person','4','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('50','7',NULL,'online','4','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('51','7',NULL,'in_person','1','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('52','7',NULL,'in_person','1','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('53','8',NULL,'in_person','3','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('54','8',NULL,'in_person','3','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('55','8',NULL,'online','0','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('56','8',NULL,'online','0','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('57','8',NULL,'online','1','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('58','8',NULL,'in_person','1','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('59','8',NULL,'in_person','2','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('60','8',NULL,'in_person','2','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('61','9',NULL,'in_person','0','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('62','9',NULL,'online','0','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('63','9',NULL,'online','2','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('64','9',NULL,'in_person','2','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('65','9',NULL,'in_person','4','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('66','9',NULL,'online','4','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('67','9',NULL,'in_person','3','09:00:00','13:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('68','9',NULL,'in_person','3','16:00:00','20:00:00','60','1','2026-05-26 14:04:46','2026-05-26 14:04:46'),
('69','1',NULL,'online','0','09:00:00','18:00:00','60','1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('70','1','1','in_person','0','09:00:00','14:00:00','60','1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('71','1',NULL,'online','1','09:00:00','18:00:00','60','1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('72','1','1','in_person','1','09:00:00','14:00:00','60','1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('73','1',NULL,'online','2','09:00:00','18:00:00','60','1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('74','1','1','in_person','2','09:00:00','14:00:00','60','1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('75','1',NULL,'online','3','09:00:00','18:00:00','60','1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('76','1','1','in_person','3','09:00:00','14:00:00','60','1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('77','1',NULL,'online','4','09:00:00','18:00:00','60','1','2026-05-28 11:00:32','2026-05-28 11:00:32'),
('78','1','1','in_person','4','09:00:00','14:00:00','60','1','2026-05-28 11:00:32','2026-05-28 11:00:32');

DROP TABLE IF EXISTS `therapist_specializations`;
CREATE TABLE `therapist_specializations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `specialization_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `therapist_specializations_therapist_id_foreign` (`therapist_id`),
  KEY `therapist_specializations_specialization_id_foreign` (`specialization_id`),
  CONSTRAINT `therapist_specializations_specialization_id_foreign` FOREIGN KEY (`specialization_id`) REFERENCES `specializations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `therapist_specializations_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `therapist_specializations` (`id`,`therapist_id`,`specialization_id`,`created_at`,`updated_at`) VALUES
('1','1','7',NULL,NULL),
('2','2','1',NULL,NULL),
('3','2','2',NULL,NULL),
('4','2','5',NULL,NULL),
('5','3','4',NULL,NULL),
('6','3','9',NULL,NULL),
('7','4','7',NULL,NULL),
('8','4','8',NULL,NULL),
('9','5','3',NULL,NULL),
('10','5','12',NULL,NULL),
('11','6','6',NULL,NULL),
('12','7','1',NULL,NULL),
('13','7','14',NULL,NULL),
('14','8','11',NULL,NULL),
('15','8','10',NULL,NULL),
('16','9','4',NULL,NULL),
('17','9','2',NULL,NULL),
('18','9','9',NULL,NULL);

DROP TABLE IF EXISTS `therapist_unavailabilities`;
CREATE TABLE `therapist_unavailabilities` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `date` date NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `therapist_unavailabilities_therapist_id_foreign` (`therapist_id`),
  CONSTRAINT `therapist_unavailabilities_therapist_id_foreign` FOREIGN KEY (`therapist_id`) REFERENCES `therapists` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS `therapists`;
CREATE TABLE `therapists` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `full_name_en` varchar(255) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `bio_en` text DEFAULT NULL,
  `years_experience` int(11) NOT NULL DEFAULT 0,
  `title` varchar(255) DEFAULT NULL,
  `gender` enum('male','female') DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `degree` varchar(255) DEFAULT NULL,
  `is_approved` tinyint(1) NOT NULL DEFAULT 0,
  `is_verified` tinyint(1) NOT NULL DEFAULT 0,
  `approved_at` timestamp NULL DEFAULT NULL,
  `accepts_online` tinyint(1) NOT NULL DEFAULT 0,
  `accepts_in_person` tinyint(1) NOT NULL DEFAULT 1,
  `online_session_price` decimal(8,2) DEFAULT NULL,
  `in_person_session_price` decimal(8,2) DEFAULT NULL,
  `session_duration` int(11) NOT NULL DEFAULT 60,
  `rating_average` decimal(3,2) NOT NULL DEFAULT 0.00,
  `rating_count` int(11) NOT NULL DEFAULT 0,
  `total_patients` int(11) NOT NULL DEFAULT 0,
  `total_sessions` int(11) NOT NULL DEFAULT 0,
  `is_featured` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `therapists_user_id_foreign` (`user_id`),
  CONSTRAINT `therapists_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `therapists` (`id`,`user_id`,`full_name`,`full_name_en`,`avatar`,`bio`,`bio_en`,`years_experience`,`title`,`gender`,`latitude`,`longitude`,`city`,`degree`,`is_approved`,`is_verified`,`approved_at`,`accepts_online`,`accepts_in_person`,`online_session_price`,`in_person_session_price`,`session_duration`,`rating_average`,`rating_count`,`total_patients`,`total_sessions`,`is_featured`,`created_at`,`updated_at`) VALUES
('1','2','محمد خلاف',NULL,'avatars/therapists/uv1GtnzMzqqD3dDL2M5XQ2U52ELye0t6UU3sEBLS.jpg','معالج',NULL,'5','معالج وظيفي','male','31.90380000','35.20340000','رام الله','بكالوريوس','1','0','2026-05-26 09:28:25','0','1',NULL,NULL,'60','0.00','0','0','0','0','2026-05-26 09:26:33','2026-06-02 05:23:38'),
('2','6','د. سارة الأحمد',NULL,NULL,'متخصصة في علاج إصابات العمود الفقري والمفاصل مع خبرة 8 سنوات في إعادة التأهيل',NULL,'8','أخصائية علاج طبيعي','female','32.22110000','35.25440000','نابلس','ماجستير','1','0',NULL,'0','1',NULL,NULL,'60','4.00','1','0','0','1','2026-05-26 14:04:32','2026-06-02 05:23:38'),
('3','7','أ. يوسف ناصر',NULL,NULL,'متخصص في العلاج الرياضي وتأهيل الرياضيين بعد الإصابات',NULL,'5','معالج طبيعي','male','31.53260000','35.09980000','الخليل','بكالوريوس','1','0',NULL,'0','1',NULL,NULL,'60','5.00','3','0','0','0','2026-05-26 14:04:32','2026-06-02 05:23:38'),
('4','8','د. منى حسين',NULL,NULL,'خبرة واسعة في علاج الأطفال وتأهيلهم الحركي والوظيفي',NULL,'10','أخصائية علاج وظيفي','female','32.46200000','35.29830000','جنين','دكتوراه','1','0',NULL,'0','1',NULL,NULL,'60','4.00','2','0','0','1','2026-05-26 14:04:33','2026-06-02 05:23:38'),
('5','9','أ. خالد إبراهيم',NULL,NULL,'متخصص في علاج إصابات الأعصاب والسكتة الدماغية وشلل الأطفال',NULL,'7','أخصائي علاج أعصاب','male','31.70540000','35.20240000','بيت لحم','ماجستير','1','0',NULL,'0','1',NULL,NULL,'60','4.00','1','0','0','0','2026-05-26 14:04:33','2026-06-02 05:23:38'),
('6','10','د. رنا المصري',NULL,NULL,'متخصصة في علاج مشاكل أرضية الحوض لدى النساء ما قبل وبعد الولادة',NULL,'6','أخصائية حوض وأرضية الحوض','female','31.85670000','35.46090000','أريحا','ماجستير','1','0',NULL,'0','1',NULL,NULL,'60','4.50','2','0','0','0','2026-05-26 14:04:33','2026-06-02 05:23:38'),
('7','11','أ. عمر شحادة',NULL,NULL,'يقدم خدمات العلاج الطبيعي الشاملة لمختلف الحالات',NULL,'4','معالج طبيعي عام','male','32.31000000','35.02800000','طولكرم','بكالوريوس','1','0',NULL,'0','1',NULL,NULL,'60','0.00','0','0','0','0','2026-05-26 14:04:34','2026-06-02 05:23:38'),
('8','12','د. ليلى عبد الرحمن',NULL,NULL,'متخصصة في إعادة تأهيل مرضى القلب وأمراض الأوعية الدموية',NULL,'9','أخصائية علاج القلب','female','32.18920000','34.97060000','قلقيلية','دكتوراه','1','0',NULL,'0','1',NULL,NULL,'60','4.00','2','0','0','1','2026-05-26 14:04:34','2026-06-02 05:23:38'),
('9','13','أ. باسم قاسم',NULL,NULL,'أخصائي معتمد في الطب الرياضي وعلاج إصابات كرة القدم',NULL,'6','معالج طبيعي رياضي','male','31.95000000','35.25000000','البيرة','ماجستير','1','0',NULL,'0','1',NULL,NULL,'60','4.50','2','0','0','0','2026-05-26 14:04:34','2026-06-02 05:23:38');

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `phone` varchar(20) NOT NULL,
  `phone_country_code` varchar(5) NOT NULL DEFAULT '+970',
  `otp` varchar(6) DEFAULT NULL,
  `otp_expires_at` timestamp NULL DEFAULT NULL,
  `type` enum('therapist','patient','admin') NOT NULL DEFAULT 'patient',
  `password` varchar(255) DEFAULT NULL,
  `fcm_token` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `phone_verified_at` timestamp NULL DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_phone_unique` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `users` (`id`,`phone`,`phone_country_code`,`otp`,`otp_expires_at`,`type`,`password`,`fcm_token`,`is_active`,`phone_verified_at`,`remember_token`,`created_at`,`updated_at`) VALUES
('1','599000000','+970',NULL,NULL,'admin','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,'1','2026-05-26 12:53:40',NULL,'2026-05-25 15:19:51','2026-05-28 10:12:40'),
('2','594513978','+972',NULL,NULL,'therapist','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a','fE7K0-iSQTig1NkuJog3xy:APA91bF5bEXiuZ-2IfFKVEaN5_t1TM344rPWMMJc5wfTBtZ3-YQuCPsR5C9u5dwodhiXm2A0AJCXOI3ZSQH0YxLcQ2NOU8njb3afGZZj0v9I50JyF97ZH0U','1','2026-05-26 08:44:21',NULL,'2026-05-26 07:58:12','2026-06-02 05:35:38'),
('6','591000001','+972',NULL,NULL,'therapist','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:04:32',NULL,'2026-05-26 14:04:32','2026-06-02 05:13:34'),
('7','591000002','+972',NULL,NULL,'therapist','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:04:32',NULL,'2026-05-26 14:04:32','2026-06-02 05:13:34'),
('8','591000003','+972',NULL,NULL,'therapist','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:04:33',NULL,'2026-05-26 14:04:33','2026-06-02 05:13:34'),
('9','591000004','+972',NULL,NULL,'therapist','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:04:33',NULL,'2026-05-26 14:04:33','2026-06-02 05:13:34'),
('10','591000005','+972',NULL,NULL,'therapist','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:04:33',NULL,'2026-05-26 14:04:33','2026-06-02 05:13:34'),
('11','591000006','+972',NULL,NULL,'therapist','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:04:34',NULL,'2026-05-26 14:04:34','2026-06-02 05:13:34'),
('12','591000007','+972',NULL,NULL,'therapist','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:04:34',NULL,'2026-05-26 14:04:34','2026-06-02 05:13:34'),
('13','591000008','+972',NULL,NULL,'therapist','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:04:34',NULL,'2026-05-26 14:04:34','2026-06-02 05:13:34'),
('14','592000001','+972',NULL,NULL,'patient','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a','e5BWzZ28Ro6yC3AMta3s5I:APA91bG3qtTHSgFeEyd03JJyUPc92KpYchccrjmLR8fHinc6OjHsuRrWwQxKHJbjNKv6ZTTwh4sBptxU172nXbSenFMuULxkzGwRqbLa6DgQ7-6zTIUwa_4','1','2026-05-26 14:05:08',NULL,'2026-05-26 14:05:08','2026-06-02 05:13:34'),
('15','592000002','+972',NULL,NULL,'patient','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:05:08',NULL,'2026-05-26 14:05:08','2026-06-02 05:13:34'),
('16','592000003','+972',NULL,NULL,'patient','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:05:08',NULL,'2026-05-26 14:05:08','2026-06-02 05:13:34'),
('17','592000004','+972',NULL,NULL,'patient','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:05:09',NULL,'2026-05-26 14:05:09','2026-06-02 05:13:34'),
('18','592000005','+972',NULL,NULL,'patient','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a',NULL,'1','2026-05-26 14:05:09',NULL,'2026-05-26 14:05:09','2026-06-02 05:13:34'),
('19','598420090','+972',NULL,NULL,'patient','$2y$12$UvmjBMtSmwkPeMfDQ1hFeeYpj1F6QWDpYRLrBlJaDHAsBN6OZ6d5a','enLuRzgIQ_i6xAfPEZQuDD:APA91bE8gws_Q7MY5TRfJc1FWPctDmjrjZzoLuFe8zXWoPwBCt8cC6-12etjbd1IO9Gm48BQFNnMslAa10O7YxP1I6HtuFoSEbrWNyd1_goJa7uW8z_JqdM','1','2026-05-26 14:28:09',NULL,'2026-05-26 14:27:58','2026-06-02 05:16:56');

SET FOREIGN_KEY_CHECKS=1;
