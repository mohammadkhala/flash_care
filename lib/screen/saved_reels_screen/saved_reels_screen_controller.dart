import 'package:doctor_flutter/common/confirmation_dialog.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/message/api_status.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/service/api_service.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/urls.dart';
import 'package:get/get.dart';

class SavedReelsScreenController extends GetxController {

  DoctorData? doctorData;
  RxList<Reel> reels = <Reel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchSavedReels();
    super.onInit();
  }

  void fetchSavedReels() async {
    isLoading.value = true;
    doctorData = SessionManager.instance.getDoctor();

    if ((doctorData?.savedReels ?? '').isEmpty) {
      isLoading.value = false;
      return;
    }

    ApiService.instance.call(
      url: Urls.fetchSavedReels,
      param: {pIds: doctorData?.savedReels, pType: 1, pId: doctorData?.id},
      completion: (response) {
        Reels data = Reels.fromJson(response);
        if (data.status == true) {
          reels.addAll(data.data ?? []);
        }
        isLoading.value = false;
      },
    );
  }

  onDeleteReel(Reel reel) {
    Get.dialog(
      ConfirmationDialog(
        aspectRatio: 1.6,
        onPositiveTap: () {
          ApiService.instance.call(
              url: Urls.deleteReel,
              param: {pReelId: reel.id, pDoctorId: reel.doctorId},
              completion: (response) {
                ApiStatus data = ApiStatus.fromJson(response);
                if (data.status == true) {
                  reels.removeWhere(
                    (element) => element.id?.toInt() == reel.id?.toInt(),
                  );
                }
              });
        },
        title1: S.current.deletePostPermanently,
        title2: S.current.areYouSureYouWantToDeleteThisPostThis,
        positiveText: S.current.delete,
      ),
    );
  }
}
