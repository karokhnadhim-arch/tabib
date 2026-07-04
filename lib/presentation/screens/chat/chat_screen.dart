import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/chat_message.dart';
import '../../../services/auth_service.dart';
import '../../../services/image_storage_service.dart';
import '../../../utils/image_upload_utils.dart';
import '../../../utils/localization_utils.dart';
import '../../../utils/tabib_image_upload.dart';
import '../../../services/offline/offline_recent_chats_service.dart';
import '../../providers/app_providers.dart';
import '../../widgets/offline_indicator_banner.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.clinicId,
    required this.patientId,
    this.patientName,
  });

  final String clinicId;
  final String patientId;
  final String? patientName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  ChatProvider? _chatProvider;
  late String _patientId;
  bool _sendingImage = false;
  int _lastMessageCount = 0;
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _controller.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startChat());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chat = _chatProvider ??= context.read<ChatProvider>();
    if (!chat.messages.isEmpty && _lastMessageCount == 0) {
      _lastMessageCount = chat.messages.length;
    }
    chat.removeListener(_onChatUpdated);
    chat.addListener(_onChatUpdated);
  }

  void _onChatUpdated() {
    if (!mounted) return;
    final chat = _chatProvider;
    if (chat == null) return;
    final count = chat.messages.length;
    if (count > _lastMessageCount) {
      _lastMessageCount = count;
      _acknowledgeMessages();
      _scrollToBottom(animated: _initialScrollDone);
      _initialScrollDone = true;
    } else if (!_initialScrollDone && count > 0) {
      _initialScrollDone = true;
      _scrollToBottom(animated: false);
    }
  }

  void _startChat() {
    final auth = context.read<AuthService>();
    _patientId = widget.patientId.isNotEmpty
        ? widget.patientId
        : auth.patientId;
    final chat = context.read<ChatProvider>();
    chat.watch(clinicId: widget.clinicId, patientId: _patientId);
    final title = widget.patientName?.trim().isNotEmpty == true
        ? widget.patientName!.trim()
        : widget.clinicId;
    context.read<OfflineRecentChatsService>().recordOpen(
          clinicId: widget.clinicId,
          patientId: _patientId,
          title: title,
        );
    _acknowledgeMessages();
  }

  @override
  void dispose() {
    _chatProvider?.removeListener(_onChatUpdated);
    _controller.removeListener(_onTextChanged);
    _scrollController.removeListener(_onScroll);
    _controller.dispose();
    _scrollController.dispose();
    _chatProvider?.stopWatching();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 48) {
      context.read<ChatProvider>().loadOlderMessages();
    }
  }

  void _onTextChanged() {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    if (user == null) return;
    final l10n = AppLocalizations.of(context);
    final role = auth.isPatient ? 'patient' : 'secretary';
    final senderName = auth.isPatient
        ? user.name.localized(context)
        : l10n.chatWithClinic;
    context.read<ChatProvider>().setTyping(
          clinicId: widget.clinicId,
          patientId: _patientId,
          userId: user.id,
          userName: senderName,
          role: role,
          isTyping: _controller.text.trim().isNotEmpty,
        );
  }

  Future<void> _acknowledgeMessages() async {
    final auth = context.read<AuthService>();
    final role = auth.isPatient ? 'patient' : 'secretary';
    await context.read<ChatProvider>().acknowledgeIncoming(
          clinicId: widget.clinicId,
          patientId: _patientId,
          readerRole: role,
        );
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final auth = context.read<AuthService>();
    final user = auth.currentUser!;
    final l10n = AppLocalizations.of(context);
    final role = auth.isPatient ? 'patient' : 'secretary';
    final senderName = auth.isPatient
        ? user.name.localized(context)
        : l10n.chatWithClinic;

    _controller.clear();
    await context.read<ChatProvider>().send(
          clinicId: widget.clinicId,
          patientId: _patientId,
          senderId: user.id,
          senderName: senderName,
          senderRole: role,
          text: text,
        );
    _scrollToBottom();
  }

  Future<void> _pickAndSendImage() async {
    if (_sendingImage) return;
    setState(() => _sendingImage = true);

    try {
      final auth = context.read<AuthService>();
      final user = auth.currentUser!;
      final l10n = AppLocalizations.of(context);
      final role = auth.isPatient ? 'patient' : 'secretary';
      final senderName = auth.isPatient
          ? user.name.localized(context)
          : l10n.chatWithClinic;

      final uploaded = await TabibImageUpload.pickOptimizeAndUpload(
        category: ImageStorageCategory.chatImage,
        ownerId: '${widget.clinicId}_$_patientId',
        optimizer: optimizeClinicImage,
      );
      if (uploaded == null || !mounted) return;

      await context.read<ChatProvider>().sendImage(
            clinicId: widget.clinicId,
            patientId: _patientId,
            senderId: user.id,
            senderName: senderName,
            senderRole: role,
            imageUrl: uploaded.fullUrl,
            imageThumbnailUrl: uploaded.thumbnailUrl,
          );
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sendingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthService>();
    final chat = context.watch<ChatProvider>();
    final title = widget.patientName ??
        (auth.isPatient ? l10n.chatWithClinic : l10n.chatWithSecretary);
    final accent =
        auth.isPatient ? AppTheme.patientColor : AppTheme.secretaryColor;

    final typing = chat.typing;
    final showTyping = typing != null &&
        typing.isActive(currentUserId: auth.currentUser?.id ?? '');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: accent,
      ),
      body: Column(
        children: [
          const OfflineIndicatorBanner(compact: true),
          Expanded(
            child: chat.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chat.messages.isEmpty
                    ? Center(
                        child: Text(
                          l10n.typeMessage,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        itemCount: chat.messages.length +
                            (chat.isLoadingOlder ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (chat.isLoadingOlder && index == 0) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          final msgIndex =
                              chat.isLoadingOlder ? index - 1 : index;
                          final m = chat.messages[msgIndex];
                          final isMine =
                              m.senderId == auth.currentUser?.id;
                          return _MessageBubble(
                            message: m,
                            isMine: isMine,
                            seenLabel: l10n.messageSeen,
                          );
                        },
                      ),
          ),
          if (showTyping)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.userIsTyping(typing.userName),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          Material(
            elevation: 6,
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      tooltip: l10n.attachImage,
                      onPressed: _sendingImage ? null : _pickAndSendImage,
                      icon: _sendingImage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.image_outlined),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: l10n.typeMessage,
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendText(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    FilledButton(
                      onPressed: _sendText,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.medicalGreen,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: const Icon(Icons.send_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.seenLabel,
  });

  final ChatMessage message;
  final bool isMine;
  final String seenLabel;

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        isMine ? AppTheme.medicalBlue : Theme.of(context).colorScheme.surface;
    final textColor = isMine ? Colors.white : Colors.black87;

    return Align(
      alignment: isMine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMine ? 18 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 18),
          ),
          border: isMine ? null : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isImage && message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Builder(
                  builder: (context) {
                    final provider = tabibImageProvider(
                      message.imageUrl,
                      thumbnailUrl: message.imageThumbnailUrl,
                    );
                    if (provider == null) {
                      return const SizedBox(
                        width: 220,
                        height: 140,
                        child: Center(child: Icon(Icons.broken_image)),
                      );
                    }
                    return Image(
                      image: provider,
                      width: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    );
                  },
                ),
              ),
            if (message.text.isNotEmpty) ...[
              if (message.isImage) const SizedBox(height: 6),
              Text(message.text, style: TextStyle(color: textColor)),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.jm().format(message.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: isMine
                        ? Colors.white.withOpacity(0.75)
                        : Colors.grey.shade600,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  _DeliveryIcon(status: message.deliveryStatus),
                  if (message.deliveryStatus == ChatDeliveryStatus.read) ...[
                    const SizedBox(width: 4),
                    Text(
                      seenLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryIcon extends StatelessWidget {
  const _DeliveryIcon({required this.status});

  final ChatDeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status == ChatDeliveryStatus.read
        ? Colors.lightBlueAccent
        : Colors.white.withOpacity(0.85);
    final icon = switch (status) {
      ChatDeliveryStatus.sending => Icons.access_time,
      ChatDeliveryStatus.failed => Icons.error_outline,
      ChatDeliveryStatus.sent => Icons.check,
      ChatDeliveryStatus.delivered => Icons.done_all,
      ChatDeliveryStatus.read => Icons.done_all,
    };
    return Icon(icon, size: 14, color: color);
  }
}
