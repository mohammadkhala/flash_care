import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/model/chat/chat.dart';
import 'package:patient_flutter/model/doctor/doctor_review.dart';
import 'package:patient_flutter/model/doctor/fetch_doctor.dart';
import 'package:patient_flutter/model/reels/reels.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/screen/message_chat_screen/message_chat_screen.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/urls.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorProfileScreenController extends GetxController {
  List<String> list = [
    S.current.details,
    S.current.reels,
    S.current.reviews,
    S.current.education,
    S.current.experience,
    S.current.awards,
    'إحصائيات',
  ];
  int selectedCategoryIndex = 0;
  int start = 0;
  ScrollController scrollController = ScrollController();
  double maxExtent = 300.0;
  double currentExtent = 300.0;
  bool isExpertiseShowMore = false;
  bool isServiceShowMore = false;
  bool isPosition = false;
  bool isLoading = false;
  List<DoctorReviewData> review = [];
  DoctorData? doctorData;
  UserData? userData;
  bool isFavouriteId = false;
  bool isBackFavDoc = false;
  RxBool isReelLoading = false.obs;
  bool hasNoMoreReel = false;

  RxList<Reel> reels = <Reel>[].obs;

  DoctorProfileScreenController(this.doctorData);

  @override
  void onInit() {
    prefData();
    getDoctorProfile();
    initScrollController();
    super.onInit();
  }

  Future<void> getDoctorProfile() async {
    isLoading = true;
    await ApiService.instance
        .fetchDoctorProfile(doctorId: doctorData?.id)
        .then((value) {
      doctorData = value.data;
      isLoading = false;
      update();
    });
    fetchDoctorReviewsApiCall();
    fetchDoctorReels();
  }

  void fetchDoctorReviewsApiCall() {
    ApiService.instance
        .fetchDoctorReviews(doctorId: doctorData?.id, start: review.length)
        .then(
      (value) {
        review.addAll(value.data!);
        update();
      },
    );
  }

  void onExpertiseShowMoreTap() {
    isExpertiseShowMore = !isExpertiseShowMore;
  }

  void onServicesShowMoreTap() {
    isServiceShowMore = !isServiceShowMore;
  }

  void onCategoryChange(int index) {
    selectedCategoryIndex = index;
    update();
  }

  void initScrollController() {
    scrollController.addListener(() {
      currentExtent = maxExtent - scrollController.offset;
      if (currentExtent < 0) currentExtent = 0.0;
      if (currentExtent > maxExtent) currentExtent = maxExtent;
      update();
      if (scrollController.offset ==
          scrollController.position.maxScrollExtent) {
        fetchDoctorReviewsApiCall();
      }
    });
  }

  void prefData() async {
    userData = SessionManager.instance.getUser();
    isFavouriteId =
        userData?.favouriteDoctors?.contains('${doctorData?.id}') ?? false;
    update();
  }

  void updateProfileApiCall() {
    isFavouriteId = !isFavouriteId;
    String? savedProfile = userData?.favouriteDoctors;
    List<String> savedId = [];
    if (savedProfile == null || savedProfile.isEmpty) {
      savedProfile = doctorData?.id.toString();
    } else {
      savedId = savedProfile.split(',');
      if (savedProfile.contains('${doctorData?.id}')) {
        savedId.remove(doctorData?.id.toString());
      } else {
        savedId.add(doctorData?.id.toString() ?? '-1');
      }
      savedProfile = savedId.join(',');
    }

    ApiService.instance
        .updateUserDetails(favouriteDoctors: savedProfile)
        .then((value) {
      userData = value.data;
      isFavouriteId = value.data?.favouriteDoctors
              ?.contains(doctorData?.id.toString() ?? '-1') ??
          false;
      isBackFavDoc = true;
      update();
    });
  }

  void onChatBtnTap() {
    ChatUser chatUser = ChatUser(
        image: doctorData?.image,
        designation: doctorData?.designation,
        msgCount: 0,
        userid: doctorData?.id,
        userIdentity: CommonFun.setDoctorId(doctorId: doctorData?.id),
        userMail: doctorData?.identity,
        username: doctorData?.name);
    Conversation conversation = Conversation(
        time: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: CommonFun.getConversationId(
            patient: userData?.id, doctor: doctorData?.id),
        deletedId: '',
        isDeleted: false,
        lastMsg: '',
        deviceType: doctorData?.deviceType,
        inTheChat: 0,
        user: chatUser);
    Get.to(() =>
        MessageChatScreen(conversation: conversation, userData: userData));
  }

  void onCallBtnTap() {
    print(doctorData?.mobileNumber?.split(' ')[0]);
    print(doctorData?.mobileNumber);
    launchUrl(Uri.parse('tel:${doctorData?.mobileNumber?.split(' ')[0]}'));
  }

  void fetchDoctorReels() {
    if (hasNoMoreReel) return;
    isReelLoading.value = true;
    ApiService.instance.call(
        url: Urls.fetchDoctorReels,
        completion: (response) {
          Reels data = Reels.fromJson(response);
          if (data.status == true) {
            reels.addAll(data.data ?? []);
          }
          if ((data.data?.length ?? 0) < paginationLimit) {
            hasNoMoreReel = true;
          }
          isReelLoading.value = false;
        },
        param: {
          pDoctorId: doctorData?.id,
          pStart: reels.length,
          pCount: paginationLimit,
          pUserId: SessionManager.instance.getUserID()
        });
  }
}
