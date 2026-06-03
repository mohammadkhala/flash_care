import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/agora_service.dart';
import '../../../calls/presentation/pages/video_call_page.dart';
import '../../../../core/theme/app_theme.dart';

String _fix(String? url) {
  if (url == null || url.isEmpty) return '';
  return url
      .replaceAll('localhost', '192.168.1.10')
      .replaceAll('127.0.0.1', '192.168.1.10');
}

class ChatPage extends StatefulWidget {
  final int conversationId;
  final int? newConvoPartnerId;
  final String? newConvoName;

  const ChatPage({
    required this.conversationId,
    this.newConvoPartnerId,
    this.newConvoName,
    super.key,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _msgs = [];
  bool _loading = true;
  bool _sending = false;
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  Timer? _timer;

  int? _myUserId;
  int? _convoId;
  int? _partnerId;
  String _partnerName = '';

  /// True only when this is a brand-new conversation (not yet sent any message)
  bool get _isNew => _convoId == null;

  @override
  void initState() {
    super.initState();
    _convoId     = widget.conversationId > 0 ? widget.conversationId : null;
    _partnerId   = widget.newConvoPartnerId;
    _partnerName = widget.newConvoName ?? 'المريض';
    _init();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _loadMe();
    await _loadMsgs();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => _loadMsgs(silent: true));
  }

  Future<void> _loadMe() async {
    try {
      final r = await ApiClient.instance.get('/me');
      final u = r.data['user'] as Map? ?? r.data as Map? ?? {};
      setState(() => _myUserId = u['id'] as int?);
    } catch (_) {}
  }

  Future<void> _loadMsgs({bool silent = false}) async {
    if (_isNew) {
      if (!silent) setState(() => _loading = false);
      return;
    }
    if (!silent) setState(() => _loading = true);
    try {
      final r = await ApiClient.instance.get('/messages/conversations/$_convoId');
      if (!mounted) return;
      final raw = r.data is List
          ? r.data as List
          : ((r.data['data'] ?? r.data) as List? ?? []);
      final list = raw.cast<Map<String, dynamic>>();
      // API returns newest-first. Keep that order — ListView uses reverse:true
      // so index-0 (newest) appears at the bottom automatically.
      setState(() {
        _msgs..clear()..addAll(list);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Send text ──────────────────────────────────────────────────
  Future<void> _sendText() async {
    final txt = _ctrl.text.trim();
    if (txt.isEmpty || _partnerId == null) return;
    _ctrl.clear();
    await _doSend({'content': txt, 'type': 'text'});
  }

  // ── Send media ─────────────────────────────────────────────────
  Future<void> _sendMedia(File file, String type) async {
    if (_partnerId == null) return;
    setState(() => _sending = true);
    try {
      final formData = FormData.fromMap({
        'type': type,
        'content': '',
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(Platform.pathSeparator).last,
        ),
      });
      await _doSend(formData, isForm: true);
    } catch (_) {
      if (mounted) _showErr('تعذّر إرسال الملف');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _doSend(dynamic data, {bool isForm = false}) async {
    if (_partnerId == null) return;
    setState(() => _sending = true);
    try {
      final res = await ApiClient.instance.post(
        '/messages/send/$_partnerId',
        data: data,
        options: isForm ? Options(contentType: 'multipart/form-data') : null,
      );
      if (!mounted) return;
      if (_isNew) {
        final msgObj = res.data['message'] as Map?;
        final cid = msgObj?['conversation_id'] as int?;
        if (cid != null) setState(() => _convoId = cid);
      }
      await _loadMsgs(silent: true);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?['message'] as String? ?? 'تعذّر الإرسال';
      if (mounted) _showErr(msg);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showErr(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700));

  // ── Attachment sheet ───────────────────────────────────────────
  void _showAttachSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _AttachOption(icon: Icons.camera_alt_rounded,   label: 'كاميرا',          color: AppColors.primary, onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
            _AttachOption(icon: Icons.photo_library_rounded,label: 'معرض الصور',      color: AppColors.primary, onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
            _AttachOption(icon: Icons.videocam_rounded,     label: 'تسجيل فيديو',     color: AppColors.accent,  onTap: () { Navigator.pop(context); _pickVideo(ImageSource.camera); }),
            _AttachOption(icon: Icons.video_library_rounded,label: 'مكتبة الفيديو',   color: AppColors.accent,  onTap: () { Navigator.pop(context); _pickVideo(ImageSource.gallery); }),
            _AttachOption(icon: Icons.attach_file_rounded,  label: 'ملف',             color: AppColors.textSecondary, onTap: () { Navigator.pop(context); _pickFile(); }),
          ]),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource src) async {
    final f = await ImagePicker().pickImage(source: src, imageQuality: 80);
    if (f != null) await _sendMedia(File(f.path), 'image');
  }

  Future<void> _pickVideo(ImageSource src) async {
    final f = await ImagePicker().pickVideo(source: src);
    if (f != null) await _sendMedia(File(f.path), 'video');
  }

  Future<void> _pickFile() async {
    final r = await FilePicker.platform.pickFiles();
    if (r != null && r.files.single.path != null) {
      await _sendMedia(File(r.files.single.path!), 'file');
    }
  }

  // ── Call ───────────────────────────────────────────────────────
  Future<void> _startCall({required bool isVideo}) async {
    if (_convoId == null) {
      _showErr('أرسل رسالة أولاً لبدء المحادثة');
      return;
    }
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => VideoCallPage(
        channel:  'nabdh-chat-$_convoId',
        appId:    '',
        peerName: _partnerName.isNotEmpty ? _partnerName : 'مريض',
        isVideo:  isVideo,
      ),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.surface,
      leading: const BackButton(),
      title: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(
            _partnerName.isNotEmpty ? _partnerName[0] : '؟',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          )),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(_partnerName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis)),
      ]),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_rounded),
          tooltip: 'مكالمة صوتية',
          onPressed: () => _startCall(isVideo: false),
        ),
        IconButton(
          icon: const Icon(Icons.videocam_rounded),
          tooltip: 'مكالمة فيديو',
          onPressed: () => _startCall(isVideo: true),
        ),
        const SizedBox(width: 4),
      ],
    ),
    body: Column(children: [
      // Messages list
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _msgs.isEmpty
                ? Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 56, color: AppColors.textHint),
                      const SizedBox(height: 12),
                      Text(_isNew ? 'ابدأ محادثة جديدة' : 'لا توجد رسائل بعد',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 15)),
                    ]),
                  )
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,   // index-0 = newest = bottom
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    itemCount: _msgs.length,
                    itemBuilder: (_, i) => _MessageBubble(
                      msg: _msgs[i],
                      isMe: _msgs[i]['sender_id'] == _myUserId,
                    ),
                  ),
      ),
      // Input bar
      _InputBar(
        ctrl:     _ctrl,
        sending:  _sending,
        onSend:   _sendText,
        onAttach: _showAttachSheet,
      ),
    ]),
  );
}

