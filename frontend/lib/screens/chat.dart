import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/constants.dart';

class ChatScreen extends StatefulWidget {
  final String? initialPrompt;

  const ChatScreen({super.key, this.initialPrompt});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      role: 'assistant',
      content: '안녕하세요. 저장된 스크린샷 분석 결과를 바탕으로 바로 정리해드릴게요.',
    ),
  ];

  bool _isSending = false;

  static const List<String> _quickPrompts = [
    '최근 저장한 항목 요약해줘',
    '일정등록 항목만 알려줘',
    '지도에서 볼 항목 정리해줘',
    '장학금 관련 정보 있어?',
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

      setState(() {
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            content: reply == null || reply.isEmpty ? '답변을 생성하지 못했습니다.' : reply,
            provider: provider,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            content: '챗봇 연결에 실패했습니다. 백엔드 서버와 Watsonx 설정을 확인해주세요.\n$e',
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
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Watson 챗봇'),
            Text(
              'watsonx Granite',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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

  const _ChatMessage({
    required this.role,
    required this.content,
    this.provider,
  });

  bool get isUser => role == 'user';
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final provider = message.provider;
    final providerLabel = switch (provider) {
      'watsonx' => 'Watsonx 응답',
      'error' => '연결 오류',
      _ => '로컬 보조 응답',
    };
    final providerColor = switch (provider) {
      'watsonx' => Colors.deepPurple,
      'error' => Colors.redAccent,
      _ => Colors.grey.shade600,
    };

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
          border: isUser ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 15,
                height: 1.35,
              ),
            ),
            if (!isUser && provider != null) ...[
              const SizedBox(height: 6),
              Text(
                providerLabel,
                style: TextStyle(
                  color: providerColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
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
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _QuickPromptBar extends StatelessWidget {
  final List<String> prompts;
  final bool enabled;
  final ValueChanged<String> onSelected;

  const _QuickPromptBar({
    required this.prompts,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: prompts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            avatar: const Icon(Icons.auto_awesome, size: 16),
            label: Text(prompt),
            onPressed: enabled ? () => onSelected(prompt) : null,
          );
        },
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
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
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
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
          IconButton.filled(
            onPressed: enabled ? onSubmitted : null,
            icon: const Icon(Icons.send),
            tooltip: '전송',
          ),
        ],
      ),
    );
  }
}
