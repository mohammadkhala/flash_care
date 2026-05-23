import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/global/global_setting.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/update_res.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';

class CommonFun {
  static calculateAge(String? birthDate) {
    DateTime currentDate = DateTime.now();
    DateTime parseDate = DateFormat(yyyyMmDd, 'en').parse(birthDate ?? '');
    int age = currentDate.year - parseDate.year;
    int month1 = currentDate.month;
    int month2 = parseDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = parseDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  static String timeAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365) {
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? S.current.year : S.current.years}";
    }
    if (diff.inDays > 30) {
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? S.current.month : S.current.months}";
    }
    if (diff.inDays > 7) {
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? S.current.week : S.current.weeks}";
    }
    if (diff.inDays > 0) {
      if (diff.inDays == 1) {
        return S.current.yesterday;
      }
      return "${diff.inDays}${S.current.days}";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? S.current.hour : S.current.hours}";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? S.current.minute : S.current.minutes}";
    }
    return S.current.justNow;
  }

  static String getConversationId(
      {required int? patient, required int? doctor}) {
    String patientId = setPatientId(patientId: patient);
    String doctorId = setDoctorId(doctorId: doctor);
    String convId = '${patientId}_$doctorId';

    List<String> id = convId.split('_');

    id.sort((a, b) {
      return int.parse(a.replaceAll('D', '').replaceAll('P', ''))
          .compareTo(int.parse(b.replaceAll('D', '').replaceAll('P', '')));
    });
    convId = id.join('_');
    return convId;
  }

  static String setDoctorId({required int? doctorId}) {
    return '${doctorId}D';
  }

  static String setPatientId({required int? patientId}) {
    return '${patientId}P';
  }

  static Future<void> loadUrl({required String url}) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch');
    }
  }

  static List<String> sendScheduledAtTime(
      {required String time, required String date}) {
    List<String> scheduleTime = [];
    List<Reminders> reminder = [];

    String appointmentDate =
        '$date ${CustomUi.convert24HoursInto12Hours(time)}';

    DateTime appointmentTime =
        DateFormat('yyyy-MM-dd hh:mm a', 'en_US').parse(appointmentDate);

    reminder = SessionManager.instance.getSettings()?.reminders ?? [];

    if (reminder.isNotEmpty) {
      for (int i = 0; i < reminder.length; i++) {
        Duration duration = Duration(
          days: (reminder[i].day ?? 0).toInt(),
          hours: (reminder[i].hr ?? 0).toInt(),
          minutes: (reminder[i].min ?? 0).toInt(),
        );
        DateTime scheduleDate = appointmentTime.subtract(duration);

        if (scheduleDate.compareTo(DateTime.now()) > 0) {
          scheduleTime.add(
              '${DateFormat('yyyy-MM-dd HH:mm:ss').format(scheduleDate.toUtc())}/${title(reminder[i])}');
        } else {
          debugPrint('No Appointment');
        }
      }
    }
    return scheduleTime;
  }

  static String title(Reminders reminder) {
    String day = '';
    String minute = '';
    String second = '';
    if ((reminder.day ?? 0) > 0) {
      day = '${reminder.day} Days';
    }
    if ((reminder.hr ?? 0) > 0) {
      if (day.isNotEmpty) {
        day = '$day & ';
      }
      minute = '${reminder.hr} Hours';
    }
    if ((reminder.min ?? 0) > 0) {
      if (minute.isNotEmpty) {
        minute = '$minute & ';
      }
      second = '${reminder.min} Minutes';
    }
    return (day + minute + second);
  }

  static Future<File> getVideoThumbnail(String? videoPath) async {
    final thumbnailFile = await VideoCompress.getFileThumbnail(videoPath ?? '');
    return thumbnailFile;
  }
}
