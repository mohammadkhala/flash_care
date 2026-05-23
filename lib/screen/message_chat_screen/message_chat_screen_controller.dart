import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/fancy_button.dart';
import 'package:patient_flutter/common/image_send_sheet.dart';
import 'package:patient_flutter/common/video_upload_dialog.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/ai_bot/ai_bot.dart';
import 'package:patient_flutter/model/ai_bot/content.dart';
import 'package:patient_flutter/model/chat/chat.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/firebase_res.dart';
import 'package:patient_flutter/utils/update_res.dart';

class MessageChatScreenController extends GetxController with WidgetsBindingObserver {
  TextEditingController msgController = TextEditingController();
  TextEditingController sendMediaController = TextEditingController();
  ScrollController scrollController = ScrollController();
  Conversation? conversation;
  UserData? userData;
  FirebaseFirestore db = FirebaseFirestore.instance;
  late DocumentReference documentSender;
  late DocumentReference documentReceiver;
  late CollectionReference drChatMessages;
  String firebaseUserIdentity = '';
  String firebaseDoctorIdentity = '';
  RxList<ChatMessage> chatList = <ChatMessage>[].obs;
  String deletedId = '';

  List<String> notDeletedIdentity = [];
  int documentsLimit = 20;

  StreamSubscription<QuerySnapshot<ChatMessage>>? chatStream;
  StreamSubscription<DocumentSnapshot<Conversation>>? _listenUser;

  bool isOpen = false;
  GlobalKey<FancyButtonState> key = GlobalKey<FancyButtonState>();
  final ImagePicker _picker = ImagePicker();
  String? imageUrl;
  String? videoUrl;
  List<String> timeStamp = [];
  bool isLongPress = false;
  DoctorData? doctorData;
  static String senderId = '';
  DocumentSnapshot<ChatMessage>? lastDocument;
  bool hasMore = true;
  bool isFetchingData = false;
  List<AiBot> chatGptConversation = [];
  RxBool isChatGptResponse = false.obs;
  RxBool isGenerateResponse = false.obs;

  MessageChatScreenController({required this.conversation, required this.userData});

  @override
  void onInit() {
    senderId = conversation?.conversationId ?? '';
    chatGptConversation = [];

    fetchDoctorProfile();
    initFireBase();
    WidgetsBinding.instance.addObserver(this);
    super.onInit();
  }

  void initFireBase() async {
    firebaseDoctorIdentity = CommonFun.setDoctorId(doctorId: conversation?.user?.userid);
    firebaseUserIdentity = CommonFun.setPatientId(patientId: userData?.id);

    documentReceiver = db
        .collection(FirebaseRes.userChatList)
        .doc(firebaseDoctorIdentity)
        .collection(FirebaseRes.userList)
        .doc(firebaseUserIdentity);
    documentSender = db
        .collection(FirebaseRes.userChatList)
        .doc(firebaseUserIdentity)
        .collection(FirebaseRes.userList)
        .doc(firebaseDoctorIdentity);

    drChatMessages = db
        .collection(FirebaseRes.chat)
        .doc(conversation?.conversationId)
        .collection(FirebaseRes.chat);
    getChat();
    updateDeviceType(inChatRoom: 1);
    listenConversationUser();
    onScrollToFetchData();
  }

