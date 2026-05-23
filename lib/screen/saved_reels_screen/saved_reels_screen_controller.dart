import 'package:get/get.dart';
import 'package:patient_flutter/model/reels/reels.dart';
import 'package:patient_flutter/model/user/registration.dart';
import 'package:patient_flutter/services/api_service.dart';
import 'package:patient_flutter/services/session_manager.dart';
import 'package:patient_flutter/utils/urls.dart';

class SavedReelsScreenController extends GetxController {
  UserData? userData;
  RxList<Reel> reels = <Reel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    fetchSavedReels();
    super.onInit();
  }

  void fetchSavedReels() async {
    isLoading.value = true;
    userData = SessionManager.instance.getUser();

    if ((userData?.savedReels ?? '').isEmpty) {
      isLoading.value = false;
      return;
    }

    ApiService.instance.call(
      url: Urls.fetchSavedReels,
      param: {pIds: userData?.savedReels, pType: 0, pId: userData?.id},
      completion: (response) {
        Reels data = Reels.fromJson(response);
        if (data.status == true) {
          reels.addAll(data.data ?? []);
        }
        isLoading.value = false;
      },
    );
  }

  void onRemoveUnsavedReel() {
    final user = SessionManager.instance.getUser();
    if (user == null) return;

    final savedIds =
        user.savedReels?.split(',').where((e) => e.isNotEmpty).toList() ?? [];

    // Remove from reels any element whose id is NOT in savedIds
    reels.removeWhere((element) => !savedIds.contains('${element.id}'));

    reels.refresh();
  }
}
