import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/my_text_style.dart';

class FancyButton extends StatefulWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;
  final VoidCallback onVideoTap;
  final VoidCallback? onFileTap;
  final VoidCallback? onAudioTap;
  final bool isOpen;

  const FancyButton({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
    required this.onVideoTap,
    this.onFileTap,
    this.onAudioTap,
    required this.isOpen,
  });

  @override
  State<FancyButton> createState() => FancyButtonState();
}

class FancyButtonState extends State<FancyButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // late Animation<Color?> _buttonColor;
  // late Animation<double> _animateIcon;
  late Animation<double> _translateButton;
  final Curve _curve = Curves.linear;
  final double _fabHeight = 38.0;
  bool isOpened = false;

  @override
  initState() {
    isOpened = widget.isOpen;
    setState(() {});
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    // _animateIcon =
    //     Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    // _buttonColor = ColorTween(
    //   begin: Colors.blue,
    //   end: Colors.red,
    // ).animate(CurvedAnimation(
    //   parent: _animationController,
    //   curve: const Interval(
    //     0.00,
    //     1.00,
    //     curve: Curves.linear,
    //   ),
    // ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        1.0,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  void animate() {
    if (!isOpened) {
      FocusManager.instance.primaryFocus?.unfocus();
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget inbox({required IconData icon, required VoidCallback onTap, required double value}) {
    return Transform(
      transform: Matrix4.translationValues(
        0.0,
        _translateButton.value * value,
        0.0,
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 37,
          width: 37,
          decoration: BoxDecoration(
            gradient: MyTextStyle.linearTopGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: isOpened ? ColorRes.grey : ColorRes.transparent, blurRadius: 5, spreadRadius: 2),
            ],
          ),
          margin: EdgeInsets.only(bottom: isOpened ? 10 : 0),
          child: Icon(icon, color: ColorRes.white),
        ),
      ),
    );
  }

  Widget toggle() {
    return InkWell(
      onTap: animate,
      child: Container(
        height: 40,
        width: 40,
        decoration: const BoxDecoration(
          gradient: MyTextStyle.linearTopGradient,
          shape: BoxShape.circle,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, anim) {
            return RotationTransition(
              turns: child.key == const ValueKey('icon1')
                  ? Tween<double>(begin: 1, end: 0.75).animate(anim)
                  : Tween<double>(begin: 0.75, end: 1).animate(anim),
              child: ScaleTransition(scale: anim, child: child),
            );
          },
          child: !isOpened
              ? const Icon(
                  Icons.attachment_rounded,
                  color: ColorRes.white,
                  key: ValueKey('icon1'),
                )
              : const Icon(
                  Icons.close,
                  color: ColorRes.white,
                  key: ValueKey('icon2'),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (widget.onAudioTap != null)
            inbox(icon: Icons.mic_rounded, onTap: widget.onAudioTap!, value: 5.0),
          if (widget.onFileTap != null)
            inbox(icon: Icons.attach_file_rounded, onTap: widget.onFileTap!, value: 4.0),
          inbox(icon: Icons.camera_alt_rounded, onTap: widget.onCameraTap, value: 3.0),
          inbox(icon: Icons.image, onTap: widget.onGalleryTap, value: 2.0),
          inbox(icon: Icons.videocam_rounded, onTap: widget.onVideoTap, value: 1.0),
          toggle(),
        ],
      ),
    );
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
