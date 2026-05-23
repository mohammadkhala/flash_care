import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/fancy_button.dart';
import 'package:doctor_flutter/common/image_send_sheet.dart';
import 'package:doctor_flutter/common/video_upload_dialog.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/appointment/appointment_request.dart';
import 'package:doctor_flutter/model/chat/appointment_chat.dart';
import 'package:doctor_flutter/screen/video_call_screen/video_call_screen.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/firebase_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

class AppointmentChatScreenController extends GetxController {
  TextEditingController msgController = TextEditingController();
  TextEditingController sendMediaController = TextEditingController();
  FocusNode msgFocusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  List<AppointmentChat> chatData = [];
  int start = 15;
  AppointmentData? appointmentData;
  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference? collection;
  bool isOpen = false;
  GlobalKey<FancyButtonState> key = GlobalKey<FancyButtonState>();
  final ImagePicker _picker = ImagePicker();
  String? imageUrl;
  String? videoUrl;
  final now = DateTime.now();
  static String appointmentId = '';

  AppointmentChatScreenController(this.appointmentData);

  @override
  void onInit() {
    appointmentId = appointmentData?.appointmentNumber ?? '';
    initFirebase();
    super.onInit();
  }

  void initFirebase() async {
    collection = db
        .collection(FirebaseRes.appointmentChat)
        .doc(appointmentData?.appointmentNumber ?? '')
        .collection(FirebaseRes.chat);
    getChat();
    scrollToFetchData();
  }

  void sendTextMsg() {
    if (msgController.text.isNotEmpty) {
      sendChatMessage(
          msgType: FirebaseRes.text, msg: msgController.text.trim());
      msgController.clear();
    }
  }

