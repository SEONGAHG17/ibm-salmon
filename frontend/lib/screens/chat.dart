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
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      role: 'assistant',
      content: '안녕하세요. 저장된 스크린샷 분석 결과를 바탕으로 바로 정리해드릴게요.',
    ),
  ];

  bool _isSending = false;
  String _statusProvider = 'idle';
  String _statusNotice = '챗봇 UI와 백엔드를 확인할 준비가 됐습니다.';
  int _lastCitationCount = 0;

  static const List<_QuickPrompt> _quickPrompts = [
    _QuickPrompt(
      icon: Icons.summarize_outlined,
      label: '요약',
      prompt: '최근 저장한 항목 요약해줘',
    ),
    _QuickPrompt(
      icon: Icons.event_available_outlined,
      label: '일정',
      prompt: '일정등록 항목만 알려줘',
    ),
    _QuickPrompt(
      icon: Icons.map_outlined,
      label: '지도',
      prompt: '지도에서 볼 항목 정리해줘',
    ),
    _QuickPrompt(
      icon: Icons.school_outlined,
      label: '장학금',
      prompt: '장학금 관련 정보 있어?',
    ),
    _QuickPrompt(
      icon: Icons.link_outlined,
      label: '링크',
      prompt: '바로 열어볼 링크만 정리해줘',
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
      _statusProvider = 'loading';
      _statusNotice = '스크린샷 기록과 Watsonx 응답을 확인하고 있습니다.';
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
        _statusProvider = provider;
        _statusNotice = notice ?? _providerSummary(provider);
        _lastCitationCount = citations.length;
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            content: reply == null || reply.isEmpty ? '답변을 생성하지 못했습니다.' : reply,
            provider: provider,
            notice: notice,
            citations: citations,
          ),
        );
      });
    } catch (e) {
      setState(() {
        _statusProvider = 'error';
        _statusNotice = '백엔드 서버 또는 네트워크 연결을 확인해주세요.';
        _lastCitationCount = 0;
        _messages.add(
          _ChatMessage(
            role: 'assistant',
            content: '챗봇 연결에 실패했습니다. 백엔드 서버와 Watsonx 설정을 확인해주세요.\n$e',
            provider: 'error',
            notice: '요청이 서버까지 도달하지 못했습니다.',
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

  String _providerSummary(String provider) {
    return switch (provider) {
      'watsonx' => 'Watsonx Granite 모델로 생성한 응답입니다.',
      'local_fallback' => 'Watsonx 대신 로컬 보조 응답으로 전환했습니다.',
      'error' => '챗봇 연결에 실패했습니다.',
      _ => '챗봇이 응답을 준비했습니다.',
    };
  }

  void _clearChat() {
    setState(() {
      _messages
        ..clear()
        ..add(
          const _ChatMessage(
            role: 'assistant',
            content: '대화를 초기화했습니다. 다시 질문해보세요.',
          ),
        );
      _statusProvider = 'idle';
      _statusNotice = '챗봇 UI와 백엔드를 확인할 준비가 됐습니다.';
      _lastCitationCount = 0;
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        titleSpacing: 16,
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
        actions: [
          IconButton(
            onPressed: _messages.length > 1 ? _clearChat : null,
            icon: const Icon(Icons.delete_outline),
            tooltip: '대화 초기화',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _ConnectionBanner(
              provider: _statusProvider,
              notice: _statusNotice,
              citationCount: _lastCitationCount,
              isSending: _isSending,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
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

class _ConnectionBanner extends StatelessWidget {
  final String provider;
  final String notice;
  final int citationCount;
  final bool isSending;

  const _ConnectionBanner({
    required this.provider,
    required this.notice,
    required this.citationCount,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    final status = switch (provider) {
      'watsonx' => (
          title: 'Watsonx 연결됨',
          icon: Icons.verified_outlined,
          color: Colors.deepPurple,
        ),
      'local_fallback' => (
          title: '서버 연결됨',
          icon: Icons.info_outline,
          color: Colors.amber.shade800,
        ),
      'error' => (
          title: '연결 오류',
          icon: Icons.error_outline,
          color: Colors.redAccent,
        ),
      'loading' => (
          title: '응답 생성 중',
          icon: Icons.sync,
          color: Colors.blueGrey,
        ),
      _ => (
          title: '챗봇 준비됨',
          icon: Icons.smart_toy_outlined,
          color: Colors.deepPurple,
        ),
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: status.color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(status.icon, color: status.color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        status.title,
                        style: TextStyle(
                          color: status.color,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isSending)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: status.color,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notice,
                  style: const TextStyle(fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _MiniBadge(
                      icon: Icons.memory_outlined,
                      label: provider == 'watsonx' ? 'Watsonx' : 'Fallback',
                    ),
                    _MiniBadge(
                      icon: Icons.article_outlined,
                      label: '근거 $citationCount개',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
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
      'local_fallback' => '로컬 보조 응답',
      _ => null,
    };
    final providerColor = switch (provider) {
      'watsonx' => Colors.deepPurple,
      'error' => Colors.redAccent,
      _ => Colors.grey.shade700,
    };

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.84,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepPurple : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: Radius.circular(isUser ? 8 : 2),
            bottomRight: Radius.circular(isUser ? 2 : 8),
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
                height: 1.38,
              ),
            ),
            if (!isUser && message.citations.isNotEmpty) ...[
              const SizedBox(height: 10),
              _CitationWrap(citations: message.citations),
            ],
            if (!isUser && providerLabel != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 13, color: providerColor),
                  const SizedBox(width: 4),
                  Text(
                    providerLabel,
                    style: TextStyle(
                      color: providerColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: message.content));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('답변을 복사했습니다.')),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.copy, size: 14, color: providerColor),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CitationWrap extends StatelessWidget {
  final List<_Citation> citations;

  const _CitationWrap({required this.citations});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: citations.take(3).map((citation) {
        final label = citation.actionData.isNotEmpty
            ? '${citation.category} · ${citation.actionType}'
            : citation.category;
        return Tooltip(
          message: citation.summary,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('답변 생성 중', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _QuickPromptBar extends StatelessWidget {
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
    return SizedBox(
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        itemCount: prompts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = prompts[index];
          return ActionChip(
            avatar: Icon(prompt.icon, size: 16),
            label: Text('${prompt.label} · ${prompt.prompt}'),
            onPressed: enabled ? () => onSelected(prompt.prompt) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
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
                prefixIcon: const Icon(Icons.chat_bubble_outline),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton.filled(
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
