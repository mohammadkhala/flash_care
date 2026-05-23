import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:patient_flutter/common/common_fun.dart';
import 'package:patient_flutter/common/custom_ui.dart';
import 'package:patient_flutter/common/dashboard_top_bar_title.dart';
import 'package:patient_flutter/generated/l10n.dart';
import 'package:patient_flutter/screen/appointment_screen/appointment_screen.dart';
import 'package:patient_flutter/screen/help_and_faq_screen/help_and_faq_screen.dart';
import 'package:patient_flutter/screen/languages_screen/languages_screen.dart';
import 'package:patient_flutter/screen/manage_patient_screen/manage_patient_screen.dart';
import 'package:patient_flutter/screen/notification_screen/notification_screen.dart';
import 'package:patient_flutter/screen/prescription_screen/prescription_screen.dart';
import 'package:patient_flutter/screen/profile_screen/profile_screen_controller.dart';
import 'package:patient_flutter/screen/profile_screen/widget/delete_account_sheet.dart';
import 'package:patient_flutter/screen/profile_screen/widget/switch_card.dart';
import 'package:patient_flutter/screen/saved_doctor_screen/saved_doctor_screen.dart';
import 'package:patient_flutter/screen/saved_reels_screen/saved_reels_screen.dart';
import 'package:patient_flutter/screen/wallet_screen/wallet_screen.dart';
import 'package:patient_flutter/screen/withdraw_history_screen/withdraw_history_screen.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';
import 'package:patient_flutter/utils/update_res.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileScreenController());
    return Column(
      children: [
        GetBuilder(
            init: controller,
            builder: (context) {
              return DashboardTopBarTitle(title: S.current.profile);
            }),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Gradient profile header ──────────────────────────────
                GetBuilder(
                  id: kProfileUpdate,
                  init: controller,
                  builder: (context) {
                    return Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00897B), Color(0xFF004D40)],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          children: [
                            // Avatar with white ring
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .3),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: controller.userData?.profileImage != null
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            '${ConstRes.itemBaseURL}${controller.userData?.profileImage}',
                                        width: 84,
                                        height: 84,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, error, stackTrace) {
                                          return CustomUi.userPlaceHolder(
                                              gender: controller.userData?.gender ?? 0,
                                              height: 84);
                                        },
                                      )
                                    : CustomUi.userPlaceHolder(
                                        gender: controller.userData?.gender ?? 0, height: 84),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              controller.userData?.fullname ?? S.current.unKnown,
                              style: MyTextStyle.montserratExtraBold(
                                size: 20,
                                color: ColorRes.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.userData?.identity ?? '',
                              style: MyTextStyle.montserratLight(
                                size: 14,
                                color: Colors.white.withValues(alpha: .8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: controller.onEditProfileNavigate,
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .2),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .4),
                                  ),
                                ),
                                child: Text(
                                  S.current.editDetails,
                                  style: MyTextStyle.montserratMedium(
                                    size: 13,
                                    color: ColorRes.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // ── Push notification toggle card ────────────────────────
                GetBuilder(
                  id: kNotificationUpdate,
                  init: controller,
                  builder: (controller) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: ColorRes.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SwitchCard(
                        title: S.current.pushNotification,
                        title2: S.current.keepItOnIfYou,
                        alignment: controller.isNotification
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        enable: controller.isNotification,
                        onTap: controller.onNotificationTap,
                        onNotificationTap: () {
                          Get.to(() => const NotificationScreen());
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ── Section 1: الحساب ────────────────────────────────────
                _SectionHeader(title: 'الحساب'),
                GetBuilder(
                    init: controller,
                    builder: (context) {
                      return Column(
                        children: [
                          _ModernMenuItem(
                            title: S.current.savedDoctors,
                            icon: Icons.bookmark_rounded,
                            iconBg: const Color(0xFFE0F2F1),
                            iconColor: const Color(0xFF00897B),
                            onTap: () => Get.to(() => const SavedDoctorScreen()),
                          ),
                          _ModernMenuItem(
                            title: S.current.wallet,
                            icon: Icons.account_balance_wallet_rounded,
                            iconBg: const Color(0xFFFFF8E1),
                            iconColor: const Color(0xFFF59E0B),
                            onTap: () => Get.to(() => const WalletScreen()),
                          ),
                          _ModernMenuItem(
                            title: S.current.withdrawRequests,
                            icon: Icons.currency_exchange_rounded,
                            iconBg: const Color(0xFFE3F2FD),
                            iconColor: const Color(0xFF1E88E5),
                            onTap: () => Get.to(() => const WithdrawHistoryScreen()),
                          ),
                        ],
                      );
                    }),

                const SizedBox(height: 16),

                // ── Section 2: الخدمات ───────────────────────────────────
                _SectionHeader(title: 'الخدمات'),
                GetBuilder(
                    init: controller,
                    builder: (context) {
                      return Column(
                        children: [
                          _ModernMenuItem(
                            title: S.current.appointments,
                            icon: Icons.calendar_today_rounded,
                            iconBg: const Color(0xFFF3E5F5),
                            iconColor: const Color(0xFF8E24AA),
                            onTap: () => Get.to(() => AppointmentScreen(screenType: 1)),
                          ),
                          _ModernMenuItem(
                            title: S.current.managePatients,
                            icon: Icons.people_rounded,
                            iconBg: const Color(0xFFE8F5E9),
                            iconColor: const Color(0xFF43A047),
                            onTap: () => Get.to(() => const ManagePatientScreen()),
                          ),
                          _ModernMenuItem(
                            title: S.current.prescriptions,
                            icon: Icons.medical_services_rounded,
                            iconBg: const Color(0xFFE0F2F1),
                            iconColor: const Color(0xFF00897B),
                            onTap: () => Get.to(() => const PrescriptionScreen()),
                          ),
                          _ModernMenuItem(
                            title: S.current.savedReels,
                            icon: Icons.play_circle_rounded,
                            iconBg: const Color(0xFFFCE4EC),
                            iconColor: const Color(0xFFE91E63),
                            onTap: () => Get.to(() => const SavedReelsScreen()),
                          ),
                        ],
                      );
                    }),

                const SizedBox(height: 16),

                // ── Section 3: الإعدادات ─────────────────────────────────
                _SectionHeader(title: 'الإعدادات'),
                GetBuilder(
                    init: controller,
                    builder: (context) {
                      return Column(
                        children: [
                          _ModernMenuItem(
                            title: S.current.languages.capitalize ?? '',
                            icon: Icons.language_rounded,
                            iconBg: const Color(0xFFE8EAF6),
                            iconColor: const Color(0xFF3949AB),
                            onTap: () => Get.to(() => const LanguagesScreen()),
                          ),
                          _ModernMenuItem(
                            title: S.current.termsOfUse,
                            icon: Icons.description_rounded,
                            iconBg: ColorRes.whiteSmoke,
                            iconColor: ColorRes.battleshipGrey,
                            onTap: () async => CommonFun.loadUrl(url: ConstRes.termsOfUse),
                          ),
                          _ModernMenuItem(
                            title: S.current.privacyPolicy,
                            icon: Icons.privacy_tip_rounded,
                            iconBg: ColorRes.whiteSmoke,
                            iconColor: ColorRes.battleshipGrey,
                            onTap: () async => CommonFun.loadUrl(url: ConstRes.privacyPolicy),
                          ),
                          _ModernMenuItem(
                            title: S.current.helpAndFAQ,
                            icon: Icons.help_rounded,
                            iconBg: const Color(0xFFFFF3E0),
                            iconColor: const Color(0xFFF57C00),
                            onTap: () => Get.to(() => const HelpAndFaqScreen()),
                          ),
                        ],
                      );
                    }),

                const SizedBox(height: 16),

                // ── Section 4: Danger zone ───────────────────────────────
                GetBuilder(
                    init: controller,
                    builder: (context) {
                      return Column(
                        children: [
                          _ModernMenuItem(
                            title: S.current.logout,
                            icon: Icons.logout_rounded,
                            iconBg: const Color(0xFFFFF3E0),
                            iconColor: const Color(0xFFF57C00),
                            onTap: () {
                              Get.bottomSheet(
                                  DeleteAccountSheet(
                                    onDeleteContinueTap: controller.onLogoutTap,
                                    title: S.current.logout,
                                    description: S.current.doYouReallyWantToLogoutEtc,
                                  ),
                                  isScrollControlled: true);
                            },
                          ),
                          _ModernMenuItem(
                            title: S.current.deleteMyAccount,
                            icon: Icons.delete_rounded,
                            iconBg: const Color(0xFFFFEBEE),
                            iconColor: const Color(0xFFE53935),
                            onTap: () {
                              Get.bottomSheet(
                                  DeleteAccountSheet(
                                    onDeleteContinueTap: controller.onDeleteContinueTap,
                                    title: S.current.deleteMyAccount,
                                    description: S.current.doYouReallyWantToEtc,
                                  ),
                                  isScrollControlled: true);
                            },
                          ),
                        ],
                      );
                    }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          style: MyTextStyle.montserratSemiBold(
            size: 13,
            color: ColorRes.battleshipGrey,
          ),
        ),
      ),
    );
  }
}

class _ModernMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ModernMenuItem({
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: ColorRes.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: MyTextStyle.montserratMedium(size: 15, color: ColorRes.charcoalGrey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: ColorRes.silver,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