// ── Input bar ──────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  const _InputBar({
    required this.ctrl, required this.sending,
    required this.onSend, required this.onAttach,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
        8, 8, 8, MediaQuery.of(context).padding.bottom + 8),
    decoration: BoxDecoration(
      color: AppColors.surface,
      border: const Border(top: BorderSide(color: AppColors.border)),
    ),
    child: Row(children: [
      IconButton(
        icon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondary),
        onPressed: onAttach,
        tooltip: 'إرفاق',
      ),
      Expanded(child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: ctrl,
          maxLines: 5,
          minLines: 1,
          decoration: const InputDecoration(
            hintText: 'اكتب رسالة...',
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => onSend(),
        ),
      )),
      const SizedBox(width: 6),
      GestureDetector(
        onTap: sending ? null : onSend,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44, height: 44,
          decoration: BoxDecoration(
            gradient: sending ? null : const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary]),
            color: sending ? AppColors.border : null,
            shape: BoxShape.circle,
          ),
          child: sending
              ? const Center(child: SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
              : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        ),
      ),
    ]),
  );
}

// ── Message bubble ─────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMe;
  const _MessageBubble({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final type     = msg['type'] as String? ?? 'text';
    final content  = msg['content'] as String? ?? '';
    final mediaUrl = _fix(msg['media_url'] as String?);
    final mediaName = msg['media_name'] as String? ?? 'ملف';
    final time     = msg['created_at'] as String?;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        decoration: BoxDecoration(
          gradient: isMe
              ? const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          color: isMe ? null : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(18),
            topRight:    const Radius.circular(18),
            bottomLeft:  Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border: isMe ? null : Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(18),
            topRight:    const Radius.circular(18),
            bottomLeft:  Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (type == 'image' && mediaUrl.isNotEmpty)
              _ImageContent(url: mediaUrl)
            else if (type == 'video' && mediaUrl.isNotEmpty)
              _VideoContent(url: mediaUrl)
            else if ((type == 'file' || type == 'voice') && mediaUrl.isNotEmpty)
              _FileContent(url: mediaUrl, name: mediaName, isMe: isMe, isVoice: type == 'voice')
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                child: Text(
                  content.isNotEmpty ? content : '📎 مرفق',
                  style: TextStyle(
                    color: isMe ? Colors.white : AppColors.textPrimary,
                    fontSize: 14, height: 1.5),
                ),
              ),
            // Timestamp
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Text(
                time != null ? _fmtTime(time) : '',
                style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white60 : AppColors.textHint),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  String _fmtTime(String iso) {
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return '';
    return DateFormat('HH:mm').format(dt);
  }
}

// ── Image content ──────────────────────────────────────────────────────────
class _ImageContent extends StatelessWidget {
  final String url;
  const _ImageContent({required this.url});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => showDialog(
      context: context,
      builder: (_) => Dialog(
        child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
      ),
    ),
    child: CachedNetworkImage(
      imageUrl: url,
      width: double.infinity, height: 200,
      fit: BoxFit.cover,
      placeholder: (_, __) => const SizedBox(height: 200,
          child: Center(child: CircularProgressIndicator())),
      errorWidget: (_, __, ___) => const SizedBox(height: 80,
          child: Center(child: Icon(Icons.broken_image_rounded,
              size: 40, color: AppColors.textHint))),
    ),
  );
}

