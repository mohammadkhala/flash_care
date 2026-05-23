import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/utils/const_res.dart';

///------------------------ GetX ------------------------///
const String kTimerUpdate = 'timerUpdate';
const String kSelectCountries = 'selectCountries';
const String kSelectGender = 'selectGender';
const String kAppointmentDelete = 'appointmentDelete';
const String kAppointmentDateChange = 'appointmentDateChange';
const String kDoctorCategory = 'doctorCategory';

///------------------------ Setting data ------------------------///
String dollar = '\$';

///------------------------ Notification key ------------------------///
const String androidChannelId = 'doctor_flutter';
const String nSenderId = 'senderId';
const String nAppointmentId = 'appointmentId';
const String nNotificationType = 'notificationType';
const String nTitle = 'title';
const String nBody = 'body';

///------------------------ App Res ------------------------///

const String ddMmmYyyyHhMmA = 'dd MMM, yyyy hh:mm a';
const String eeeMmmDdYyyy = 'dd MMM, yyyy : EE,';
const String ddMmmYyyyDesHhMmA = 'dd MMM, yyyy - h:mm a';
const String ddMmmmYyyyHhMmA = 'dd MMMM yyyy : hh:mm a';
const String ddMmmYyyyEeeHhMmA = 'dd MMM yyyy: EEE, hh:mm:a';
const String eeeDdMmmYyyyHhMmA = 'EEE, dd MMM, yyyy : hh:mm a';
const String yyyyMmDd = 'yyyy-MM-dd';
const String ddMmmmYyyy = 'dd MMMM yyyy';
const String ddMmmYyyy = 'dd MMM yyyy';
const String hhMmA = 'hh:mm a';
const String pm = 'PM';
const String ee = 'EE';
const String mmmm = 'MMMM';
const String hhMm = 'HHmm';
const String mm = 'MM';
const String yyyy = 'yyyy';
const double latConst = 20.5937;
const double longConst = 78.9629;
const String milliDate = '1640901600000000';
const String createdDate = '2023-04-11T11:35:17.000000Z';
const String numberFormat = '#,##,###.#';
const String percentage = '%';
const String fourHundred = '400';
const String chartFormat = 'Day : point.x \nEarning : point.y  ';
const String testingEmail = 'dhruvkathiriya.retrytech@gmail.com';

// For Login and registration
String get theEmailIsAlreadyInUseInThePatientApp =>
    '${S.current.theEmailIsAlreadyInUseInThe} $appName. ${S.current.pleaseUseADifferentEmailAddress}';
