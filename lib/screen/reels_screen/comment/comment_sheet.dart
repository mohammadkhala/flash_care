import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:doctor_flutter/common/common_fun.dart';
import 'package:doctor_flutter/common/custom_round_btn.dart';
import 'package:doctor_flutter/common/custom_ui.dart';
import 'package:doctor_flutter/generated/l10n.dart';
import 'package:doctor_flutter/model/doctorProfile/registration/registration.dart';
import 'package:doctor_flutter/model/reel/fetch_comment.dart';
import 'package:doctor_flutter/model/reel/reels.dart';
import 'package:doctor_flutter/screen/reels_screen/reel/reel_page_controller.dart';
import 'package:doctor_flutter/service/session_manager.dart';
import 'package:doctor_flutter/utils/asset_res.dart';
import 'package:doctor_flutter/utils/color_res.dart';
import 'package:doctor_flutter/utils/const_res.dart';
import 'package:doctor_flutter/utils/font_res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentSheet extends StatelessWidget {
  final Reel reelData;

  const CommentSheet({super.key, required this.reelData});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReelController>(tag: '${reelData.id}');
    return Container(
      margin: EdgeInsets.only(top: AppBar().preferredSize.height * 2.5),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        color: ColorRes.white,
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(
                left: 20.0, right: 15, bottom: 10, top: 5),
            child: Row(
              children: [
                Expanded(
                  child: Text(S.of(context).comments,
                      style: const TextStyle(
                        fontFamily: FontRes.medium,
                        fontSize: 16,
                        color: ColorRes.darkJungleGreen,
                      )),
                ),
                const CustomRoundBtn(
                    bgColor: ColorRes.greenWhite,
                    iconColor: ColorRes.battleshipGrey)
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: Obx(
              () => controller.isCommentLoading.value &&
                      controller.comments.isEmpty
                  ? CustomUi.loaderWidget()
                  : controller.comments.isEmpty
                      ? CustomUi.noDataImage(message: S.of(context).noComments)
                      : Padding(
                          padding: EdgeInsets.zero,
                          child: ListView.builder(
                            itemCount: controller.comments.length,
                            itemBuilder: (context, index) {
                              Comment comment = controller.comments[index];
                              return CommentItem(comment: comment);
                            },
                          ),
                        ),
            ),
          ),
          BottomTextFieldCustom(
            onTap: controller.onSendComment,
          ),
        ],
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: Image.network(
                '${ConstRes.itemBaseURL}${comment.commentBy?.toInt() == 0 ? (comment.user?.profileImage ?? '') : (comment.doctor?.image ?? '')}',
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return comment.commentBy?.toInt() == 0
                      ? CustomUi.userPlaceHolder(
                          male: comment.user?.gender?.toInt() ?? 1, height: 40)
                      : CustomUi.doctorPlaceHolder(
                          male: comment.user?.gender?.toInt() ?? 1, height: 40);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.commentBy?.toInt() == 0
                        ? (comment.user?.fullname ?? S.current.unKnown)
                        : (comment.doctor?.name ?? S.current.unKnown),
                    style: const TextStyle(
                        color: ColorRes.davyGrey,
                        fontFamily: FontRes.semiBold,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    CommonFun.timeAgo(DateTime.parse(comment.createdAt ?? '')),
                    style: const TextStyle(
                        color: ColorRes.starDust,
                        fontFamily: FontRes.regular,
                        fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  TextComment(text: comment.comment),
                  const SizedBox(height: 10),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 5),
        const Divider(height: 1, thickness: 1),
      ],
    );
  }
}

class TextComment extends StatelessWidget {
  final String? text;

  const TextComment({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return DetectableText(
      text: text ?? '',
      detectionRegExp: RegExp(r"\B#\w\w+"),
      basicStyle: const TextStyle(
          fontSize: 15,
          color: ColorRes.mediumGrey,
          fontFamily: FontRes.regular),
      trimMode: TrimMode.Line,
      trimLines: 5,
      trimCollapsedText: ' ${S.of(context).more}',
      trimExpandedText: '   ${S.current.less}',
      moreStyle: const TextStyle(color: ColorRes.mediumGrey, fontSize: 15),
      lessStyle: const TextStyle(color: ColorRes.mediumGrey, fontSize: 15),
    );
  }
}

class BottomTextFieldCustom extends StatefulWidget {
  final Function(String comment) onTap;

  const BottomTextFieldCustom({super.key, required this.onTap});

  @override
  State<BottomTextFieldCustom> createState() => _BottomTextFieldCustomState();
}

class _BottomTextFieldCustomState extends State<BottomTextFieldCustom> {

  DoctorData? doctorData;
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPrefData();
  }

  getPrefData() async {
    doctorData = SessionManager.instance.getDoctor();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          const Divider(height: 1, thickness: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            child: Row(
              children: [
                ClipOval(
                    child: Image.network(
                        '${ConstRes.itemBaseURL}${doctorData?.image}',
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                  return CustomUi.doctorPlaceHolder(
                      height: 40, male: doctorData?.gender ?? 1);
                })),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: ColorRes.dawnPink),
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        suffixIconConstraints: const BoxConstraints(),
                        suffixIcon: InkWell(
                          onTap: () {
                            widget.onTap(commentController.text.trim());
                            commentController.clear();
                          },
                          child: Container(
                            height: 41,
                            width: 41,
                            margin: const EdgeInsets.all(3),
                            alignment: const Alignment(.2, 0),
                            decoration: const BoxDecoration(
                                color: ColorRes.havelockBlue,
                                shape: BoxShape.circle),
                            child: Image.asset(AssetRes.icSend,
                                height: 25, width: 25),
                          ),
                        ),
                      ),
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                          fontFamily: FontRes.medium,
                          color: ColorRes.battleshipGrey,
                          fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
