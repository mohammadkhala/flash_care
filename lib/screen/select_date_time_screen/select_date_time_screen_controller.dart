import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_accept_pending_appointments.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/custom/categories.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/confirm_booking_screen/confirm_booking_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/extention.dart';
import 'package:patient_flutter/utils/update_res.dart';

class SelectDateTimeScreenController extends GetxController {
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int day = DateTime.now().day;
  Rx<DateTime> selectedDay = DateTime.now().obs;
  TextEditingController problemController = TextEditingController();
  int selectedAppointmentType = 0;
  DoctorData? doctorData;
  UserData? currentUser;
  List<Patient?> patientList = [];
  Patient? selectedPatient;
  List<Slots> slotTime = [];
  Slots? selectedSlot;
  List<File> imageFileList = [];

  // ── Family member quick-add ───────────────────────────────────────────────
  final TextEditingController familyNameController    = TextEditingController();
  final TextEditingController familyAgeController     = TextEditingController();
  final TextEditingController familyRelationController = TextEditingController();
  String familyGender = 'ذكر';
  bool isAddingFamilyMember = false;

  bool isLoadAppointment = false;
  List<FetchAcceptPendingAppointmentData> acceptPendingData = [];
  List<Patient>? patientData = [];
  AppointmentData? appointmentData;
  ScrollController dateController = ScrollController();

