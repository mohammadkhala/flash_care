-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: nabdh
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `nabdh`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `nabdh` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `nabdh`;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (1,7,1,NULL,'2026-05-01 10:00:00',60,'in_person','confirmed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(2,2,1,NULL,'2026-05-03 15:00:00',60,'in_person','confirmed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(3,3,1,NULL,'2026-05-29 17:00:00',60,'in_person','completed',NULL,NULL,0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(4,9,1,NULL,'2026-05-25 13:00:00',60,'online','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(5,8,2,NULL,'2026-03-31 11:00:00',60,'online','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(6,9,2,NULL,'2026-04-22 10:00:00',60,'online','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(7,9,2,NULL,'2026-04-02 11:00:00',60,'online','confirmed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(8,8,2,NULL,'2026-05-10 16:00:00',60,'in_person','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(9,5,3,NULL,'2026-04-01 13:00:00',60,'online','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(10,3,3,NULL,'2026-05-16 12:00:00',60,'online','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(11,2,4,NULL,'2026-05-20 16:00:00',60,'in_person','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(12,4,4,NULL,'2026-03-28 11:00:00',60,'online','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(13,4,5,NULL,'2026-04-24 13:00:00',60,'online','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(14,6,5,NULL,'2026-05-09 12:00:00',60,'in_person','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(15,6,5,NULL,'2026-04-24 17:00:00',60,'in_person','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(16,3,5,NULL,'2026-04-15 13:00:00',60,'online','completed',NULL,'ألم في الظهر والكتف',0,NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(17,1,1,1,'2026-06-01 09:00:00',60,'in_person','confirmed',NULL,NULL,0,NULL,NULL,NULL,NULL,'2026-05-28 09:58:42','2026-05-28 15:04:26'),(18,6,1,NULL,'2026-06-02 10:00:00',60,'in_person','pending',NULL,NULL,0,NULL,NULL,NULL,NULL,'2026-05-28 11:02:05','2026-05-28 11:02:05'),(19,1,1,1,'2026-06-02 09:00:00',60,'in_person','completed',NULL,NULL,0,NULL,NULL,NULL,NULL,'2026-05-28 15:01:31','2026-05-28 15:14:16');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `articles`
--

DROP TABLE IF EXISTS `articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `articles`
--

LOCK TABLES `articles` WRITE;
/*!40000 ALTER TABLE `articles` DISABLE KEYS */;
/*!40000 ALTER TABLE `articles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assessments`
--

DROP TABLE IF EXISTS `assessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assessments`
--

LOCK TABLES `assessments` WRITE;
/*!40000 ALTER TABLE `assessments` DISABLE KEYS */;
/*!40000 ALTER TABLE `assessments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clinics`
--

DROP TABLE IF EXISTS `clinics`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clinics`
--

LOCK TABLES `clinics` WRITE;
/*!40000 ALTER TABLE `clinics` DISABLE KEYS */;
INSERT INTO `clinics` VALUES (1,1,'عيادة محمد خلاف','شارع الوحدة','الخليل',NULL,NULL,NULL,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(2,2,'عيادة د. سارة الأحمد','شارع الوحدة','رام الله',NULL,NULL,NULL,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(3,3,'عيادة أ. يوسف ناصر','شارع الوحدة','نابلس',NULL,NULL,NULL,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(4,4,'عيادة د. منى حسين','شارع الوحدة','الخليل',NULL,NULL,NULL,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(5,5,'عيادة أ. خالد إبراهيم','شارع الوحدة','بيت لحم',NULL,NULL,NULL,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(6,6,'عيادة د. رنا المصري','شارع الوحدة','رام الله',NULL,NULL,NULL,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(7,7,'عيادة أ. عمر شحادة','شارع الوحدة','جنين',NULL,NULL,NULL,1,'2026-05-28 08:00:33','2026-05-28 08:00:33'),(8,8,'عيادة د. ليلى عبد الرحمن','شارع الوحدة','نابلس',NULL,NULL,NULL,1,'2026-05-28 08:00:33','2026-05-28 08:00:33'),(9,9,'عيادة أ. باسم قاسم','شارع الوحدة','القدس',NULL,NULL,NULL,1,'2026-05-28 08:00:33','2026-05-28 08:00:33');
/*!40000 ALTER TABLE `clinics` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversations`
--

LOCK TABLES `conversations` WRITE;
/*!40000 ALTER TABLE `conversations` DISABLE KEYS */;
INSERT INTO `conversations` VALUES (1,1,6,2,'2026-05-26 11:38:25',0,0,'2026-05-26 11:38:22','2026-05-26 11:38:42'),(2,3,1,6,'2026-05-28 14:59:21',4,0,'2026-05-28 07:20:15','2026-05-28 14:59:21'),(3,1,1,11,'2026-05-28 16:57:50',1,0,'2026-05-28 14:59:26','2026-05-28 16:57:50');
/*!40000 ALTER TABLE `conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exercise_completions`
--

DROP TABLE IF EXISTS `exercise_completions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exercise_completions`
--

LOCK TABLES `exercise_completions` WRITE;
/*!40000 ALTER TABLE `exercise_completions` DISABLE KEYS */;
/*!40000 ALTER TABLE `exercise_completions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `home_programs`
--

DROP TABLE IF EXISTS `home_programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `home_programs`
--

LOCK TABLES `home_programs` WRITE;
/*!40000 ALTER TABLE `home_programs` DISABLE KEYS */;
INSERT INTO `home_programs` VALUES (1,1,6,NULL,'تقويم',NULL,'2026-05-28',NULL,1,'2026-05-28 16:06:28','2026-05-28 16:06:28'),(2,1,1,NULL,'تقويم',NULL,'2026-05-28',NULL,1,'2026-05-28 16:15:34','2026-05-28 16:15:34');
/*!40000 ALTER TABLE `home_programs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint(20) unsigned NOT NULL,
  `sender_id` bigint(20) unsigned NOT NULL,
  `content` text DEFAULT NULL,
  `type` enum('text','image','file','voice','video') NOT NULL DEFAULT 'text',
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
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,1,2,'.','text',NULL,NULL,NULL,NULL,'2026-05-26 11:38:42',0,'2026-05-26 11:38:22','2026-05-26 11:38:42'),(2,1,2,'..s','text',NULL,NULL,NULL,NULL,'2026-05-26 11:38:42',0,'2026-05-26 11:38:25','2026-05-26 11:38:42'),(3,2,14,'.','text',NULL,NULL,NULL,NULL,NULL,0,'2026-05-28 07:20:15','2026-05-28 07:20:15'),(4,2,14,NULL,'file','http://192.168.1.9:8000/storage/messages/1v2yv8nzI4D0goUpBMr9yTkIrnIvkBfItQFkprGl.jpg','Screenshot_٢٠٢٦٠٥٢٨_١٢٢٧٤٢.jpg',NULL,NULL,NULL,0,'2026-05-28 07:21:40','2026-05-28 07:21:40'),(5,2,14,'.','text',NULL,NULL,NULL,NULL,NULL,0,'2026-05-28 09:57:29','2026-05-28 09:57:29'),(6,2,14,'.','text',NULL,NULL,NULL,NULL,NULL,0,'2026-05-28 14:59:21','2026-05-28 14:59:21'),(7,3,14,'.','text',NULL,NULL,NULL,NULL,'2026-05-28 14:59:58',0,'2026-05-28 14:59:26','2026-05-28 14:59:58'),(8,3,2,'..','text',NULL,NULL,NULL,NULL,'2026-05-28 16:16:37',0,'2026-05-28 16:16:29','2026-05-28 16:16:37'),(9,3,2,'ظمؤي','text',NULL,NULL,NULL,NULL,'2026-05-28 16:16:37',0,'2026-05-28 16:16:33','2026-05-28 16:16:37'),(10,3,14,'.','text',NULL,NULL,NULL,NULL,'2026-05-28 16:54:11',0,'2026-05-28 16:52:52','2026-05-28 16:54:11'),(11,3,14,'مرحبا','text',NULL,NULL,NULL,NULL,NULL,0,'2026-05-28 16:57:50','2026-05-28 16:57:50');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_cache_table',1),(3,'0001_01_01_000002_create_jobs_table',1),(4,'2024_01_01_000001_create_users_table',1),(5,'2024_01_01_000002_create_therapists_table',1),(6,'2024_01_01_000003_create_patients_table',1),(7,'2024_01_01_000004_create_specializations_table',1),(8,'2024_01_01_000005_create_therapist_details_table',1),(9,'2024_01_01_000006_create_clinics_and_schedules_table',1),(10,'2024_01_01_000007_create_appointments_table',1),(11,'2024_01_01_000008_create_home_programs_table',1),(12,'2024_01_01_000009_create_messaging_table',1),(13,'2024_01_01_000010_create_reviews_and_reels_table',1),(14,'2024_01_01_000011_create_notifications_table',1),(15,'2024_01_01_000001_create_nabdh_admin_tables',2),(16,'2026_05_26_081449_create_personal_access_tokens_table',3),(17,'2026_05_26_082107_add_degree_to_therapists_table',4),(18,'2026_05_26_093538_create_articles_table',5),(19,'2026_05_26_094841_create_assessments_table',6),(20,'2026_05_26_130849_create_reel_comments_table',7),(21,'2026_05_28_110037_add_family_booking_to_appointments',8),(22,'2026_05_28_110038_create_patient_documents_table',8);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `outcome_measures`
--

DROP TABLE IF EXISTS `outcome_measures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `outcome_measures`
--

LOCK TABLES `outcome_measures` WRITE;
/*!40000 ALTER TABLE `outcome_measures` DISABLE KEYS */;
/*!40000 ALTER TABLE `outcome_measures` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pain_diary`
--

DROP TABLE IF EXISTS `pain_diary`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pain_diary`
--

LOCK TABLES `pain_diary` WRITE;
/*!40000 ALTER TABLE `pain_diary` DISABLE KEYS */;
/*!40000 ALTER TABLE `pain_diary` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_assessments`
--

DROP TABLE IF EXISTS `patient_assessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_assessments`
--

LOCK TABLES `patient_assessments` WRITE;
/*!40000 ALTER TABLE `patient_assessments` DISABLE KEYS */;
/*!40000 ALTER TABLE `patient_assessments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patient_documents`
--

DROP TABLE IF EXISTS `patient_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patient_documents`
--

LOCK TABLES `patient_documents` WRITE;
/*!40000 ALTER TABLE `patient_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `patient_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `patients`
--

DROP TABLE IF EXISTS `patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `patients`
--

LOCK TABLES `patients` WRITE;
/*!40000 ALTER TABLE `patients` DISABLE KEYS */;
INSERT INTO `patients` VALUES (1,14,'أحمد حسين',NULL,NULL,'male','رام الله',NULL,NULL,NULL,NULL,'2026-05-26 11:05:08','2026-05-26 11:05:08'),(2,15,'فاطمة علي',NULL,NULL,'female','نابلس',NULL,NULL,NULL,NULL,'2026-05-26 11:05:08','2026-05-26 11:05:08'),(3,16,'محمود عمر',NULL,NULL,'male','الخليل',NULL,NULL,NULL,NULL,'2026-05-26 11:05:08','2026-05-26 11:05:08'),(4,17,'نور سالم',NULL,NULL,'female','بيت لحم',NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(5,18,'كريم داود',NULL,NULL,'male','جنين',NULL,NULL,NULL,NULL,'2026-05-26 11:05:09','2026-05-26 11:05:09'),(6,19,'محمد',NULL,NULL,'male','الخليل',NULL,NULL,NULL,NULL,'2026-05-26 11:28:33','2026-05-26 11:28:33');
/*!40000 ALTER TABLE `patients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',2,'nabdh-app','58ba18692f8d0b62977b1d9f5327b1b747f2b11be57d004f98040184216e5ad7','[\"*\"]',NULL,NULL,'2026-05-26 05:15:26','2026-05-26 05:15:26'),(2,'App\\Models\\User',2,'nabdh-app','c67f514695425a30d0e73dc4360f71ee0decaa15c089ad9c181f8660a2a9b169','[\"*\"]',NULL,NULL,'2026-05-26 05:33:23','2026-05-26 05:33:23'),(3,'App\\Models\\User',2,'nabdh-app','1dcec43cb54eb096e3a896acbfec8c0ab72ee419deda823301a3c78e9677b6bd','[\"*\"]',NULL,NULL,'2026-05-26 05:37:55','2026-05-26 05:37:55'),(4,'App\\Models\\User',2,'nabdh-app','1cc7834ae781b43bda2e7ebce417bd5771fb007d82e5c3f4888feabf6cb4860c','[\"*\"]','2026-05-26 05:44:34',NULL,'2026-05-26 05:44:22','2026-05-26 05:44:34'),(6,'App\\Models\\User',2,'nabdh-app','be0de74e3649467bb9edac5a4af2e602707001c7b3b9f1554967bd6a9632c4b5','[\"*\"]','2026-05-26 06:17:47',NULL,'2026-05-26 06:17:07','2026-05-26 06:17:47'),(7,'App\\Models\\User',2,'nabdh-app','c11161444e546542f5e0e942fe46b637c95a9f347df61bc967d47ceae5e59c15','[\"*\"]','2026-05-26 06:23:13',NULL,'2026-05-26 06:22:19','2026-05-26 06:23:13'),(8,'App\\Models\\User',2,'nabdh-app','09b14c6ff5042bb91e56d7adb7917d810101c86ae8aea993c6c506bb83d0e759','[\"*\"]','2026-05-26 06:27:00',NULL,'2026-05-26 06:25:58','2026-05-26 06:27:00'),(9,'App\\Models\\User',2,'nabdh-app','aa2ddfdb5593947092adc5563ebff91d770bbf855cdb66fe3f50f6176464fa92','[\"*\"]',NULL,NULL,'2026-05-26 06:32:30','2026-05-26 06:32:30'),(10,'App\\Models\\User',2,'nabdh-app','459072f594e23005c29bf450b7d63e5f88707cf94d1a83ed9c77633b67bb7a14','[\"*\"]','2026-05-26 06:53:40',NULL,'2026-05-26 06:51:43','2026-05-26 06:53:40'),(11,'App\\Models\\User',2,'nabdh-app','9f5fd4e68dbf04edbb364c97442d7d8f21f5d7d11dd5ee48e77bafcc7df75283','[\"*\"]','2026-05-26 07:03:45',NULL,'2026-05-26 07:03:11','2026-05-26 07:03:45'),(12,'App\\Models\\User',2,'nabdh-app','936fac04ad3f8bda8989137903732d7a973d0e57ad33aa25b15a2fa3426b7fcd','[\"*\"]','2026-05-26 07:09:35',NULL,'2026-05-26 07:07:49','2026-05-26 07:09:35'),(13,'App\\Models\\User',2,'nabdh-app','3979191bab0e917751d2899c1630efe57c26ea6fbe8e7de76db6cfe709943166','[\"*\"]','2026-05-26 07:14:22',NULL,'2026-05-26 07:11:39','2026-05-26 07:14:22'),(14,'App\\Models\\User',2,'nabdh-app','74e5d76794207fd18db6b86e68a93a55053f27f3420144daeb55d0179961b713','[\"*\"]','2026-05-26 07:18:05',NULL,'2026-05-26 07:17:59','2026-05-26 07:18:05'),(15,'App\\Models\\User',2,'nabdh-app','3008d0392137bd89a4a25dceaecf28b435ad684b38d4ec7f06e43765f64bb6ae','[\"*\"]',NULL,NULL,'2026-05-26 07:44:29','2026-05-26 07:44:29'),(16,'App\\Models\\User',2,'nabdh-app','7ee68170752388fdf2d37da08bd8b04366eaf0f9ed80a4c3addb67ea66402cb8','[\"*\"]',NULL,NULL,'2026-05-26 07:47:40','2026-05-26 07:47:40'),(17,'App\\Models\\User',2,'nabdh-app','db63270c790d1c460ce7ace203783a57fcb0d8c47f5167c17a27df12d349e61f','[\"*\"]',NULL,NULL,'2026-05-26 07:47:47','2026-05-26 07:47:47'),(18,'App\\Models\\User',2,'nabdh-app','f7f92b0efdc310e10f4e97e1817a63d4bfaca3fe78f893e711b453dce9c63877','[\"*\"]',NULL,NULL,'2026-05-26 07:48:08','2026-05-26 07:48:08'),(19,'App\\Models\\User',2,'nabdh-app','7939cbe66d41b6f498d63c16b8cf6080b184810d5be60ff2d1298534362b207e','[\"*\"]','2026-05-26 07:53:14',NULL,'2026-05-26 07:49:52','2026-05-26 07:53:14'),(20,'App\\Models\\User',2,'nabdh-app','31ecad9df8f585e7fa7bc711cadbb4f560d9356cbb21d8c33db23b43b881461b','[\"*\"]','2026-05-26 10:06:02',NULL,'2026-05-26 10:02:22','2026-05-26 10:06:02'),(21,'App\\Models\\User',2,'nabdh-app','b1a283a61970dc4ed0b01ee736876a442d3e77ccc9542131b693fd3168c8f68c','[\"*\"]','2026-05-26 10:45:41',NULL,'2026-05-26 10:45:18','2026-05-26 10:45:41'),(22,'App\\Models\\User',2,'nabdh-app','de30e40c1ac8881a7ac971082dbd447d2d7834a8dbde9764099f947b0b9aeb94','[\"*\"]','2026-05-26 11:04:43',NULL,'2026-05-26 10:58:22','2026-05-26 11:04:43'),(24,'App\\Models\\User',19,'nabdh-app','ca572e9aa9f445823f7d0eabce011f32ac248904879468d7b9b473c2aa349266','[\"*\"]','2026-05-26 11:28:34',NULL,'2026-05-26 11:28:09','2026-05-26 11:28:34'),(25,'App\\Models\\User',19,'nabdh-app','8e6f1e749f88deccc6e69fd79e173a9f5fd0e286ecef0d5c99fbaa734139f91b','[\"*\"]','2026-05-26 11:39:02',NULL,'2026-05-26 11:34:49','2026-05-26 11:39:02'),(26,'App\\Models\\User',2,'nabdh-app','659993803a9035065b6c46f66c15742768f9aa57ff9f20dcd5a70208b50040e4','[\"*\"]','2026-05-26 11:38:46',NULL,'2026-05-26 11:38:12','2026-05-26 11:38:46'),(27,'App\\Models\\User',14,'nabdh-app','5a2dde6e54a6bc388cdd79c83e8ed38ca6cac8c9c9520faca95a2fe3f8d71a45','[\"*\"]','2026-05-28 08:08:27',NULL,'2026-05-28 07:16:23','2026-05-28 08:08:27'),(28,'App\\Models\\User',14,'nabdh-app','4c4395f17b7cc8da8a32b0af831cfa8fd31aefc3e601abae981e91b7c9bb0bd0','[\"*\"]','2026-05-28 10:03:10',NULL,'2026-05-28 09:56:53','2026-05-28 10:03:10'),(29,'App\\Models\\User',14,'nabdh-app','10c23da789f75d0213f5caa09b4f5d237a14b9d19164e9c321f944083a60c3e0','[\"*\"]',NULL,NULL,'2026-05-28 09:57:00','2026-05-28 09:57:00'),(30,'App\\Models\\User',2,'nabdh-app','cc3d227b6451d80e24562b54889125a0699c8aee1aa42793bee6a36d089eecb1','[\"*\"]','2026-05-28 10:02:46',NULL,'2026-05-28 09:59:35','2026-05-28 10:02:46'),(31,'App\\Models\\User',14,'nabdh-app','12d9cf0c64ab635ba377c82745befa6222142b9f3aeb060203185cea90d13415','[\"*\"]','2026-05-28 11:11:14',NULL,'2026-05-28 11:00:55','2026-05-28 11:11:14'),(32,'App\\Models\\User',2,'nabdh-app','5621f68cb8c5f072960dff81eed50a5076cc4117297930e804fc8c9f3a623579','[\"*\"]','2026-05-28 11:04:11',NULL,'2026-05-28 11:02:45','2026-05-28 11:04:11'),(33,'App\\Models\\User',2,'nabdh-app','983d3c19fd829b2353f18e0510fe63375dc80a2da4a004c50730e4be6f0f3049','[\"*\"]','2026-05-28 15:04:55',NULL,'2026-05-28 14:57:33','2026-05-28 15:04:55'),(34,'App\\Models\\User',14,'nabdh-app','de761ad5bb33819ad144b06d5dc64fff43e53f90ce7cb5db0633754d09961d9d','[\"*\"]','2026-05-28 15:04:49',NULL,'2026-05-28 14:58:43','2026-05-28 15:04:49'),(35,'App\\Models\\User',14,'nabdh-app','e7cf4cef4d799d043fac50c6408cef1eda46eb20d9c6f399518009c6888dc9d0','[\"*\"]','2026-05-28 15:14:39',NULL,'2026-05-28 15:10:54','2026-05-28 15:14:39'),(36,'App\\Models\\User',2,'nabdh-app','a842254d83d540311f7a298dbdc32cbca101a37e60da5e05940aae914cb2d9e7','[\"*\"]','2026-05-28 15:16:54',NULL,'2026-05-28 15:11:50','2026-05-28 15:16:54'),(37,'App\\Models\\User',14,'nabdh-app','92ab90ac076c04a24314769b6f49a7462bbcf7e6c1a5224be8400d8c4e27e079','[\"*\"]','2026-05-28 15:51:57',NULL,'2026-05-28 15:51:26','2026-05-28 15:51:57'),(38,'App\\Models\\User',14,'nabdh-app','787c1e6553e58101278edec53729c58b36abc0e433dcec60a92b9b8e324274e0','[\"*\"]','2026-05-28 16:07:40',NULL,'2026-05-28 16:04:09','2026-05-28 16:07:40'),(39,'App\\Models\\User',2,'nabdh-app','35fdbffa30f2c6d6a4082b7b139b14e95d0539d82fd361e23ece66b81fceccd9','[\"*\"]','2026-05-28 16:06:32',NULL,'2026-05-28 16:04:43','2026-05-28 16:06:32'),(40,'App\\Models\\User',14,'nabdh-app','8ac8570c3253d0708b010387131bd8aed3fb6a215cd123e5c4a99a7c68641f68','[\"*\"]','2026-05-28 16:22:12',NULL,'2026-05-28 16:12:28','2026-05-28 16:22:12'),(41,'App\\Models\\User',2,'nabdh-app','b71f497b983919839f0e098efc40fa92652693a8894dce754e52f6305807f01a','[\"*\"]','2026-05-28 16:16:36',NULL,'2026-05-28 16:12:46','2026-05-28 16:16:36'),(42,'App\\Models\\User',14,'nabdh-app','3da9ef9c2658f0378dd5b8c4bbd5850a2d9997788f24dfc21789fa1944212ca3','[\"*\"]','2026-05-28 16:45:59',NULL,'2026-05-28 16:45:18','2026-05-28 16:45:59'),(43,'App\\Models\\User',2,'nabdh-app','2ce9933bd6e9d65b699088ac8aa687b52f7306c546c9d0101c36b20bd7bd18fe','[\"*\"]','2026-05-28 16:46:41',NULL,'2026-05-28 16:46:12','2026-05-28 16:46:41'),(44,'App\\Models\\User',14,'nabdh-app','33a1341c00d958888bd6dfaa50b28a34fc16d44ed1f4dd7681fd426716979e45','[\"*\"]','2026-05-28 17:02:01',NULL,'2026-05-28 16:52:28','2026-05-28 17:02:01'),(45,'App\\Models\\User',2,'nabdh-app','1288a88de21a993ef5ffee28c79e0d425626575044efd073d77b57115ab0db2d','[\"*\"]','2026-05-28 16:54:32',NULL,'2026-05-28 16:54:06','2026-05-28 16:54:32');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `prescriptions`
--

DROP TABLE IF EXISTS `prescriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `prescriptions`
--

LOCK TABLES `prescriptions` WRITE;
/*!40000 ALTER TABLE `prescriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `prescriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `program_exercises`
--

DROP TABLE IF EXISTS `program_exercises`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `program_exercises`
--

LOCK TABLES `program_exercises` WRITE;
/*!40000 ALTER TABLE `program_exercises` DISABLE KEYS */;
INSERT INTO `program_exercises` VALUES (1,1,'تقويم',NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,0,'2026-05-28 16:06:28','2026-05-28 16:06:28'),(2,2,'تقويم',NULL,NULL,NULL,NULL,NULL,'none',NULL,NULL,0,'2026-05-28 16:15:34','2026-05-28 16:15:34');
/*!40000 ALTER TABLE `program_exercises` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `program_templates`
--

DROP TABLE IF EXISTS `program_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `program_templates`
--

LOCK TABLES `program_templates` WRITE;
/*!40000 ALTER TABLE `program_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `program_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `push_notifications`
--

DROP TABLE IF EXISTS `push_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_notifications`
--

LOCK TABLES `push_notifications` WRITE;
/*!40000 ALTER TABLE `push_notifications` DISABLE KEYS */;
INSERT INTO `push_notifications` VALUES (1,19,'رسالة من محمد خلاف','.','new_message','{\"conversation_id\":\"1\"}',NULL,'2026-05-26 11:38:22','2026-05-26 11:38:22'),(2,19,'رسالة من محمد خلاف','..s','new_message','{\"conversation_id\":\"1\"}',NULL,'2026-05-26 11:38:25','2026-05-26 11:38:25'),(3,7,'رسالة من أحمد حسين','.','new_message','{\"conversation_id\":\"2\"}',NULL,'2026-05-28 07:20:15','2026-05-28 07:20:15'),(4,7,'رسالة من أحمد حسين','📎 مرفق','new_message','{\"conversation_id\":\"2\"}',NULL,'2026-05-28 07:21:40','2026-05-28 07:21:40'),(5,7,'رسالة من أحمد حسين','.','new_message','{\"conversation_id\":\"2\"}',NULL,'2026-05-28 09:57:30','2026-05-28 09:57:30'),(6,2,'موعد جديد','لديك طلب موعد جديد من أحمد حسين','new_appointment','{\"appointment_id\":\"17\"}','2026-05-28 11:02:50','2026-05-28 09:58:42','2026-05-28 11:02:50'),(7,2,'موعد جديد','قام أحمد حسين بحجز موعد جديد معك','new_appointment','{\"appointment_id\":\"17\"}','2026-05-28 11:02:50','2026-05-28 09:58:42','2026-05-28 11:02:50'),(8,10,'موعد جديد','لديك طلب موعد جديد من أحمد حسين','new_appointment','{\"appointment_id\":\"18\"}',NULL,'2026-05-28 11:02:05','2026-05-28 11:02:05'),(9,10,'موعد جديد','قام أحمد حسين بحجز موعد جديد معك','new_appointment','{\"appointment_id\":\"18\"}',NULL,'2026-05-28 11:02:05','2026-05-28 11:02:05'),(10,7,'رسالة من أحمد حسين','.','new_message','{\"conversation_id\":\"2\"}',NULL,'2026-05-28 14:59:21','2026-05-28 14:59:21'),(11,2,'رسالة من أحمد حسين','.','new_message','{\"conversation_id\":\"3\"}',NULL,'2026-05-28 14:59:27','2026-05-28 14:59:27'),(12,2,'موعد جديد','لديك طلب موعد جديد من أحمد حسين','new_appointment','{\"appointment_id\":\"19\"}',NULL,'2026-05-28 15:01:31','2026-05-28 15:01:31'),(13,2,'موعد جديد','قام أحمد حسين بحجز موعد جديد معك','new_appointment','{\"appointment_id\":\"19\"}',NULL,'2026-05-28 15:01:31','2026-05-28 15:01:31'),(14,14,'تم تأكيد موعدك','تم تأكيد موعدك مع محمد خلاف','appointment_confirmed','{\"appointment_id\":\"19\"}',NULL,'2026-05-28 15:04:19','2026-05-28 15:04:19'),(15,14,'تم تأكيد موعدك','تم تأكيد موعدك مع محمد خلاف','appointment_confirmed','{\"appointment_id\":\"17\"}',NULL,'2026-05-28 15:04:26','2026-05-28 15:04:26'),(16,14,'انتهت الجلسة','يرجى تقييم جلستك مع المعالج','session_completed','{\"appointment_id\":\"19\"}',NULL,'2026-05-28 15:14:16','2026-05-28 15:14:16'),(17,19,'برنامج منزلي جديد','أرسل لك معالجك برنامجاً منزلياً: تقويم','new_home_program','{\"program_id\":\"1\"}',NULL,'2026-05-28 16:06:28','2026-05-28 16:06:28'),(18,14,'برنامج منزلي جديد','أرسل لك معالجك برنامجاً منزلياً: تقويم','new_home_program','{\"program_id\":\"2\"}',NULL,'2026-05-28 16:15:34','2026-05-28 16:15:34'),(19,14,'رسالة من محمد خلاف','..','new_message','{\"conversation_id\":\"3\"}','2026-05-28 16:45:47','2026-05-28 16:16:29','2026-05-28 16:45:47'),(20,14,'رسالة من محمد خلاف','ظمؤي','new_message','{\"conversation_id\":\"3\"}','2026-05-28 16:45:47','2026-05-28 16:16:33','2026-05-28 16:45:47'),(21,2,'رسالة من أحمد حسين','.','new_message','{\"conversation_id\":\"3\"}',NULL,'2026-05-28 16:52:52','2026-05-28 16:52:52'),(22,2,'رسالة من أحمد حسين','مرحبا','new_message','{\"conversation_id\":\"3\"}',NULL,'2026-05-28 16:57:50','2026-05-28 16:57:50');
/*!40000 ALTER TABLE `push_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reel_comments`
--

DROP TABLE IF EXISTS `reel_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reel_comments`
--

LOCK TABLES `reel_comments` WRITE;
/*!40000 ALTER TABLE `reel_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `reel_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reel_likes`
--

DROP TABLE IF EXISTS `reel_likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reel_likes`
--

LOCK TABLES `reel_likes` WRITE;
/*!40000 ALTER TABLE `reel_likes` DISABLE KEYS */;
INSERT INTO `reel_likes` VALUES (3,11,14,'2026-05-28 16:16:02','2026-05-28 16:16:02');
/*!40000 ALTER TABLE `reel_likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reels`
--

DROP TABLE IF EXISTS `reels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reels`
--

LOCK TABLES `reels` WRITE;
/*!40000 ALTER TABLE `reels` DISABLE KEYS */;
INSERT INTO `reels` VALUES (1,1,'الحج',NULL,'reels/videos/K67tYdx4N6VXnhclotzMVqOGR5x8CE3mIjMKiuY5.mp4',NULL,NULL,0,0,0,'approved',NULL,1,'2026-05-26 07:08:12','2026-05-26 07:08:21'),(2,1,'حج',NULL,'reels/videos/acQ80EijhUpyP3FMQgP98OK1acVZROhBUnP0maye.mp4',NULL,NULL,0,1,1,'approved',NULL,1,'2026-05-26 07:14:13','2026-05-26 11:03:42'),(3,2,'تمارين تقوية أسفل الظهر','مجموعة تمارين فعالة لتقوية عضلات أسفل الظهر والحد من الآلام المزمنة','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',NULL,185,386,68,2,'approved',NULL,1,'2026-05-26 11:05:30','2026-05-26 11:05:30'),(4,3,'كيف تتعافى من إصابة الركبة؟','شرح مبسط لمراحل تعافي الركبة بعد الإصابة وأهم التمارين في كل مرحلة','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',NULL,240,147,80,15,'approved',NULL,1,'2026-05-26 11:05:30','2026-05-26 11:05:30'),(5,4,'تمارين الرقبة للمكتبيين','تمارين يومية لتخفيف آلام الرقبة الناتجة عن الجلوس الطويل أمام الكمبيوتر','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',NULL,156,485,38,9,'approved',NULL,1,'2026-05-26 11:05:30','2026-05-26 11:05:30'),(6,5,'إعادة تأهيل بعد عملية الغضروف','برنامج التأهيل الكامل بعد جراحة الغضروف - الأسبوع الأول','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',NULL,312,375,61,15,'approved',NULL,1,'2026-05-26 11:05:30','2026-05-26 11:05:30'),(7,6,'تمارين الكتف للرياضيين','تمارين تقوية وتمطيط الكتف للرياضيين والوقاية من الإصابات','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',NULL,198,395,27,3,'approved',NULL,1,'2026-05-26 11:05:30','2026-05-26 11:05:30'),(8,7,'علاج آلام القدم المسطحة','تمارين وإرشادات لتحسين تقوس القدم وتخفيف الآلام','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',NULL,167,493,29,13,'approved',NULL,1,'2026-05-26 11:05:30','2026-05-26 11:05:30'),(9,8,'تمارين التوازن لكبار السن','تمارين آمنة وفعالة لتحسين التوازن والوقاية من السقوط لدى كبار السن','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',NULL,220,380,58,13,'approved',NULL,1,'2026-05-26 11:05:30','2026-05-26 11:05:30'),(10,9,'تمارين تقوية عضلات الحوض','تمارين بيلاتيس لتقوية عضلات قاع الحوض وتحسين الثبات','https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',NULL,195,119,49,10,'approved',NULL,1,'2026-05-26 11:05:30','2026-05-26 11:05:30'),(11,1,'حج',NULL,'reels/videos/zZSTWOBS4JvofDqDiLZWoOvKigPNVeXt7Ra38GbC.mp4',NULL,NULL,0,1,0,'approved',NULL,1,'2026-05-28 10:00:08','2026-05-28 16:16:02'),(12,1,'ننن',NULL,'reels/videos/7oxY89yYEcyQD8sxNrAgSz4oRLhhOtw7MxJHAEn3.mp4',NULL,NULL,0,0,0,'approved',NULL,1,'2026-05-28 15:02:53','2026-05-28 15:03:02'),(13,1,'عيد',NULL,'reels/videos/a7YDoJfHP4zpqpim4meI2XLIrcSypEpdLK3kay5v.mp4',NULL,NULL,0,0,0,'approved',NULL,1,'2026-05-28 15:13:37','2026-05-28 15:13:42');
/*!40000 ALTER TABLE `reels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reviews`
--

DROP TABLE IF EXISTS `reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reviews`
--

LOCK TABLES `reviews` WRITE;
/*!40000 ALTER TABLE `reviews` DISABLE KEYS */;
INSERT INTO `reviews` VALUES (1,3,1,3,5,'متعاون ومهني جداً',1,'2026-05-04 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(2,9,1,4,5,'جلسة ممتازة وأخصائي محترف',1,'2026-05-02 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(3,8,2,5,4,'جلسة ممتازة وأخصائي محترف',1,'2026-05-21 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(4,9,2,6,4,'خدمة ممتازة وبيئة مريحة',1,'2026-05-04 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(5,8,2,8,4,'تحسن كبير بعد الجلسات',1,'2026-04-28 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(6,5,3,9,4,'جلسة ممتازة وأخصائي محترف',1,'2026-05-20 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(7,3,3,10,5,'تحسن كبير بعد الجلسات',1,'2026-05-03 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(8,2,4,11,4,'جلسة ممتازة وأخصائي محترف',1,'2026-05-20 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(9,4,4,12,4,'نتائج رائعة، أنصح بشدة',1,'2026-05-13 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(10,4,5,13,4,'تحسن كبير بعد الجلسات',1,'2026-05-15 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(11,6,5,14,5,'جلسة ممتازة وأخصائي محترف',1,'2026-05-04 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(12,6,5,15,4,'خدمة ممتازة وبيئة مريحة',1,'2026-05-23 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09'),(13,3,5,16,5,'تحسن كبير بعد الجلسات',1,'2026-04-27 11:05:09','2026-05-26 11:05:09','2026-05-26 11:05:09');
/*!40000 ALTER TABLE `reviews` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `session_notes`
--

DROP TABLE IF EXISTS `session_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `session_notes`
--

LOCK TABLES `session_notes` WRITE;
/*!40000 ALTER TABLE `session_notes` DISABLE KEYS */;
INSERT INTO `session_notes` VALUES (1,19,NULL,NULL,NULL,NULL,5,NULL,'2026-05-28 15:14:16','2026-05-28 15:14:24');
/*!40000 ALTER TABLE `session_notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES ('9IW64HrE5rDLP6YOGjXKnxuYHOLDiOIDiQnTgMGI',NULL,'127.0.0.1','curl/8.11.0','YTozOntzOjY6Il90b2tlbiI7czo0MDoicGNaam9idXY5RE4xb0h0MTR2SmFnRXlmQmRlMDg5dnprQ0d2Tk5BVyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly8xMjcuMC4wLjE6ODAwMSI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==',1779972889),('Ggj7jOUmM0uIXhaXZwrl89oPzM5xf3MY94PD8Lmt',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiVWZQS2w2eFBGcWI1RHFpeTdtNEtHajV5YUJDb2FyRjRjYVhmTXhHSiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MzM6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMS9hZG1pbi9yZWVscyI7czo1OiJyb3V0ZSI7czoxNzoiYWRtaW4ucmVlbHMuaW5kZXgiO31zOjY6Il9mbGFzaCI7YToyOntzOjM6Im9sZCI7YTowOnt9czozOiJuZXciO2E6MDp7fX1zOjM6InVybCI7YTowOnt9czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTt9',1779982131),('gJPPA7xj8ELYquKLxJoCNozzhNG1Hk8aO5obRUP8',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiVnB2dVd2V2RxMVE1ZHFTdG9abjdMQncwNVo2SkxMaVBCNTFQT0RHWCI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjM2OiJodHRwOi8vbG9jYWxob3N0OjgwMDEvYWRtaW4vcGF0aWVudHMiO3M6NToicm91dGUiO3M6MjA6ImFkbWluLnBhdGllbnRzLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTt9',1779998296),('IJnqe0ihh1G1hin4tqXjnSXhDtsYHBmJRJCppVma',1,'127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','YTo1OntzOjY6Il90b2tlbiI7czo0MDoiQ2Q3T0puYm5vOUZqQlVkbzdhRTExaUwzcXJUWDFGSm5uUkdYVHMxNSI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjI3OiJodHRwOi8vbG9jYWxob3N0OjgwMDEvYWRtaW4iO3M6NToicm91dGUiO3M6MTU6ImFkbWluLmRhc2hib2FyZCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==',1779966191);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `specializations`
--

DROP TABLE IF EXISTS `specializations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `specializations`
--

LOCK TABLES `specializations` WRITE;
/*!40000 ALTER TABLE `specializations` DISABLE KEYS */;
INSERT INTO `specializations` VALUES (1,'علاج طبيعي عام','General Physical Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(2,'علاج عظام ومفاصل','Orthopedic Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(3,'علاج أعصاب','Neurological Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(4,'علاج رياضي','Sports Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(5,'علاج العمود الفقري','Spine Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(6,'علاج حوض وأرضية الحوض','Pelvic Floor Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(7,'علاج وظيفي','Occupational Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(8,'علاج أطفال','Pediatric Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(9,'إعادة التأهيل بعد الجراحة','Post-Surgical Rehabilitation',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(10,'علاج سرطان','Oncology Rehabilitation',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(11,'علاج قلب وأوعية','Cardiopulmonary Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(12,'علاج شيخوخة','Geriatric Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(13,'دراما العلاج النفسي الحركي','Psychomotor Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51'),(14,'التأهيل اليدوي','Hand Therapy',NULL,1,'2026-05-25 12:19:51','2026-05-25 12:19:51');
/*!40000 ALTER TABLE `specializations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `therapist_certifications`
--

DROP TABLE IF EXISTS `therapist_certifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `therapist_certifications`
--

LOCK TABLES `therapist_certifications` WRITE;
/*!40000 ALTER TABLE `therapist_certifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `therapist_certifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `therapist_documents`
--

DROP TABLE IF EXISTS `therapist_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `therapist_documents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `therapist_id` bigint(20) unsigned NOT NULL,
  `type` enum('license','id_card','certificate','other') NOT NULL,
  `file_path` varchar(255) NOT NULL,
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `therapist_documents`
--

LOCK TABLES `therapist_documents` WRITE;
/*!40000 ALTER TABLE `therapist_documents` DISABLE KEYS */;
/*!40000 ALTER TABLE `therapist_documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `therapist_educations`
--

DROP TABLE IF EXISTS `therapist_educations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `therapist_educations`
--

LOCK TABLES `therapist_educations` WRITE;
/*!40000 ALTER TABLE `therapist_educations` DISABLE KEYS */;
/*!40000 ALTER TABLE `therapist_educations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `therapist_languages`
--

DROP TABLE IF EXISTS `therapist_languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `therapist_languages`
--

LOCK TABLES `therapist_languages` WRITE;
/*!40000 ALTER TABLE `therapist_languages` DISABLE KEYS */;
INSERT INTO `therapist_languages` VALUES (1,2,'العربية','native','2026-05-26 11:04:32','2026-05-26 11:04:32'),(2,2,'الإنجليزية','fluent','2026-05-26 11:04:32','2026-05-26 11:04:32'),(3,3,'العربية','native','2026-05-26 11:04:32','2026-05-26 11:04:32'),(4,3,'الإنجليزية','fluent','2026-05-26 11:04:32','2026-05-26 11:04:32'),(5,4,'العربية','native','2026-05-26 11:04:33','2026-05-26 11:04:33'),(6,4,'الإنجليزية','fluent','2026-05-26 11:04:33','2026-05-26 11:04:33'),(7,5,'العربية','native','2026-05-26 11:04:33','2026-05-26 11:04:33'),(8,5,'الإنجليزية','fluent','2026-05-26 11:04:33','2026-05-26 11:04:33'),(9,6,'العربية','native','2026-05-26 11:04:33','2026-05-26 11:04:33'),(10,6,'الإنجليزية','fluent','2026-05-26 11:04:33','2026-05-26 11:04:33'),(11,7,'العربية','native','2026-05-26 11:04:34','2026-05-26 11:04:34'),(12,7,'الإنجليزية','fluent','2026-05-26 11:04:34','2026-05-26 11:04:34'),(13,8,'العربية','native','2026-05-26 11:04:34','2026-05-26 11:04:34'),(14,8,'الإنجليزية','fluent','2026-05-26 11:04:34','2026-05-26 11:04:34'),(15,9,'العربية','native','2026-05-26 11:04:34','2026-05-26 11:04:34'),(16,9,'الإنجليزية','fluent','2026-05-26 11:04:34','2026-05-26 11:04:34');
/*!40000 ALTER TABLE `therapist_languages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `therapist_schedules`
--

DROP TABLE IF EXISTS `therapist_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `therapist_schedules`
--

LOCK TABLES `therapist_schedules` WRITE;
/*!40000 ALTER TABLE `therapist_schedules` DISABLE KEYS */;
INSERT INTO `therapist_schedules` VALUES (1,2,NULL,'in_person',4,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(2,2,NULL,'online',4,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(3,2,NULL,'in_person',0,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(4,2,NULL,'online',0,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(5,2,NULL,'in_person',2,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(6,2,NULL,'online',2,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(7,2,NULL,'online',1,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(8,2,NULL,'in_person',1,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(9,2,NULL,'in_person',3,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(10,2,NULL,'online',3,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(11,3,NULL,'online',0,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(12,3,NULL,'in_person',0,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(13,3,NULL,'in_person',1,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(14,3,NULL,'in_person',1,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(15,3,NULL,'online',4,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(16,3,NULL,'online',4,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(17,3,NULL,'in_person',2,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(18,3,NULL,'in_person',2,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(19,4,NULL,'in_person',4,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(20,4,NULL,'in_person',4,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(21,4,NULL,'in_person',3,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(22,4,NULL,'online',3,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(23,4,NULL,'in_person',2,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(24,4,NULL,'in_person',2,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(25,4,NULL,'online',1,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(26,4,NULL,'in_person',1,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(27,5,NULL,'online',0,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(28,5,NULL,'online',0,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(29,5,NULL,'online',3,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(30,5,NULL,'in_person',3,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(31,5,NULL,'online',1,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(32,5,NULL,'online',1,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(33,5,NULL,'online',4,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(34,5,NULL,'in_person',4,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(35,5,NULL,'in_person',2,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(36,5,NULL,'online',2,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(37,6,NULL,'online',4,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(38,6,NULL,'in_person',4,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(39,6,NULL,'online',1,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(40,6,NULL,'online',1,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(41,6,NULL,'in_person',2,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(42,6,NULL,'online',2,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(43,6,NULL,'online',3,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(44,6,NULL,'online',3,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(45,6,NULL,'online',0,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(46,6,NULL,'in_person',0,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(47,7,NULL,'online',2,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(48,7,NULL,'online',2,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(49,7,NULL,'in_person',4,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(50,7,NULL,'online',4,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(51,7,NULL,'in_person',1,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(52,7,NULL,'in_person',1,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(53,8,NULL,'in_person',3,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(54,8,NULL,'in_person',3,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(55,8,NULL,'online',0,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(56,8,NULL,'online',0,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(57,8,NULL,'online',1,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(58,8,NULL,'in_person',1,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(59,8,NULL,'in_person',2,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(60,8,NULL,'in_person',2,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(61,9,NULL,'in_person',0,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(62,9,NULL,'online',0,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(63,9,NULL,'online',2,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(64,9,NULL,'in_person',2,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(65,9,NULL,'in_person',4,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(66,9,NULL,'online',4,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(67,9,NULL,'in_person',3,'09:00:00','13:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(68,9,NULL,'in_person',3,'16:00:00','20:00:00',60,1,'2026-05-26 11:04:46','2026-05-26 11:04:46'),(69,1,NULL,'online',0,'09:00:00','18:00:00',60,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(70,1,1,'in_person',0,'09:00:00','14:00:00',60,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(71,1,NULL,'online',1,'09:00:00','18:00:00',60,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(72,1,1,'in_person',1,'09:00:00','14:00:00',60,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(73,1,NULL,'online',2,'09:00:00','18:00:00',60,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(74,1,1,'in_person',2,'09:00:00','14:00:00',60,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(75,1,NULL,'online',3,'09:00:00','18:00:00',60,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(76,1,1,'in_person',3,'09:00:00','14:00:00',60,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(77,1,NULL,'online',4,'09:00:00','18:00:00',60,1,'2026-05-28 08:00:32','2026-05-28 08:00:32'),(78,1,1,'in_person',4,'09:00:00','14:00:00',60,1,'2026-05-28 08:00:32','2026-05-28 08:00:32');
/*!40000 ALTER TABLE `therapist_schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `therapist_specializations`
--

DROP TABLE IF EXISTS `therapist_specializations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `therapist_specializations`
--

LOCK TABLES `therapist_specializations` WRITE;
/*!40000 ALTER TABLE `therapist_specializations` DISABLE KEYS */;
INSERT INTO `therapist_specializations` VALUES (1,1,7,NULL,NULL),(2,2,1,NULL,NULL),(3,2,2,NULL,NULL),(4,2,5,NULL,NULL),(5,3,4,NULL,NULL),(6,3,9,NULL,NULL),(7,4,7,NULL,NULL),(8,4,8,NULL,NULL),(9,5,3,NULL,NULL),(10,5,12,NULL,NULL),(11,6,6,NULL,NULL),(12,7,1,NULL,NULL),(13,7,14,NULL,NULL),(14,8,11,NULL,NULL),(15,8,10,NULL,NULL),(16,9,4,NULL,NULL),(17,9,2,NULL,NULL),(18,9,9,NULL,NULL);
/*!40000 ALTER TABLE `therapist_specializations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `therapist_unavailabilities`
--

DROP TABLE IF EXISTS `therapist_unavailabilities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `therapist_unavailabilities`
--

LOCK TABLES `therapist_unavailabilities` WRITE;
/*!40000 ALTER TABLE `therapist_unavailabilities` DISABLE KEYS */;
/*!40000 ALTER TABLE `therapist_unavailabilities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `therapists`
--

DROP TABLE IF EXISTS `therapists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `therapists`
--

LOCK TABLES `therapists` WRITE;
/*!40000 ALTER TABLE `therapists` DISABLE KEYS */;
INSERT INTO `therapists` VALUES (1,2,'محمد خلاف',NULL,'avatars/therapists/uv1GtnzMzqqD3dDL2M5XQ2U52ELye0t6UU3sEBLS.jpg','معالج',NULL,5,'معالج وظيفي','male',NULL,NULL,'الخليل','بكالوريوس',1,0,'2026-05-26 06:28:25',0,1,NULL,NULL,60,0.00,0,0,0,0,'2026-05-26 06:26:33','2026-05-26 06:28:25'),(2,6,'د. سارة الأحمد',NULL,NULL,'متخصصة في علاج إصابات العمود الفقري والمفاصل مع خبرة 8 سنوات في إعادة التأهيل',NULL,8,'أخصائية علاج طبيعي','female',NULL,NULL,'رام الله','ماجستير',1,0,NULL,0,1,NULL,NULL,60,4.00,1,0,0,1,'2026-05-26 11:04:32','2026-05-26 11:05:09'),(3,7,'أ. يوسف ناصر',NULL,NULL,'متخصص في العلاج الرياضي وتأهيل الرياضيين بعد الإصابات',NULL,5,'معالج طبيعي','male',NULL,NULL,'نابلس','بكالوريوس',1,0,NULL,0,1,NULL,NULL,60,5.00,3,0,0,0,'2026-05-26 11:04:32','2026-05-26 11:05:09'),(4,8,'د. منى حسين',NULL,NULL,'خبرة واسعة في علاج الأطفال وتأهيلهم الحركي والوظيفي',NULL,10,'أخصائية علاج وظيفي','female',NULL,NULL,'الخليل','دكتوراه',1,0,NULL,0,1,NULL,NULL,60,4.00,2,0,0,1,'2026-05-26 11:04:33','2026-05-26 11:05:09'),(5,9,'أ. خالد إبراهيم',NULL,NULL,'متخصص في علاج إصابات الأعصاب والسكتة الدماغية وشلل الأطفال',NULL,7,'أخصائي علاج أعصاب','male',NULL,NULL,'بيت لحم','ماجستير',1,0,NULL,0,1,NULL,NULL,60,4.00,1,0,0,0,'2026-05-26 11:04:33','2026-05-26 11:05:09'),(6,10,'د. رنا المصري',NULL,NULL,'متخصصة في علاج مشاكل أرضية الحوض لدى النساء ما قبل وبعد الولادة',NULL,6,'أخصائية حوض وأرضية الحوض','female',NULL,NULL,'رام الله','ماجستير',1,0,NULL,0,1,NULL,NULL,60,4.50,2,0,0,0,'2026-05-26 11:04:33','2026-05-26 11:05:09'),(7,11,'أ. عمر شحادة',NULL,NULL,'يقدم خدمات العلاج الطبيعي الشاملة لمختلف الحالات',NULL,4,'معالج طبيعي عام','male',NULL,NULL,'جنين','بكالوريوس',1,0,NULL,0,1,NULL,NULL,60,0.00,0,0,0,0,'2026-05-26 11:04:34','2026-05-26 11:04:34'),(8,12,'د. ليلى عبد الرحمن',NULL,NULL,'متخصصة في إعادة تأهيل مرضى القلب وأمراض الأوعية الدموية',NULL,9,'أخصائية علاج القلب','female',NULL,NULL,'نابلس','دكتوراه',1,0,NULL,0,1,NULL,NULL,60,4.00,2,0,0,1,'2026-05-26 11:04:34','2026-05-26 11:05:09'),(9,13,'أ. باسم قاسم',NULL,NULL,'أخصائي معتمد في الطب الرياضي وعلاج إصابات كرة القدم',NULL,6,'معالج طبيعي رياضي','male',NULL,NULL,'القدس','ماجستير',1,0,NULL,0,1,NULL,NULL,60,4.50,2,0,0,0,'2026-05-26 11:04:34','2026-05-26 11:05:09');
/*!40000 ALTER TABLE `therapists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
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
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'599000000','+970',NULL,NULL,'admin','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 09:53:40',NULL,'2026-05-25 12:19:51','2026-05-28 07:12:40'),(2,'594513978','+972',NULL,NULL,'therapist','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 05:44:21',NULL,'2026-05-26 04:58:12','2026-05-28 07:12:40'),(6,'591000001','+972',NULL,NULL,'therapist','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:04:32',NULL,'2026-05-26 11:04:32','2026-05-28 07:12:40'),(7,'591000002','+972',NULL,NULL,'therapist','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:04:32',NULL,'2026-05-26 11:04:32','2026-05-28 07:12:40'),(8,'591000003','+972',NULL,NULL,'therapist','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:04:33',NULL,'2026-05-26 11:04:33','2026-05-28 07:12:40'),(9,'591000004','+972',NULL,NULL,'therapist','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:04:33',NULL,'2026-05-26 11:04:33','2026-05-28 07:12:40'),(10,'591000005','+972',NULL,NULL,'therapist','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:04:33',NULL,'2026-05-26 11:04:33','2026-05-28 07:12:40'),(11,'591000006','+972',NULL,NULL,'therapist','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:04:34',NULL,'2026-05-26 11:04:34','2026-05-28 07:12:40'),(12,'591000007','+972',NULL,NULL,'therapist','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:04:34',NULL,'2026-05-26 11:04:34','2026-05-28 07:12:40'),(13,'591000008','+972',NULL,NULL,'therapist','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:04:34',NULL,'2026-05-26 11:04:34','2026-05-28 07:12:40'),(14,'592000001','+972',NULL,NULL,'patient','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq','e5BWzZ28Ro6yC3AMta3s5I:APA91bG3qtTHSgFeEyd03JJyUPc92KpYchccrjmLR8fHinc6OjHsuRrWwQxKHJbjNKv6ZTTwh4sBptxU172nXbSenFMuULxkzGwRqbLa6DgQ7-6zTIUwa_4',1,'2026-05-26 11:05:08',NULL,'2026-05-26 11:05:08','2026-05-28 16:53:47'),(15,'592000002','+972',NULL,NULL,'patient','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:05:08',NULL,'2026-05-26 11:05:08','2026-05-28 07:12:40'),(16,'592000003','+972',NULL,NULL,'patient','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:05:08',NULL,'2026-05-26 11:05:08','2026-05-28 07:12:40'),(17,'592000004','+972',NULL,NULL,'patient','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:05:09',NULL,'2026-05-26 11:05:09','2026-05-28 07:12:40'),(18,'592000005','+972',NULL,NULL,'patient','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:05:09',NULL,'2026-05-26 11:05:09','2026-05-28 07:12:40'),(19,'598420090','+972',NULL,NULL,'patient','$2y$12$QCMXECA/fTlLqirSERxopeo7IxClJbr9NBpLbkcVz0poEhF0tORjq',NULL,1,'2026-05-26 11:28:09',NULL,'2026-05-26 11:27:58','2026-05-28 07:12:40');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-01 13:23:29