  Future<void> sendChatMessage({String? msg,
    required String msgType,
    String? image,
    String? videoCallTime,
    String? video}) async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    await collection?.doc(time).set(
          AppointmentChat(
            id: time,
            image: image,
            msg: msg,
            msgType: msgType,
            video: video,
            videoCall: VideoCall(
              time: videoCallTime,
              isStarted: true,
              patientName: appointmentData?.user?.fullname ?? S.current.unKnown,
              channelId: appointmentData?.appointmentNumber,
              patientImage: appointmentData?.user?.profileImage ?? '',
              token: '',
            ),
            senderUser: ChatUser(
              name: appointmentData?.doctor?.name ?? S.current.unKnown,
              userId: appointmentData?.doctor?.id,
              image: appointmentData?.doctor?.image,
              identity: appointmentData?.doctor?.identity,
              dob: '',
            ),
          ).toJson(),
        );
    if (appointmentData?.user?.isNotification == 1) {
      Map<String, dynamic> map = {};

      map[nTitle] = appointmentData?.appointmentNumber ?? '';
      map[nBody] = msgType == FirebaseRes.image
          ? '🖼️ ${FirebaseRes.image}'
          : msgType == FirebaseRes.video
              ? '🎥 ${FirebaseRes.video}'
              : msgType == FirebaseRes.videoCall
                  ? '${appointmentData?.doctor?.name} ${S.current.askingYouToVideoConsultation}'
                  : '$msg';
      map[nAppointmentId] = appointmentData?.appointmentNumber;
      map[nNotificationType] = '1';

      log('DeviceToken User : ${appointmentData?.user?.deviceToken}');
      ApiService().pushNotification(
          data: map,
          token: appointmentData?.user?.deviceToken ?? '',
          deviceType: appointmentData?.user?.deviceType);
    }
  }

  void scrollToFetchData() {
    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        getChat();
      }
    });
  }

  void getChat() async {
    collection
        ?.orderBy(FirebaseRes.id, descending: true)
        .limit(start)
        .withConverter(
          fromFirestore: AppointmentChat.fromFireStore,
          toFirestore: (AppointmentChat value, options) {
            return value.toFireStore();
          },
        )
        .snapshots()
        .listen((event) {
      chatData = [];
      for (int i = 0; i < event.docs.length; i++) {
        chatData.add(event.docs[i].data());
      }
      start += 5;
      update();
    });
  }

  void onImageTap({required ImageSource source}) async {
    key.currentState?.animate();
    final XFile? galleryImage = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxHeight: maxHeight,
        maxWidth: maxWidth);
    if (galleryImage != null) {
      ApiService.instance
          .uploadFileGivePath(File(galleryImage.path))
          .then((value) {
        imageUrl = value.path;
      });
      Get.bottomSheet(
              ImageSendSheet(
                image: galleryImage.path,
                onSendMediaTap: (image) =>
                    onSendMediaTap(image: galleryImage.path, type: 0),
                sendMediaController: sendMediaController,
              ),
              isScrollControlled: true)
          .then((value) {
        sendMediaController.clear();
      });
    }
  }

  void onVideoTap() async {
    key.currentState?.animate();
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      final videoFile = File(video.path);
      int sizeInBytes = videoFile.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb <= 15) {
        CustomUi.loader();
        ApiService.instance.uploadFileGivePath(File(video.path)).then((value) {
          videoUrl = value.path;
        });
        VideoCompress.getFileThumbnail(video.path).then((value) {
          ApiService.instance.uploadFileGivePath(value).then((value) {
            imageUrl = value.path;
          });
          Get.back();
          Get.bottomSheet(
                  ImageSendSheet(
                    image: value.path,
                    onSendMediaTap: (String image) => onSendMediaTap(
                        image: value.path, type: 1, video: videoFile.path),
                    sendMediaController: sendMediaController,
                  ),
                  isScrollControlled: true)
              .then((value) {
            sendMediaController.clear();
          });
        });
      } else {
        showDialog(
          context: Get.context!,
          builder: (context) {
            return VideoUploadDialog(selectAnother: () {
              Get.back();
              onVideoTap();
            });
          },
        );
      }
    }
  }

  void allScreenTap() {
    msgFocusNode.unfocus();
    onTextFiledTap();
  }

  void onTextFiledTap() {
    if (key.currentState?.isOpened == true) {
      key.currentState?.animate();
    }
  }

  void onSendMediaTap(
      {required String image, required int type, String? video}) async {
    if (type == 0) {
      if (imageUrl == null) {
        await ApiService.instance.uploadFileGivePath(File(image)).then((value) {
          imageUrl = value.path;
        });
      }
      Get.back();
      sendChatMessage(
          msgType: FirebaseRes.image,
          msg: sendMediaController.text.trim(),
          image: imageUrl);
    } else {
      if (videoUrl == null) {
        await ApiService.instance
            .uploadFileGivePath(File(video ?? ''))
            .then((value) {
          videoUrl = value.path;
        });
      } else if (imageUrl == null) {
        await ApiService.instance.uploadFileGivePath(File(image)).then((value) {
          imageUrl = value.path;
        });
      }
      Get.back();
      sendChatMessage(
        msgType: FirebaseRes.video,
        msg: sendMediaController.text.trim(),
        image: imageUrl,
        video: videoUrl,
      );
    }
  }

  void onVideoCallBtnTap() {
    showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate:
          DateTime.utc(DateTime.now().year + 1, DateTime.now().month).subtract(
        const Duration(days: 1),
      ),
    ).then((date) {
      if (date != null) {
        showTimePicker(context: Get.context!, initialTime: TimeOfDay.now())
            .then((value) {
          if (value != null) {
            DateTime time = DateTime(
                date.year, date.month, date.day, value.hour, value.minute);
            sendChatMessage(
                msgType: FirebaseRes.videoCall,
                videoCallTime: time.millisecondsSinceEpoch.toString());
          }
        });
      }
    });
  }

  void onJoinMeeting(AppointmentChat data) {
    if (data.videoCall?.isStarted == true) {
      DateTime meetingTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(data.videoCall?.time ?? ''));
      DateTime now = DateTime.now();

      if (meetingTime.isBefore(now)) {
        VideoCall? call = data.videoCall;

        if (call?.token == null || call!.token!.isEmpty) {
          CustomUi.loader();
          ApiService.instance
              .getAgoraToken(channelName: call?.channelId ?? '')
              .then((t) {
            Get.back();
            if (t.status == true) {
              call?.token = t.token;
              collection?.doc(data.id).update(
                  {FirebaseRes.videoCall: call?.toJson()}).then((value) {
                Get.to(() => VideoCallScreen(appointmentChat: data))
                    ?.then((value) {
                  endVideoStatusUpdate(value: value, data: data, call: call);
                });
              });
            } else {
              CustomUi.snackBar(message: t.message ?? '');
            }
          });
        } else {
          Get.to(() => VideoCallScreen(appointmentChat: data))?.then((value) {
            endVideoStatusUpdate(value: value, data: data, call: call);
          });
        }
      } else {
        CustomUi.snackBar(
          message: S.current.pleaseWaitYourMeetingEtc,
        );
      }
    } else {
      CustomUi.snackBar(
        message: S.current.meetingEnd,
      );
    }
  }

  void endVideoStatusUpdate(
      {VideoCall? call, required bool value, required AppointmentChat data}) {
    if (value == true) {
      call?.isStarted = false;
    } else {
      call?.token = '';
    }

    collection?.doc(data.id).update({FirebaseRes.videoCall: call?.toJson()});
  }

  @override
  void onClose() {
    appointmentId = '';
    super.onClose();
  }
}
