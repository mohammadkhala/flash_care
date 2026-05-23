import 'package:flutter/material.dart';
import 'package:patient_flutter/utils/color_res.dart';
import 'package:patient_flutter/utils/const_res.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatFileCard extends StatelessWidget {
  final String? fileUrl;
  final String? fileName;
  final String? time;
  final Color cardColor;
  final EdgeInsets? margin;

  const ChatFileCard({
    super.key,
    this.fileUrl,
    this.fileName,
    this.time,
    this.cardColor = ColorRes.whiteSmoke,
    this.margin,
  });

  IconData _iconForFile(String? name) {
    if (name == null) return Icons.attach_file_rounded;
    final ext = name.split('.').last.toLowerCase();
    if (ext == 'pdf') return Icons.picture_as_pdf_rounded;
    if (['doc', 'docx'].contains(ext)) return Icons.description_rounded;
    if (['xls', 'xlsx'].contains(ext)) return Icons.table_chart_rounded;
    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) return Icons.image_rounded;
    return Icons.attach_file_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = fileName ?? fileUrl?.split('/').last ?? 'File';
    return InkWell(
      onTap: () async {
        final url = '${ConstRes.itemBaseURL}${fileUrl ?? ''}';
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        margin: margin ?? EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconForFile(displayName),
                  color: const Color(0xFF00897B), size: 22),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        color: ColorRes.davyGrey,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to open',
                    style: TextStyle(fontSize: 11, color: ColorRes.nobel),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.open_in_new_rounded, size: 16, color: ColorRes.nobel),
          ],
        ),
      ),
    );
  }
}
