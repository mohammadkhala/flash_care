import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/fancy_button.dart';
import 'package:patient_flutter/common/image_send_sheet.dart';
import 'package:patient_flutter/common/video_upload_dialog.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/appointment/fetch_appointment.dart';
import 'package:patient_flutter/model/chat/appointment_chat.dart';
import 'package:patient_flutter/screen/video_call_screen/video_call_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/firebase_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class AppointmentChatScreenController extends GetxController {
  TextEditingController msgController = TextEditingController();
  TextEditingController sendMediaController = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<AppointmentChat> chatData = [];
  int start = 15;
  AppointmentData? appointmentData;
  FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference? collection;
  bool isOpen = false;
  GlobalKey<FancyButtonState> key = GlobalKey<FancyButtonState>();
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? imageUrl;
  String? videoUrl;
  String? audioUrl;
  bool isRecording = false;
  String? recordingPath;
  StreamSubscription<QuerySnapshot<AppointmentChat>>? chatCollectionStream;
  static String appointmentId = '';

  @override
  void onInit() {
    appointmentData = Get.arguments;
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

  void onSendTextMsg() {
    if (msgController.text.isNotEmpty) {
      chatMessage(msgType: FirebaseRes.text, msg: msgController.text.trim());
      msgController.clear();
    }
  }

  void chatMessage(
      {String? msg,
      required String msgType,
      String? image,
      String? video,
      String? audio,
      String? file,
      String? fileName}) async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    collection?.doc(time).set(
          AppointmentChat(
            id: time,
            image: image,
            msg: msg,
            msgType: msgType,
            video: video,
            audio: audio,
            file: file,
            fileName: fileName,
            videoCall: VideoCall(),
            senderUser: AppointmentUser(
              name: appointmentData?.user?.fullname ?? '',
              userId: appointmentData?.user?.id,
              image: appointmentData?.user?.profileImage,
              identity: appointmentData?.user?.identity,
              dob: appointmentData?.user?.dob,
            ),
          ).toJson(),
        );

    if (appointmentData?.doctor?.isNotification == 1) {
      Map<String, dynamic> map = {};

      map[nTitle] = appointmentData?.appointmentNumber ?? '';
      map[nBody] = msgType == FirebaseRes.image
          ? '🖼️ صورة'
          : msgType == FirebaseRes.video
              ? '🎥 فيديو'
              : msgType == FirebaseRes.audio
                  ? '🎤 رسالة صوتية'
                  : msgType == FirebaseRes.file
                      ? '📎 ملف'
                      : '$msg';
      map[nNotificationType] = '1';
      map[nAppointmentId] = appointmentData?.appointmentNumber;

      ApiService().pushNotification(
          token: appointmentData?.doctor?.deviceToken ?? '',
          deviceType: appointmentData?.doctor?.deviceType,
          data: map);
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
    chatCollectionStream = collection
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
      /// calculating file size
      final videoFile = File(video.path);
      int sizeInBytes = videoFile.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb <= 50) {
        CustomUi.loader();
        ApiService.instance.uploadFileGivePath(File(video.path)).then((value) {
          videoUrl = value.path;
        });

        File videoThumbnail = await CommonFun.getVideoThumbnail(video.path);
        ApiService.instance.uploadFileGivePath(videoThumbnail).then((value) {
          imageUrl = value.path;
        });
        Get.back();
        Get.bottomSheet(
                ImageSendSheet(
                  image: videoThumbnail.path,
                  onSendMediaTap: (String image) => onSendMediaTap(
                      image: videoThumbnail.path,
                      type: 1,
                      video: videoFile.path),
                  sendMediaController: sendMediaController,
                ),
                isScrollControlled: true)
            .then((value) {
          sendMediaController.clear();
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

  void onSendMediaTap(
      {required String image, required int type, String? video}) async {
    if (type == 0) {
      if (imageUrl == null) {
        await ApiService.instance.uploadFileGivePath(File(image)).then((value) {
          imageUrl = value.path;
        });
      }
      Get.back();
      chatMessage(
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
      chatMessage(
        msgType: FirebaseRes.video,
        msg: sendMediaController.text.trim(),
        image: imageUrl,
        video: videoUrl,
      );
    }
  }

  void allScreenTap() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (key.currentState?.isOpened == true) {
      key.currentState?.animate();
    }
  }

  void onTextFiledTap() {
    if (key.currentState?.isOpened == true) {
      key.currentState?.animate();
    }
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
              CustomUi.infoSnackBar(t.message ?? '');
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
    if (value == false) {
      call?.token = '';
      collection?.doc(data.id).update({FirebaseRes.videoCall: call?.toJson()});
    }
  }

  void onStartRecording() async {
    final micPermission = await Permission.microphone.request();
    if (!micPermission.isGranted) {
      CustomUi.snackBar(message: Get.locale?.languageCode == 'ar'
          ? 'يُرجى السماح بالوصول للميكروفون'
          : 'Please allow microphone access');
      return;
    }
    final tempDir = Directory.systemTemp;
    recordingPath = '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: recordingPath!,
    );
    isRecording = true;
    update(['recording']);
  }

  void onStopRecording() async {
    await _audioRecorder.stop();
    isRecording = false;
    update(['recording']);
    if (recordingPath != null) {
      CustomUi.loader();
      ApiService.instance.uploadFileGivePath(File(recordingPath!)).then((value) {
        audioUrl = value.path;
        Get.back();
        chatMessage(msgType: FirebaseRes.audio, audio: audioUrl);
        audioUrl = null;
        recordingPath = null;
      });
    }
  }

  void onCancelRecording() async {
    await _audioRecorder.cancel();
    isRecording = false;
    recordingPath = null;
    update(['recording']);
  }

  void onFileTap() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.path == null) return;
    CustomUi.loader();
    ApiService.instance.uploadFileGivePath(File(picked.path!)).then((value) {
      Get.back();
      chatMessage(
        msgType: FirebaseRes.file,
        file: value.path,
        fileName: picked.name,
      );
    });
  }

  @override
  void onClose() {
    appointmentId = '';
    chatCollectionStream?.cancel();
    msgController.dispose();
    sendMediaController.dispose();
    scrollController.dispose();
    _audioRecorder.dispose();
    super.onClose();
  }
}
