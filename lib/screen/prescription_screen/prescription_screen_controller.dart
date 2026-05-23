import 'dart:convert';

import 'package:get/get.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/appointment/prescription.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/update_res.dart';

class PrescriptionScreenController extends GetxController {
  List<Patient?> list = [
    Patient(fullname: S.current.all),
  ];
  List<Patient>? patientData;
  Patient? selectedPrescription;
  List<PrescriptionData>? prescriptionData;
  List<PrescriptionData>? tempData;

  @override
  void onInit() {
    fetchPrescriptionApiCall();
    prefData();
    super.onInit();
  }

  void fetchPrescriptionApiCall() {
    ApiService.instance.fetchMyPrescriptions().then((value) {
      prescriptionData = value.data;
      tempData = value.data;
      update();
    });
  }

  void prefData() async {
    String response = SessionManager.instance.getString(key: kPatient) ?? '';
    Iterable l = jsonDecode(response);
    patientData = List<Patient>.from(l.map((e) => Patient.fromJson(e)));
    list.addAll(patientData ?? []);
    selectedPrescription = list[0];
    update();
  }

  void onPatientChange(Patient? onChange) {
    selectedPrescription = onChange!;
    if (selectedPrescription?.id == null) {
      prescriptionData = tempData;
    } else {
      prescriptionData = [];
      prescriptionData = tempData
          ?.where((element) =>
              element.appointment?.patientId == selectedPrescription?.id)
          .toList();
    }
    update();
  }
}
