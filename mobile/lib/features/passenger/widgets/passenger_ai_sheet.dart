import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/fleet_state.dart';
import '../../../services/passenger_ai_service.dart';

class PassengerAiSheet extends StatefulWidget {
  final PassengerModel passenger;

  const PassengerAiSheet({
    super.key,
    required this.passenger,
  });

  static Future<void> show(BuildContext context, {required PassengerModel passenger}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PassengerAiSheet(passenger: passenger),
    );
  }

  @override
  State<PassengerAiSheet> createState() => _PassengerAiSheetState();
}

class _PassengerAiSheetState extends State<PassengerAiSheet> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AiMessage> _messages = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initWelcomeMessage();
  }

  void _initWelcomeMessage() {
    _messages.add(
      AiMessage(
        id: 'AI-WELCOME',
        text: '👋 **Namaskaram ${widget.passenger.name}!** I am your **EnRoute Kerala AI Travel Assistant**.\n\n'
            'Ask me anything about bus timings, step-by-step route guidance, or advice for your journey:\n\n'
            '• *"I want full list of SpeedWings bus timings"*\n'
            '• *"I want to go from Aluva to Perumbavoor, what should I do?"*\n'
            '• *"I don\'t have any previous experience of bus journey, what should I do?"*\n\n'
            'Tap any prompt below or type your question!',
        isUser: false,
        timestamp: DateTime.now(),
        quickSuggestions: [
          'Full list of SpeedWings bus timings',
          'I want to go from Aluva to Perumbavoor, what should I do?',
          'I don’t have any previous experience of bus journey, what should I do?',
          'How to go from Kaloor to Thoppumpady?',
          'What is the fare from Aluva to Kizhakkambalam?',
          'Which buses are running right now?',
        ],
      ),
    );
  }

  Future<void> _handleSend([String? presetQuery]) async {
    final rawText = presetQuery ?? _inputController.text;
    final text = rawText.trim();
    if (text.isEmpty) return;

    if (presetQuery == null) {
      _inputController.clear();
    }

    setState(() {
      _messages.add(
        AiMessage(
          id: 'USER-${DateTime.now().millisecondsSinceEpoch}',
          text: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isProcessing = true;
    });

    _scrollToBottom();

    try {
      final reply = await PassengerAiService.instance.processQuery(
        text,
        passenger: widget.passenger,
      );
      if (mounted) {
        setState(() {
          _messages.add(reply);
          _isProcessing = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
            AiMessage(
              id: 'AI-ERR-${DateTime.now().millisecondsSinceEpoch}',
              text: '⚠️ Sorry, I encountered an issue analyzing the fleet database. Please try again or ask for bus timings.',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _isProcessing = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _restartChat() {
    setState(() {
      _messages.clear();
      _initWelcomeMessage();
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E242B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with Meta-style glowing avatar
          _buildHeader(isDark),

          const Divider(height: 1),

          // Chat history messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (_isProcessing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isProcessing) {
                  return _buildTypingIndicator(isDark);
                }
                final msg = _messages[index];
                return _buildMessageItem(msg, isDark);
              },
            ),
          ),

          // Quick Prompt Suggestion Strip
          _buildQuickSuggestionsBar(isDark),

          // Bottom Input Bar
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Meta AI Style Glowing Avatar
          Container(
            width: 42,
            height: 42,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFF00C6FF),
                  Color(0xFF0072FF),
                  Color(0xFF8E2DE2),
                  Color(0xFFF355DA),
                  Color(0xFF00C6FF),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E242B) : Colors.white,
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Color(0xFF0072FF),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'EnRoute AI Assistant',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        'Kerala Transit Intelligence • Live Fleet',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            tooltip: 'Restart Conversation',
            onPressed: _restartChat,
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(AiMessage msg, bool isDark) {
    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGreen, Color(0xFF0A8A50)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.accentAmber,
              child: Text(
                widget.passenger.name.isNotEmpty ? widget.passenger.name[0].toUpperCase() : 'P',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ],
        ),
      );
    }

    // AI Response Card
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF8E2DE2)],
              ),
            ),
            child: CircleAvatar(
              backgroundColor: isDark ? const Color(0xFF2C323B) : Colors.white,
              child: const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF0072FF)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A313C) : const Color(0xFFF3F5F7),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formatted Markdown-like text
                  _buildFormattedText(msg.text, isDark),

                  // Stop-by-Stop Schedule List (if present)
                  if (msg.scheduleList != null && msg.scheduleList!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildScheduleWidget(msg.scheduleList!, isDark),
                  ],

                  // Action buttons
                  if (msg.quickActions != null && msg.quickActions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: msg.quickActions!.map((act) {
                        return OutlinedButton.icon(
                          onPressed: () => _handleSend(act.query),
                          icon: Icon(act.icon, size: 15, color: const Color(0xFF0072FF)),
                          label: Text(
                            act.label,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            side: const BorderSide(color: Color(0xFF0072FF), width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Follow-up Suggestions
                  if (msg.quickSuggestions != null && msg.quickSuggestions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 16),
                    Text(
                      'Suggested Follow-ups:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: msg.quickSuggestions!.map((s) {
                        return ActionChip(
                          avatar: const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF0072FF)),
                          label: Text(s, style: const TextStyle(fontSize: 11)),
                          backgroundColor: isDark ? const Color(0xFF1E242B) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
                          ),
                          onPressed: () => _handleSend(s),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text, bool isDark) {
    final lines = text.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
        continue;
      }

      // Check for bullet lines
      final trimmed = line.trim();
      final isBullet = trimmed.startsWith('•') || trimmed.startsWith('-');
      final cleanLine = isBullet ? trimmed.substring(1).trim() : trimmed;

      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: isBullet ? 8.0 : 0.0, bottom: 3.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isBullet)
                const Padding(
                  padding: EdgeInsets.only(right: 6, top: 4),
                  child: Icon(Icons.circle, size: 5, color: Color(0xFF0072FF)),
                ),
              Expanded(
                child: _parseRichSpans(cleanLine, isDark),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _parseRichSpans(String raw, bool isDark) {
    // Simple inline bold and code highlighter
    final spans = <TextSpan>[];
    final parts = raw.split('**');

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];
      final isBold = i % 2 == 1;

      if (part.contains('`')) {
        final codeParts = part.split('`');
        for (int c = 0; c < codeParts.length; c++) {
          final isCode = c % 2 == 1;
          spans.add(
            TextSpan(
              text: codeParts[c],
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isCode
                    ? (isDark ? Colors.amberAccent : Colors.teal.shade800)
                    : (isDark ? Colors.white : Colors.black87),
                backgroundColor: isCode ? (isDark ? Colors.white10 : Colors.grey.shade200) : null,
              ),
            ),
          );
        }
      } else {
        spans.add(
          TextSpan(
            text: part,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 13.5,
          height: 1.4,
          color: isDark ? Colors.white : Colors.black87,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildScheduleWidget(List<BusStopSchedule> schedule, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F252E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.schedule, size: 16, color: Color(0xFF0072FF)),
              SizedBox(width: 6),
              Text(
                'Complete Route Timeline',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < schedule.length; i++) ...[
            Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: i == 0
                            ? AppTheme.primaryGreen
                            : (i == schedule.length - 1 ? Colors.redAccent : Colors.blue.shade600),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i != schedule.length - 1)
                      Container(
                        width: 2,
                        height: 20,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    schedule[i].stopName,
                    style: TextStyle(
                      fontWeight: (i == 0 || i == schedule.length - 1) ? FontWeight.bold : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    schedule[i].time,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Color(0xFF0072FF),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF8E2DE2)],
              ),
            ),
            child: CircleAvatar(
              backgroundColor: isDark ? const Color(0xFF2C323B) : Colors.white,
              child: const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF0072FF)),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A313C) : const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0072FF)),
                ),
                const SizedBox(width: 8),
                Text(
                  'EnRoute AI is analyzing fleet data...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestionsBar(bool isDark) {
    final suggestions = PassengerAiService.instance.getSuggestedPrompts();

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final s = suggestions[i];
          return ActionChip(
            label: Text(
              s,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey.shade300 : Colors.black87,
              ),
            ),
            backgroundColor: isDark ? const Color(0xFF2A313C) : const Color(0xFFE8EEF5),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.blue.withValues(alpha: 0.15)),
            ),
            onPressed: () => _handleSend(s),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E242B) : Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A313C) : const Color(0xFFF3F5F7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Ask AI (e.g. SpeedWings timings, Aluva to Fort Kochi)...',
                        hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onSubmitted: (val) => _handleSend(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none, size: 20, color: Color(0xFF0072FF)),
                    tooltip: 'Voice Search Suggestion',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎙️ Voice prompt ready: Ask "SpeedWings timings" or "Aluva to Perumbavoor"'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF), Color(0xFF8E2DE2)],
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 19),
              onPressed: () => _handleSend(),
            ),
          ),
        ],
      ),
    );
  }
}