// ── Video content ──────────────────────────────────────────────────────────
class _VideoContent extends StatelessWidget {
  final String url;
  const _VideoContent({required this.url});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) launchUrl(uri);
    },
    child: Container(
      height: 160, color: Colors.black87,
      child: Stack(alignment: Alignment.center, children: [
        const Icon(Icons.play_circle_filled_rounded, size: 56, color: Colors.white),
        Positioned(
          bottom: 8, left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(4)),
            child: const Text('فيديو',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ),
      ]),
    ),
  );
}

// ── File content ───────────────────────────────────────────────────────────
class _FileContent extends StatelessWidget {
  final String url;
  final String name;
  final bool isMe;
  final bool isVoice;
  const _FileContent({
    required this.url, required this.name,
    required this.isMe, required this.isVoice,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) launchUrl(uri);
    },
    child: Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: isMe
                ? Colors.white24
                : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isVoice ? Icons.mic_rounded : Icons.insert_drive_file_rounded,
            color: isMe ? Colors.white : AppColors.primary, size: 22,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name,
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13,
                color: isMe ? Colors.white : AppColors.textPrimary),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('اضغط للتحميل',
            style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white60 : AppColors.textHint)),
        ])),
        Icon(Icons.download_rounded,
            color: isMe ? Colors.white60 : AppColors.textHint, size: 18),
      ]),
    ),
  );
}

// ── Attach option tile ─────────────────────────────────────────────────────
class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AttachOption({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      width: 42, height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    ),
    title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    onTap: onTap,
  );
}
