import 'dart:io';

import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/screen/appointment_detail_screen/appointment_detail_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({super.key});

  @override
  State<QRViewExample> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(),
          Text(
            S.current.scanTheBookingQREtc,
            style: const TextStyle(fontSize: 15, color: ColorRes.darkJungleGreen),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Flexible(
            flex: 5,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                border: Border.all(color: ColorRes.havelockBlue, width: 3),
              ),
              child: QRView(
                key: qrKey,
                onQRViewCreated: (p0) {
                  _onQRViewCreated(p0);
                },
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      result = scanData;
      ApiService.instance.fetchAppointmentDetails(appointmentId: int.parse(result?.code ?? '-1')).then((value) {
        Get.off(() => AppointmentDetailScreen(appointmentData: value.data));
      });
    });
  }
}