  RxList<DateTime> days = List<DateTime>.generate(
      dateLimit,
      (i) => DateTime.utc(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .add(Duration(hours: 24 * i))).obs;

  @override
  void onInit() {
    doctorData = Get.arguments[0];
    appointmentData = Get.arguments[1];
    currentUser = SessionManager.instance.getUser();
    // First entry = the user themselves (no id = "myself")
    patientList = [Patient(fullname: currentUser?.fullname ?? 'أنا')];
    fetchDoctorProfile();
    fetchPatientApiCall();
    super.onInit();
  }

  void onDoneClick(int month, int year) {
    this.year = year;
    this.month = month;
    if (DateTime.now().month == month) {
      day = DateTime.now().day;
    } else {
      day = DateTime(year, month).day;
    }
    getDays(year: year, month: month, day: day);
    onSelectedDateClick(
        DateTime(year, month, day),
        days.indexWhere(
          (element) =>
              element.isSameDate(DateTime(year, month, selectedDay.value.day)),
        ));
    update([kSelectDate]);
  }

  void getDays({required int year, required int month, required int day}) {
    days.value = [];
    days.value = List<DateTime>.generate(dateLimit,
        (i) => DateTime.utc(year, month, day).add(Duration(hours: 24 * i)));
  }

  void onSelectedDateClick(DateTime dateTime, int index) {
    selectedSlot = null;
    selectedDay.value = dateTime;
    fetchAcceptedPendingAppointmentsOfDoctorByDate(
        DateFormat(yyyyMMDd).format(dateTime), (data) {
      initSlotList(dateTime, data);
    });
    if (dateController.hasClients &&
        dateController.offset < dateController.position.maxScrollExtent) {
      dateController.animateTo(index * (63 + 8),
          duration: const Duration(milliseconds: 300), curve: Curves.linear);
    }
    year = dateTime.year;
    month = dateTime.month;
    day = dateTime.day;
    update([kSelectTime, kSelectDate]);
  }

  void fetchAcceptedPendingAppointmentsOfDoctorByDate(String date,
      Function(List<FetchAcceptPendingAppointmentData> data) onComplete) async {
    print('date :- $date');
    isLoadAppointment = true;
    update([kSelectTime]);
    ApiService.instance
        .fetchAcceptedPendingAppointmentsOfDoctorByDate(
            doctorId: doctorData?.id ?? -1, date: date)
        .then((value) {
      isLoadAppointment = false;

      if (value.status == true) {
        acceptPendingData = value.data ?? [];
        onComplete(acceptPendingData);
        update([kSelectTime]);
      } else {
        CustomUi.snackBar(message: value.message);
      }
    });
  }

  void fetchPatientApiCall() async {
    // Try session cache first for instant render
    String response = SessionManager.instance.getString(key: kPatient) ?? '';
    if (response.isNotEmpty) {
      Iterable l = jsonDecode(response);
      patientData = List<Patient>.from(l.map((e) => Patient.fromJson(e)));
      patientList = [Patient(fullname: currentUser?.fullname ?? 'أنا'), ...patientData!];
      update();
    }
    // Then refresh from API in background
    try {
      final val = await ApiService.instance.fetchPatient();
      patientData = val.data ?? [];
      patientList = [Patient(fullname: currentUser?.fullname ?? 'أنا'), ...patientData!];
      update();
    } catch (_) {}
  }

  void onPatientChange(Patient? onChange) {
    selectedPatient = onChange!;
    update();
  }

  // ── Show patient selection + add family member sheet ──────────────────────
  void showPatientSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PatientSelectionSheet(controller: this),
    );
  }

  void onAddFamilyMemberTap(BuildContext context) {
    familyNameController.clear();
    familyAgeController.clear();
    familyRelationController.clear();
    familyGender = 'ذكر';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _AddFamilyMemberSheet(controller: this),
      ),
    );
  }

  Future<void> submitFamilyMember(BuildContext context) async {
    final name     = familyNameController.text.trim();
    final age      = familyAgeController.text.trim();
    final relation = familyRelationController.text.trim();
    if (name.isEmpty || age.isEmpty || relation.isEmpty) {
      CustomUi.snackBar(message: 'يرجى تعبئة جميع الحقول المطلوبة');
      return;
    }
    isAddingFamilyMember = true;
    update();
    try {
      final result = await ApiService.instance.addPatient(
        fullName: name,
        age:      age,
        relation: relation,
        gender:   familyGender == 'ذكر' ? 1 : 0,
      );
      if (result.status == true) {
        Get.back(); // close add sheet
        Get.back(); // close selection sheet
        await _reloadPatientList();
        // Auto-select the newly added patient (last in list)
        if (patientData != null && patientData!.isNotEmpty) {
          selectedPatient = patientData!.last;
          update();
        }
        CustomUi.snackBar(message: 'تمت إضافة الشخص بنجاح');
      } else {
        CustomUi.snackBar(message: result.message ?? 'حدث خطأ');
      }
    } catch (e) {
      CustomUi.snackBar(message: 'تعذر الاتصال، حاول مجدداً');
    } finally {
      isAddingFamilyMember = false;
      update();
    }
  }

  Future<void> _reloadPatientList() async {
    final val = await ApiService.instance.fetchPatient();
    patientData = val.data ?? [];
    patientList = [Patient(fullname: currentUser?.fullname ?? 'أنا'), ...patientData!];
    update();
  }

  void onTimeTap(Slots? slots) {
    selectedSlot = slots;
    update([kSelectTime]);
  }

  void onAppointmentTypeTap(int index) {
    selectedAppointmentType = index;
    update([kAppointmentType]);
  }

  void initSlotList(
      DateTime time, List<FetchAcceptPendingAppointmentData> bookedData) {
    slotTime = [];
    bool isToday = DateFormat('yyyy-MM-dd').format(DateTime.now().toLocal()) ==
        DateFormat('yyyy-MM-dd').format(selectedDay.value.toLocal());

    if (doctorData?.holidays?.any((holiday) =>
            DateFormat('yyyy-MM-dd').format(time) == holiday.date) ??
        false) {
      slotTime = [];
    } else {
      for (var slot in doctorData?.slots ?? []) {
        if (time.weekday == slot.weekday &&
            (!isToday ||
                slot.time!.compareTo(
                        '${0.convert2Digits(TimeOfDay.now().hour)}${0.convert2Digits(TimeOfDay.now().minute)}') ==
                    1)) {
          slotTime.add(slot);
        }
      }

      for (var slotData in slotTime) {
        var bookedSlots = bookedData
            .where((element) => element.time == slotData.time)
            .toList();
        slotData.calculateBookedSlots(bookedSlots.length);
      }

      slotTime.sort((a, b) {
        if (a.remainSlot == 0 ||
            a.time!.compareTo(
                    '${0.convert2Digits(TimeOfDay.now().hour)}${0.convert2Digits(TimeOfDay.now().minute)}') <
                1) {
          return 1;
        }
        return -1;
      });

      update([kSelectTime]);
    }
  }

  void onAttachDocument() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.attachPhoto,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF00897B)),
              title: Text(Get.locale?.languageCode == 'ar' ? 'صور' : 'Photos'),
              onTap: () async {
                Get.back();
                final ImagePicker picker = ImagePicker();
                final List<XFile> images = await picker.pickMultiImage(imageQuality: 50);
                if (images.isEmpty) return;
                for (XFile image in images) {
                  imageFileList.add(File(image.path));
                }
                update([kAttachDocument]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file_rounded, color: Color(0xFF00897B)),
              title: Text(Get.locale?.languageCode == 'ar' ? 'ملفات وتقارير (PDF، Word...)' : 'Files & Reports (PDF, Word...)'),
              onTap: () async {
                Get.back();
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'jpg', 'jpeg', 'png'],
                );
                if (result == null || result.files.isEmpty) return;
                for (PlatformFile file in result.files) {
                  if (file.path != null) {
                    imageFileList.add(File(file.path!));
                  }
                }
                update([kAttachDocument]);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void onRescheduleTap() {
    if (selectedSlot?.time == null) {
      CustomUi.snackBar(
        message: S.current.pleaseSelectAppointmentTime,
      );
      return;
    }
    CustomUi.loader();
    ApiService.instance
        .rescheduleAppointment(
            userId: appointmentData?.userId,
            appointmentId: appointmentData?.id,
            date: DateFormat(yyyyMMDd).format(selectedDay.value.toUtc()),
            time: selectedSlot?.time)
        .then((value) {
      if (value.status == true) {
        Get.back();
        Get.back();
        ApiService.instance.scheduleAppointmentReminders(
            appointmentID: value.data?.id ?? -1,
            scheduledAt: CommonFun.sendScheduledAtTime(
                time: selectedSlot?.time ?? '',
                date: DateFormat(yyyyMMDd).format(selectedDay.value.toUtc())));
        CustomUi.snackBar(message: value.message ?? '');
      } else {
        CustomUi.snackBar(message: value.message ?? '');
      }
    });
  }

  void onMakePaymentClick() {
    if (selectedSlot?.time == null) {
      CustomUi.infoSnackBar(S.current.pleaseSelectAppointmentTime);
      return;
    } else if (problemController.text.isEmpty) {
      CustomUi.infoSnackBar(S.current.pleaseExplainYourProblem);
      return;
    } else {
      AppointmentDetail detail = AppointmentDetail(
          date: DateFormat(yyyyMMDd, 'en').format(selectedDay.value.toUtc()),
          time: selectedSlot?.time ?? '',
          problem: problemController.text,
          type: selectedAppointmentType,
          patientId: selectedPatient?.id,
          documents: imageFileList,
          serviceAmount: doctorData?.consultationFee);
      Get.to(() => const ConfirmBookingScreen(),
          arguments: [detail, doctorData]);
    }
  }

  onImageDelete(File? imageFileList) {
    this.imageFileList.remove(imageFileList);
    update([kAttachDocument]);
  }

  void fetchDoctorProfile() {
    ApiService.instance
        .fetchDoctorProfile(doctorId: doctorData?.id)
        .then((value) {
      doctorData = value.data;
      onSelectedDateClick(selectedDay.value, 0);
      rescheduleAppointment();
      update();
    });
  }

  void rescheduleAppointment() {
    selectedAppointmentType = appointmentData?.type ?? 0;
    if (appointmentData?.patientId != null) {
      selectedPatient = patientList.firstWhere(
        (element) => element?.id == appointmentData?.patientId,
        orElse: () => patientList.first,
      );
    }
    problemController = TextEditingController(text: appointmentData?.problem);
    update();
    update([kAppointmentType]);
  }
}