  updateDeviceType({int? inChatRoom}) {
    documentReceiver
        .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (value, options) => value.toFirestore())
        .get()
        .then(
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
          conversation = value.data();
          deletedId = value.data()?.deletedId.toString() ?? '';
          print('Update user');
        }
      }
    });
  }

  void onSendBtnTap() async {
    if (msgController.text.isNotEmpty) {
      if (conversation?.user?.userid != 0) {
        chatMessage(msgType: FirebaseRes.text, msg: msgController.text.trim());
      } else {
        sendChatBot(msgController.text.trim());
      }

      msgController.clear();
      update();
    }
  }

  void sendChatBot(String question) {
    String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

    // Prepare user identity
    List<String> notDeletedIdentity = [firebaseUserIdentity, firebaseDoctorIdentity];

    // Add user's question to the chat list
    drChatMessages.doc(currentTime).set(
          ChatMessage(
            notDeletedIdentities: notDeletedIdentity,
            senderUser: buildChatUser(),
            msgType: FirebaseRes.text,
            msg: question,
            id: currentTime,
          ).toJson(),
        );

    // Add the response to the conversation
    chatGptConversation.add(AiBot(role: 'user', content: question));

    var finalList = chatGptConversation.reversed.toList().take(2).toList() +
        [AiBot(role: chatGptRole, content: chatGptFirstPrompt(conversation?.user?.username))];

    // print('================================\n');
    // for (var element in finalList.reversed) {
    //   print(
    //       'Role : ${element.role}\n content: ${element.content}\n\t\t-------\n');
    // }
    // print('\n================================');

    isGenerateResponse.value = true;
    // Make API call to get AI's response
    ApiService.instance.chatCompletion(
      model: 'gpt-4o-mini',
      content: finalList.reversed.toList(),
      token: conversation?.user?.userMail ?? '',
      completion: (response) {
        try {
          Content content = Content.fromJson(response);
          if (content.error != null) {
            CustomUi.snackBar(message: content.error?.message ?? '');
            return;
          }
          final aiResponse = content.choices?.first.message?.content;
          if (aiResponse != null) {
            String responseTime = DateTime.now().millisecondsSinceEpoch.toString();
            // Add AI response to Firestore
            drChatMessages.doc(responseTime).set(
                  ChatMessage(
                    notDeletedIdentities: notDeletedIdentity,
                    senderUser: buildChatUser(isAI: true),
                    msgType: FirebaseRes.text,
                    msg: aiResponse,
                    id: responseTime,
                  ).toJson(),
                );

            chatGptConversation.add(AiBot(
                role: content.choices?.first.message?.role ?? chatGptRole, content: aiResponse));
            chatGptConversation.add(AiBot(role: 'user', content: question));
            isGenerateResponse.value = false;
          }
        } catch (e) {
          log('Error processing AI response: $e');
          CustomUi.snackBar(message: "An error occurred while fetching the AI response.");
        }
      },
    );
  }

  ChatUser buildChatUser({bool isAI = false}) {
    return ChatUser(
      username: isAI ? conversation?.user?.username : userData?.fullname,
      msgCount: 0,
      userid: isAI ? conversation?.user?.userid : userData?.id,
      userIdentity: isAI ? firebaseDoctorIdentity : firebaseUserIdentity,
      userMail: isAI ? conversation?.user?.userMail : userData?.identity,
      image: isAI ? conversation?.user?.image : userData?.profileImage,
      age: '0',
      gender: '0',
    );
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

  onScrollToFetchData() {
    scrollController.addListener(() {
      if (scrollController.offset == scrollController.position.maxScrollExtent) {
        fetchChatList();
      }
    });
  }

  void getChat() async {
    chatStream = drChatMessages
        .where(FirebaseRes.noDeleteIdentity, arrayContains: firebaseUserIdentity)
        .where(FirebaseRes.id, isGreaterThan: deletedId.isEmpty ? '0' : deletedId)
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
                if (chatList.isEmpty) {
                  log('Added: ${data.id}');

                  chatGptConversation.add(AiBot(
                      role: element.doc.data()?.senderUser?.userid == 0 ? chatGptRole : 'user',
                      content: element.doc.data()?.msg));
                }
                chatList.add(data);
                isUpdated = true;
                break;

              case DocumentChangeType.modified:
                log('Modified: ${data.id}');
                int index = chatList.indexWhere((message) => message.id == data.id);
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
    print('Fetching chat list...');
    if (!hasMore) {
      print('No more data to fetch.');
      return;
    }
    if (isFetchingData) {
      print('Data is already being fetched.');
      return;
    }

    isFetchingData = true;

    try {
      Query<ChatMessage> query = drChatMessages
          .where(FirebaseRes.noDeleteIdentity, arrayContains: firebaseUserIdentity)
          .where(FirebaseRes.id, isGreaterThan: deletedId.isEmpty ? '0' : deletedId)
          .withConverter(
            fromFirestore: (snapshot, options) => ChatMessage.fromJson(snapshot.data()!),
            toFirestore: (ChatMessage value, options) => value.toJson(),
          )
          .orderBy(FirebaseRes.id, descending: true)
          .limit(documentsLimit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot<ChatMessage?> querySnapshot = await query.get();

      // Debugging Logs
      print('Fetched ${querySnapshot.docs.length} documents.');

      if (querySnapshot.docs.length < documentsLimit) {
        hasMore = false;
        print('No more documents available.');
      }

      if (querySnapshot.docs.isEmpty) {
        print('No documents found.');
        return;
      }

      lastDocument = querySnapshot.docs.last as DocumentSnapshot<ChatMessage>?;

      for (var element in querySnapshot.docs) {
        chatList.add(element.data()!);
      }

      print('Chat data updated. Total chats: ${chatList.length}');
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      isFetchingData = false;
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

  ///Firebase message update method
  Future<void> chatMessage(
      {required String msgType, String? msg, String? image, String? video}) async {
    final String time = DateTime.now().millisecondsSinceEpoch.toString();
    final List<String> notDeletedIdentity = [firebaseUserIdentity, firebaseDoctorIdentity];

    // Save the chat message
    final chatMessage = ChatMessage(
      notDeletedIdentities: notDeletedIdentity,
      senderUser: ChatUser(
        username: userData?.fullname,
        msgCount: 0,
        userid: userData?.id,
        userIdentity: firebaseUserIdentity,
        userMail: userData?.identity,
        image: userData?.profileImage,
        age: (userData?.dob != null && userData!.dob!.isNotEmpty)
            ? CommonFun.calculateAge(userData?.dob).toString()
            : null,
        gender: userData?.gender == 0 ? S.current.female : S.current.male,
      ),
      msgType: msgType,
      msg: msg,
      image: image,
      video: video,
      id: time,
    );

    await drChatMessages.doc(time).set(chatMessage.toJson());

    // Handle new or existing conversations
    if (chatList.isEmpty && deletedId.isEmpty) {
      await _createNewConversation(time, msg, msgType);
    } else {
      await _updateExistingConversation(time, msg, msgType);
    }

    // Send notification to the doctor if applicable
    if (doctorData?.isNotification == 1 && conversation?.inTheChat == 0) {
      _sendNotificationToDoctor(msg, msgType);
    }
  }

  // Create a new conversation
  Future<void> _createNewConversation(String time, String? msg, String msgType) async {
    final Map<String, dynamic> updatedConversation = conversation!.toJson();
    updatedConversation[FirebaseRes.lastMsg] = _getLastMsg(message: msg, msgType: msgType);

    await documentSender.set(updatedConversation);

    final newUser = ChatUser(
      username: userData?.fullname,
      msgCount: 1,
      userid: userData?.id,
      userIdentity: firebaseUserIdentity,
      userMail: userData?.identity,
      image: userData?.profileImage,
      age: (userData?.dob != null && userData!.dob!.isNotEmpty)
          ? CommonFun.calculateAge(userData?.dob).toString()
          : null,
      gender: userData?.gender == 0 ? S.current.female : S.current.male,
    );

    final newConversation = Conversation(
        conversationId: conversation?.conversationId,
        deletedId: '',
        isDeleted: false,
        lastMsg: _getLastMsg(message: msg, msgType: msgType),
        time: time,
        user: newUser,
        deviceType: userData?.deviceType,
        inTheChat: 1);

    await documentReceiver.set(newConversation.toJson());
  }

  // Update an existing conversation
  Future<void> _updateExistingConversation(String time, String? msg, String msgType) async {
    final conversationSnapshot = await documentReceiver
        .withConverter(
          fromFirestore: Conversation.fromFirestore,
          toFirestore: (value, options) => value.toFirestore(),
        )
        .get();

    final conversationData = conversationSnapshot.data();
    final receiverUser = conversationData?.user;

    if (receiverUser != null) {
      receiverUser.msgCount = (receiverUser.msgCount ?? 0) + 1;

      await documentReceiver.update({
        FirebaseRes.time: time,
        FirebaseRes.isDeleted: false,
        FirebaseRes.lastMsg: _getLastMsg(message: msg, msgType: msgType),
        FirebaseRes.user: receiverUser.toJson(),
      });
    } else {
      await _createNewConversation(time, msg, msgType);
    }

    await documentSender.update({
      FirebaseRes.time: time,
      FirebaseRes.isDeleted: false,
      FirebaseRes.lastMsg: _getLastMsg(message: msg, msgType: msgType),
    });
  }

  // Send notification to the doctor
  void _sendNotificationToDoctor(String? msg, String msgType) {
    log('Device Token Doctor : ${doctorData?.deviceToken}');

    final Map<String, dynamic> notificationData = {
      nTitle: userData?.fullname ?? S.current.unKnown,
      nBody: _getLastMsg(message: msg, msgType: msgType),
      nSenderId: conversation?.conversationId,
      nNotificationType: '0',
    };

    ApiService().pushNotification(
      token: doctorData?.deviceToken,
      data: notificationData,
      deviceType: doctorData?.deviceType,
    );
  }

  void onImageTap({required ImageSource source}) async {
    key.currentState?.animate();

    final XFile? galleryImage = await _picker.pickImage(
        source: source, imageQuality: imageQuality, maxHeight: maxHeight, maxWidth: maxWidth);

    if (galleryImage != null) {
      ApiService.instance.uploadFileGivePath(File(galleryImage.path)).then((value) {
        imageUrl = value.path;
      });
      Get.bottomSheet(
              ImageSendSheet(
                  image: galleryImage.path,
                  onSendMediaTap: (image) => onSendMediaTap(image: galleryImage.path, type: 0),
                  sendMediaController: sendMediaController),
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
      if (sizeInMb <= 15) {
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
                  onSendMediaTap: (String image) =>
                      onSendMediaTap(image: videoThumbnail.path, type: 1, video: videoFile.path),
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

  void onSendMediaTap({required String image, required int type, String? video}) async {
    if (type == 0) {
      if (imageUrl == null) {
        await ApiService.instance.uploadFileGivePath(File(image)).then((value) {
          imageUrl = value.path;
        });
      }
      Get.back();
      chatMessage(
          msgType: FirebaseRes.image, msg: sendMediaController.text.trim(), image: imageUrl);
    } else {
      if (videoUrl == null) {
        await ApiService.instance.uploadFileGivePath(File(video ?? '')).then((value) {
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

  void onMsgDeleteBackTap() {
    timeStamp = [];
    update();
  }

  void onChatItemDelete() {
    for (int i = 0; i < timeStamp.length; i++) {
      drChatMessages.doc(timeStamp[i]).update(
        {
          FirebaseRes.noDeleteIdentity: FieldValue.arrayRemove([firebaseUserIdentity])
        },
      );
      chatList.removeWhere(
        (element) => element.id.toString() == timeStamp[i],
      );
    }
    timeStamp = [];

    update();
  }

  void fetchDoctorProfile() async {
    ApiService.instance.fetchDoctorProfile(doctorId: conversation?.user?.userid).then((value) {
      doctorData = value.data;
      print(doctorData?.toJson());
      update();
    });
  }

  Future<void> _msgCountUpdate() async {
    if (conversation?.user != null) {
      conversation?.user?.msgCount = 0;
      documentSender.update({FirebaseRes.user: conversation?.user?.toJson()});
    } else {
      await documentSender
          .withConverter(
            fromFirestore: Conversation.fromFirestore,
            toFirestore: (value, options) => value.toFirestore(),
          )
          .get()
          .then((value) {
        if (value.data()?.user != null) {
          var senderUser = value.data()?.user;
          senderUser?.msgCount = 0;
          documentSender.update({FirebaseRes.user: senderUser?.toJson()});
        }
      });
    }
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
    await _msgCountUpdate();
    msgController.dispose();
    sendMediaController.dispose();
    scrollController.dispose();
    updateDeviceType(inChatRoom: 0);
    super.onClose();
  }
}
