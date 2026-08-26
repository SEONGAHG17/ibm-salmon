import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';

class ChatScreen extends StatefulWidget {
  final String? initialPrompt;

  const ChatScreen({super.key, this.initialPrompt});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _ink = Color(0xFF22201F);
  static const _muted = Color(0xFF7B7370);
  static const _paper = Color(0xFFFFFCF8);
  static const _wash = Color(0xFFF7F1EC);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      role: 'assistant',
      content: '찾고 싶은 내용을 말해줘. 저장된 스크린샷에서 필요한 것만 골라볼게.',
    ),
  ];

  bool _isSending = false;

  static const List<_QuickPrompt> _quickPrompts = [
    _QuickPrompt(
      icon: Icons.search_outlined,
      label: '요약',
      prompt: '최근 저장한 항목 요약해줘',
    ),
    _QuickPrompt(
      icon: Icons.event_note_outlined,
      label: '마감',
      prompt: '마감일 있는 항목만 정리해줘',
    ),
    _QuickPrompt(
      icon: Icons.place_outlined,
      label: '장소',
      prompt: '지도에서 볼 항목 정리해줘',
    ),
    _QuickPrompt(
      icon: Icons.school_outlined,
      label: '장학금',
      prompt: '장학금 관련 정보 있어?',
    ),
    _QuickPrompt(
      icon: Icons.card_giftcard_outlined,
      label: '쿠폰',
      prompt: '쿠폰이나 기프티콘 사용기한 알려줘',
    ),
  ];

  @override
  void initState() {
    super.initState();
    final prompt = widget.initialPrompt;
    if (prompt != null && prompt.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(prompt);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? quickPrompt]) async {
    final messageText = (quickPrompt ?? _messageController.text).trim();
    if (messageText.isEmpty || _isSending) return;

    final previousHistory = _messages
        .where(
          (message) => message.role == 'user' || message.role == 'assistant',
        )
        .map((message) => {'role': message.role, 'content': message.content})
        .toList();

    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: messageText));
      _isSending = true;
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': messageText,
          'user_id': 'default_user',
          'history': previousHistory,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final reply = decoded['reply']?.toString().trim();
      final provider = decoded['provider']?.toString() ?? 'watsonx';
      final notice = decoded['notice']?.toString();
      final citations = _Citation.fromList(decoded['citations']);

      setState(() {
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            content: reply == null || reply.isEmpty ? '답변을 만들지 못했어. 다시 물어봐줘.' : reply,
            provider: provider,
            notice: notice,
            citations: citations,
          ),
        );
      });
    } catch (_) {
      setState(() {
        _messages.add(
          const _ChatMessage(
            role: 'assistant',
            content: '지금은 연결이 불안정해. 서버를 켠 뒤 다시 시도해줘.',
            provider: 'error',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
        _scrollToBottom();
      }
    }
  }

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add(
          const _ChatMessage(
            role: 'assistant',
            content: '좋아, 새로 시작하자. 어떤 스크린샷 정보를 찾을까?',
          ),
        );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _wash,
      appBar: AppBar(
        backgroundColor: _paper,
        foregroundColor: _ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'T.Salmon',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              '스크린샷 정리',
              style: TextStyle(
                color: _muted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _messages.length > 1 ? _clearChat : null,
            icon: const Icon(Icons.refresh),
            tooltip: '새 대화',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                itemCount: _messages.length + (_isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isSending && index == _messages.length) {
                    return const _TypingBubble();
                  }
                  return _MessageBubble(message: _messages[index]);
                },
              ),
            ),
            _QuickPromptBar(
              prompts: _quickPrompts,
              enabled: !_isSending,
              onSelected: (prompt) => _sendMessage(prompt),
            ),
            _ChatInput(
              controller: _messageController,
              enabled: !_isSending,
              onSubmitted: () => _sendMessage(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String role;
  final String content;
  final String? provider;
  final String? notice;
  final List<_Citation> citations;

  const _ChatMessage({
    required this.role,
    required this.content,
    this.provider,
    this.notice,
    this.citations = const [],
  });

  bool get isUser => role == 'user';
  bool get isError => provider == 'error';
  bool get isLimited => provider == 'local_fallback';
}

class _Citation {
  final String category;
  final String summary;
  final String actionType;
  final String actionData;

  const _Citation({
    required this.category,
    required this.summary,
    required this.actionType,
    required this.actionData,
  });

  static List<_Citation> fromList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(
          (item) => _Citation(
            category: item['category']?.toString() ?? '미분류',
            summary: item['summary']?.toString() ?? '',
            actionType: item['action_type']?.toString() ?? '해당없음',
            actionData: item['action_data']?.toString() ?? '',
          ),
        )
        .toList();
  }
}

class _QuickPrompt {
  final IconData icon;
  final String label;
  final String prompt;

  const _QuickPrompt({
    required this.icon,
    required this.label,
    required this.prompt,
  });
}

class _MessageBubble extends StatelessWidget {
  static const _ink = Color(0xFF22201F);
  static const _muted = Color(0xFF7B7370);
  static const _line = Color(0xFFE7DCD4);
  static const _salmon = Color(0xFFE76F61);
  static const _warning = Color(0xFF9A5B13);

  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bubbleColor = isUser ? _salmon : Colors.white;
    final textColor = isUser ? Colors.white : _ink;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.84,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(14, 11, 12, 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: Radius.circular(isUser ? 8 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 8),
          ),
          border: isUser ? null : Border.all(color: _line),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.42,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isUser && message.citations.isNotEmpty) ...[
              const SizedBox(height: 10),
              _CitationWrap(citations: message.citations),
            ],
            if (!isUser && message.isLimited) ...[
              const SizedBox(height: 8),
              const _SoftNote(
                icon: Icons.history_outlined,
                label: '저장된 기록 기준',
                color: _warning,
              ),
            ],
            if (!isUser && message.isError) ...[
              const SizedBox(height: 8),
              const _SoftNote(
                icon: Icons.wifi_off_outlined,
                label: '잠시 후 다시 시도',
                color: _warning,
              ),
            ],
            if (!isUser) ...[
              const SizedBox(height: 7),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: message.content));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('답변을 복사했습니다.')),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Icon(Icons.copy, size: 15, color: _muted),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SoftNote extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SoftNote({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CitationWrap extends StatelessWidget {
  static const _line = Color(0xFFE7DCD4);
  static const _sage = Color(0xFF4D7C6F);

  final List<_Citation> citations;

  const _CitationWrap({required this.citations});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: citations.take(3).map((citation) {
        final label = citation.actionType == '해당없음'
            ? citation.category
            : '${citation.category} · ${citation.actionType}';
        return Tooltip(
          message: citation.summary,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF6FAF7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _line),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: _sage,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE7DCD4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFE76F61),
              ),
            ),
            SizedBox(width: 8),
            Text('정리 중', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _QuickPromptBar extends StatelessWidget {
  static const _line = Color(0xFFE7DCD4);
  static const _ink = Color(0xFF22201F);
  static const _sage = Color(0xFF4D7C6F);

  final List<_QuickPrompt> prompts;
  final bool enabled;
  final ValueChanged<String> onSelected;

  const _QuickPromptBar({
    required this.prompts,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      color: const Color(0xFFFFFCF8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: prompts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            avatar: Icon(prompt.icon, size: 16, color: _sage),
            label: Text(
              prompt.label,
              style: const TextStyle(color: _ink, fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.white,
            side: const BorderSide(color: _line),
            onPressed: enabled ? () => onSelected(prompt.prompt) : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          );
        },
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  static const _line = Color(0xFFE7DCD4);
  static const _salmon = Color(0xFFE76F61);

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmitted;

  const _ChatInput({
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFCF8),
        border: Border(top: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: '질문 입력',
                filled: true,
                fillColor: const Color(0xFFF5EFEB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _salmon),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) {
                if (enabled) onSubmitted();
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton.filled(
              style: IconButton.styleFrom(
                backgroundColor: _salmon,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: enabled ? onSubmitted : null,
              icon: const Icon(Icons.send),
              tooltip: '전송',
            ),
          ),
        ],
      ),
    );
  }
}