// ── Patient selection bottom sheet ────────────────────────────────────────────
class _PatientSelectionSheet extends StatelessWidget {
  final SelectDateTimeScreenController controller;
  const _PatientSelectionSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, color: Color(0xFF00897B), size: 22),
              const SizedBox(width: 8),
              const Text('اختر المريض',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B3C))),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const Divider(height: 20),
          ...controller.patientList.map((p) {
            final isSelected = controller.selectedPatient == p ||
                (controller.selectedPatient == null && p == controller.patientList.first);
            final isMyself = p?.id == null;
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                controller.onPatientChange(p);
                Get.back();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? const Color(0xFF00897B).withValues(alpha: .1)
                      : Colors.grey.shade50,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00897B)
                        : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isSelected
                          ? const Color(0xFF00897B)
                          : Colors.grey.shade300,
                      child: Text(
                        (p?.fullname ?? '؟').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p?.fullname ?? '',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: isSelected
                                    ? const Color(0xFF00897B)
                                    : const Color(0xFF1A2B3C)),
                          ),
                          if (!isMyself && p?.relation != null)
                            Text(
                              p!.relation ?? '',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          if (isMyself)
                            Text(
                              'أنت',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade500),
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF00897B), size: 22),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          // ── Add new family member ──
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => controller.onAddFamilyMemberTap(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF00897B).withValues(alpha: .4),
                    style: BorderStyle.solid,
                    width: 1.5),
                color: const Color(0xFF00897B).withValues(alpha: .05),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt_1_rounded,
                      color: Color(0xFF00897B), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'إضافة فرد من العائلة',
                    style: TextStyle(
                        color: Color(0xFF00897B),
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add family member bottom sheet ────────────────────────────────────────────
class _AddFamilyMemberSheet extends StatefulWidget {
  final SelectDateTimeScreenController controller;
  const _AddFamilyMemberSheet({required this.controller});
  @override
  State<_AddFamilyMemberSheet> createState() => _AddFamilyMemberSheetState();
}

class _AddFamilyMemberSheetState extends State<_AddFamilyMemberSheet> {
  String _gender = 'ذكر';

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add_alt_1_rounded,
                  color: Color(0xFF00897B), size: 22),
              const SizedBox(width: 8),
              const Text('إضافة فرد من العائلة',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B3C))),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Get.back()),
            ],
          ),
          const Divider(height: 20),
          _buildField('الاسم الكامل *', c.familyNameController,
              hint: 'مثال: أحمد محمد'),
          const SizedBox(height: 12),
          _buildField('العمر *', c.familyAgeController,
              hint: 'مثال: 25',
              inputType: TextInputType.number),
          const SizedBox(height: 12),
          _buildField('صلة القرابة *', c.familyRelationController,
              hint: 'مثال: ابن / ابنة / أم / أب'),
          const SizedBox(height: 14),
          // Gender selector
          Row(
            children: [
              const Text('الجنس',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2B3C),
                      fontSize: 14)),
              const SizedBox(width: 16),
              _genderChip('ذكر', Icons.male_rounded),
              const SizedBox(width: 8),
              _genderChip('أنثى', Icons.female_rounded),
            ],
          ),
          const SizedBox(height: 20),
          GetBuilder<SelectDateTimeScreenController>(
            init: c,
            builder: (ctrl) => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ctrl.isAddingFamilyMember
                    ? null
                    : () => ctrl.submitFamilyMember(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: ctrl.isAddingFamilyMember
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('إضافة',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderChip(String label, IconData icon) {
    final selected = _gender == label;
    return GestureDetector(
      onTap: () {
        setState(() => _gender = label);
        widget.controller.familyGender = label;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: selected
              ? const Color(0xFF00897B)
              : Colors.grey.shade100,
          border: Border.all(
              color: selected
                  ? const Color(0xFF00897B)
                  : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: selected ? Colors.white : Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {String hint = '', TextInputType inputType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2B3C),
                fontSize: 14)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: inputType,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: Color(0xFF00897B), width: 1.5)),
          ),
        ),
      ],
    );
  }
}
