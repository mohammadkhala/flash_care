import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/common/fancy_button.dart';
import 'package:doctor_flutter/common/image_send_sheet.dart';
import 'package:doctor_flutter/common/video_upload_dialog.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/chat/chat.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/user/fetch_user_detail.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/firebase_res.dart';
import 'package:doctor_flutter/utils/update_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';

class MessageChatScreenController extends GetxController
    with WidgetsBindingObserver {
  TextEditingController msgController = TextEditingController();
  TextEditingController sendMediaController = TextEditingController();
  ScrollController scrollController = ScrollController();
  GlobalKey<FancyButtonState> key = GlobalKey<FancyButtonState>();
  FocusNode msgFocusNode = FocusNode();
  ImagePicker picker = ImagePicker();

  FirebaseFirestore db = FirebaseFirestore.instance;

  late DocumentReference documentSender;
  late DocumentReference documentReceiver;
  late CollectionReference drChatMessages;

  String firebaseUserIdentity = '';
  String firebaseDoctorIdentity = '';
  String? imageUrl;
  String? videoUrl;
  String deletedId = '0';
  static String senderId = '';

  RxList<ChatMessage> chatList = <ChatMessage>[].obs;
  List<String> notDeletedIdentity = [];
  List<String> timeStamp = [];

  Conversation? conversationUser;

  DoctorData? doctorData;
  User? userData;

  StreamSubscription<QuerySnapshot<ChatMessage>>? chatStream;
  StreamSubscription<DocumentSnapshot<Conversation>>? _listenUser;

  bool isLongPress = false;
  bool isOpen = false;

  DocumentSnapshot<ChatMessage>? lastDocument;
  bool hasMore = true;
  bool isFetchingData = false;
  int documentsLimit = 20;

  MessageChatScreenController(this.conversationUser, this.doctorData);

  @override
  void onInit() {
    senderId = conversationUser?.conversationId ?? '';
    fetchUserDetail();
    initFireBase();
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  void onSendBtnTap() {
    onTextFiledTap();
    if (msgController.text.isNotEmpty) {
      chatMessage(
          msgType: FirebaseRes.text, textMessage: msgController.text.trim());
      msgController.clear();
      update();
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

  void fetchUserDetail() {
    ApiService.instance
        .fetchUserDetails(userId: conversationUser?.user?.userid ?? -1)
        .then((value) {
      if (value.status == true) {
        userData = value.data;
        update();
      }
    });
  }

  void initFireBase() async {
    firebaseUserIdentity =
        CommonFun.setPatientId(patientId: conversationUser?.user?.userid);
    firebaseDoctorIdentity = CommonFun.setDoctorId(doctorId: doctorData?.id);

    documentSender = db
        .collection(FirebaseRes.userChatList)
        .doc(firebaseDoctorIdentity)
        .collection(FirebaseRes.userList)
        .doc(firebaseUserIdentity);
    documentReceiver = db
        .collection(FirebaseRes.userChatList)
        .doc(firebaseUserIdentity)
        .collection(FirebaseRes.userList)
        .doc(firebaseDoctorIdentity);

    drChatMessages = db
        .collection(FirebaseRes.chat)
        .doc(conversationUser?.conversationId)
        .collection(FirebaseRes.chat);

    updateDeviceType(inChatRoom: 1);
    getChat();
    onScrollToFetchData();
    listenConversationUser();
  }

  updateDeviceType({int? inChatRoom}) {
    documentReceiver.get().then(
      (value) {
        if (value.exists) {
          documentReceiver
              .withConverter(
                  fromFirestore: Conversation.fromFirestore,
                  toFirestore: (value, options) => value.toFirestore())
              .update({FirebaseRes.inTheChat: inChatRoom});
        }
      },
    );
  }

  listenConversationUser() async {
    _listenUser = documentSender
        .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (Conversation value, options) => value.toFirestore())
        .snapshots()
        .listen((value) {
      if (value.exists) {
        if (value.data() != null) {
          conversationUser = value.data();
          deletedId = value.data()?.deletedId.toString() ?? '';
        }
      }
    });
  }

  onScrollToFetchData() {
    scrollController.addListener(() {
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        fetchChatList();
      }
    });
  }

  void getChat() async {
    await documentSender
        .withConverter(
          fromFirestore: Conversation.fromFirestore,
          toFirestore: (Conversation value, options) {
            return value.toFirestore();
          },
        )
        .get()
        .then((value) {
      deletedId = '${value.data()?.deletedId ?? 0}';
    });

    chatStream = drChatMessages
        .where(FirebaseRes.noDeleteIdentity,
            arrayContains: firebaseDoctorIdentity)
        .where(FirebaseRes.id, isGreaterThan: deletedId)
        .orderBy(FirebaseRes.id, descending: true)
        .limit(documentsLimit)
        .withConverter(
          fromFirestore: ChatMessage.fromFirestore,
          toFirestore: (ChatMessage value, options) {
            return value.toFirestore();
          },
        )
        .snapshots()
        .listen(
      (event) async {
        try {
          bool isUpdated = false;
          for (var element in event.docChanges) {
            final data = element.doc.data();
            if (data == null) continue;
            switch (element.type) {
              case DocumentChangeType.added:
                // log('Added: ${data.id}');
                chatList.add(data);
                isUpdated = true;
                break;

              case DocumentChangeType.modified:
                log('Modified: ${data.id}');
                int index =
                    chatList.indexWhere((message) => message.id == data.id);
                if (index != -1) {
                  chatList[index] = data;
                  isUpdated = true;
                }
                break;

              case DocumentChangeType.removed:
                log('Removed: ${data.id}');
                isUpdated = true;
                break;
            }
          }

          if (isUpdated) {
            // Sort data by ID (descending order)
            chatList.sort((a, b) => b.id!.compareTo(a.id!));
            log('Chat list updated. Total messages: ${chatList.length}');
          }

          // Update lastDocument if new documents exist
          if (event.docs.isNotEmpty) {
            lastDocument = event.docs.last;
          }
        } catch (e) {
          log('Error in chatStream listener: $e');
        }
      },
    );
  }

  void fetchChatList() async {
    debugPrint('Fetching chat list...');
    if (!hasMore) {
      debugPrint('No more data to fetch.');
      return;
    }
    if (isFetchingData) {
      debugPrint('Data is already being fetched.');
      return;
    }

    isFetchingData = true;

    try {
      Query<ChatMessage> query = drChatMessages
          .where(FirebaseRes.noDeleteIdentity,
              arrayContains: firebaseUserIdentity)
          .where(FirebaseRes.id,
              isGreaterThan: deletedId.isEmpty ? '0' : deletedId)
          .withConverter(
            fromFirestore: (snapshot, options) =>
                ChatMessage.fromJson(snapshot.data()!),
            toFirestore: (ChatMessage value, options) => value.toJson(),
          )
          .orderBy(FirebaseRes.id, descending: true)
          .limit(documentsLimit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot<ChatMessage?> querySnapshot = await query.get();

      // Debugging Logs
      debugPrint('Fetched ${querySnapshot.docs.length} documents.');

      if (querySnapshot.docs.length < documentsLimit) {
        hasMore = false;
        debugPrint('No more documents available.');
      }

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No documents found.');
        return;
      }

      lastDocument = querySnapshot.docs.last as DocumentSnapshot<ChatMessage>?;

      for (var element in querySnapshot.docs) {
        chatList.add(element.data()!);
      }

      debugPrint('Chat data updated. Total chats: ${chatList.length}');
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      isFetchingData = false;
    }
  }

  ///Firebase message update method
  Future<void> chatMessage(
      {required String msgType,
      String? textMessage,
      String? image,
      String? video}) async {
    String time = DateTime.now().millisecondsSinceEpoch.toString();
    notDeletedIdentity = [];
    notDeletedIdentity.addAll(
      [firebaseUserIdentity, firebaseDoctorIdentity],
    );
    drChatMessages.doc(time).set(
          ChatMessage(
            notDeletedIdentities: notDeletedIdentity,
            senderUser: ChatUser(
              username: doctorData?.name,
              msgCount: 0,
              userid: doctorData?.id,
              userIdentity: CommonFun.setDoctorId(doctorId: doctorData?.id),
              userMail: doctorData?.identity,
              image: doctorData?.image,
              gender:
                  doctorData?.gender == 0 ? S.current.feMale : S.current.male,
              designation: doctorData?.designation,
            ),
            msgType: msgType,
            msg: textMessage,
            image: image,
            video: video,
            id: time,
          ).toJson(),
        );

    await documentReceiver
        .withConverter(
          fromFirestore: Conversation.fromFirestore,
          toFirestore: (value, options) => value.toFirestore(),
        )
        .get()
        .then((value) {
      var receiverUser = value.data()?.user;
      receiverUser?.msgCount = (receiverUser.msgCount ?? 0) + 1;
      documentReceiver.update({
        FirebaseRes.time: time,
        FirebaseRes.lastMsg:
            _getLastMsg(msgType: msgType, message: textMessage),
        FirebaseRes.user: receiverUser?.toJson(),
      });
    });
    await documentSender.update(
      {
        FirebaseRes.time: time,
        FirebaseRes.lastMsg:
            _getLastMsg(msgType: msgType, message: textMessage),
      },
    );

    if (userData?.isNotification == 1 && conversationUser?.inTheChat == 0) {
      debugPrint(
          'Push Message Notification : ${userData?.isNotification == 1 && conversationUser?.inTheChat == 0}');
      Map<String, dynamic> map = {};
      map[nSenderId] = conversationUser?.conversationId;
      map[nNotificationType] = '0';
      map[nTitle] = doctorData?.name ?? S.current.unKnown;
      map[nBody] = _getLastMsg(msgType: msgType, message: textMessage);

      ApiService()
          .pushNotification(token: '${userData?.deviceToken}', data: map);
    }
  }

  void onImageTap({required ImageSource source}) async {
    key.currentState?.animate();
    final XFile? galleryImage = await picker.pickImage(
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
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      /// calculating file size
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
          textMessage: sendMediaController.text.trim(),
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
        textMessage: sendMediaController.text.trim(),
        image: imageUrl,
        video: videoUrl,
      );
    }
  }

  /// long press to select chat method
  void onLongPress(ChatMessage? data) {
    if (!timeStamp.contains('${data?.id}')) {
      timeStamp.add('${data?.id}');
    } else {
      timeStamp.remove('${data?.id}');
    }
    isLongPress = true;
    update();
  }

  void onMsgDeleteBackTap() {
    timeStamp = [];
    update();
  }

  void onChatItemDelete() {
    for (int i = 0; i < timeStamp.length; i++) {
      drChatMessages.doc(timeStamp[i]).update({
        FirebaseRes.noDeleteIdentity:
            FieldValue.arrayRemove([firebaseDoctorIdentity])
      });
      chatList.removeWhere((element) => element.id.toString() == timeStamp[i]);
    }
    timeStamp = [];

    update();
  }

  String _getLastMsg({required String msgType, required String? message}) {
    return msgType == FirebaseRes.image
        ? '📷 ${FirebaseRes.image}'
        : msgType == FirebaseRes.video
            ? '🎥 ${FirebaseRes.video}'
            : message ?? '';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        updateDeviceType(inChatRoom: 1);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.paused:
        updateDeviceType(inChatRoom: 0);
        break;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void onClose() async {
    senderId = '';
    WidgetsBinding.instance.removeObserver(this);
    _listenUser?.cancel();
    await chatStream?.cancel();
    await documentSender
        .withConverter(
          fromFirestore: Conversation.fromFirestore,
          toFirestore: (value, options) => value.toFirestore(),
        )
        .get()
        .then((value) {
      var senderUser = value.data()?.user;
      senderUser?.msgCount = 0;
      documentSender.update({FirebaseRes.user: senderUser?.toJson()});
    });
    updateDeviceType(inChatRoom: 0);
    super.onClose();
  }
}
