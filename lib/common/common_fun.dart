import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonFun {

  static String convert24HoursInto12Hours(String? value) {
    DateTime dateTime = DateTime(
      DateTime.now().year,
      1,
      1,
      int.parse(value?.substring(0, 2) ?? '0'),
      int.parse(value?.substring(2, 4) ?? '0'),
    );
    return DateFormat(hhMmA, 'en').format(dateTime);
  }

  static int getHourFromTime(String? time) {
    if (time == null) return 0;
    return int.parse(time.split(":")[0]) + (time.split(":")[1].split(" ")[1].contains(pm) ? 12 : 0);
  }

  static String getMinFromTime(String? time) {
    return time?.split(":")[1].split(" ")[0] ?? "0";
  }

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

  static String dateFormat(String? date, int type) {
    DateTime parseDate = DateFormat(yyyyMmDd, 'en').parse(date ?? '');
    var inputDate = DateTime.parse(parseDate.toString());
    var outputFormat = DateFormat(type == 1 ? ddMmmmYyyy : ddMmmYyyy, 'en');
    String outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  static DateTime days(String? date) {
    DateTime d = DateFormat(yyyyMmDd, 'en').parse(date ?? '');
    return d;
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
      return "${diff.inDays} ${S.current.days}";
    }
    if (diff.inHours > 0) {
      return "${diff.inHours} ${diff.inHours == 1 ? S.current.hour : S.current.hours}";
    }
    if (diff.inMinutes > 0) {
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? S.current.minute : S.current.minutes}";
    }
    return S.current.justNow;
  }

  static void doctorBanned(Function completion) {
    DoctorData? doctorData = SessionManager.instance.getDoctor();
    if (doctorData?.status == 2) {
        HapticFeedback.heavyImpact();
        CustomUi.snackBar(message: S.current.doctorBlockByAdmin);
      } else {
        completion();
      }
  }

  static String getDays(int weekIndex) {
    return weekIndex == 1
        ? S.current.monday
        : weekIndex == 2
            ? S.current.tuesday
            : weekIndex == 3
                ? S.current.wednesday
                : weekIndex == 4
                    ? S.current.thursday
                    : weekIndex == 5
                        ? S.current.friday
                        : weekIndex == 6
                            ? S.current.saturday
                            : S.current.sunday;
  }

  static List<String> get getSlotsBookingLimit {
    List<String> limit = [];
    for (int i = 1; i <= maxSlotLimit; i++) {
      limit.add('$i');
    }
    return limit;
  }

  static Future<void> loadUrl({required String url}) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch');
    }
  }

  static String setDoctorId({required int? doctorId}) {
    return '${doctorId}D';
  }

  static String setPatientId({required int? patientId}) {
    return '${patientId}P';
  }
}
