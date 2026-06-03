import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  final bool? isSystemMessage;
  final String? systemTitle;
  final String? systemBody;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.isSystemMessage,
    this.systemTitle,
    this.systemBody,
  });
}

class ChatController extends GetxController {
  final messages = <ChatMessage>[].obs;
  final messageCtrl = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMessages();
  }

  void _loadMessages() {
    messages.value = [
      ChatMessage(
        id: '1',
        text: 'Salam Ahmed sahib. Slab work for second floor poured this morning. Going to cure for 7 days.',
        isMe: false,
        time: DateTime(2025, 5, 20, 9, 12),
      ),
      ChatMessage(
        id: '2',
        text: 'Excellent. Steel weighing slips agaye?',
        isMe: true,
        time: DateTime(2025, 5, 20, 9, 18),
      ),
      ChatMessage(
        id: '3',
        text: 'G ji, send kar deta hoon. Eng. Asif verified all placements.',
        isMe: false,
        time: DateTime(2025, 5, 20, 9, 25),
      ),
      ChatMessage(
        id: 'sys1',
        text: '',
        isMe: false,
        time: DateTime(2025, 5, 20, 9, 28),
        isSystemMessage: true,
        systemTitle: 'Stage Complete: Foundation',
        systemBody: 'All 4 columns + plinth beam verified. Ready to advance to Gray Structure stage.',
      ),
      ChatMessage(
        id: '4',
        text: '👍',
        isMe: true,
        time: DateTime(2025, 5, 20, 9, 30),
      ),
    ];
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isMe: true,
      time: DateTime.now(),
    ));
    messageCtrl.clear();
    messages.refresh();
  }

  @override
  void onClose() {
    messageCtrl.dispose();
    super.onClose();
  }
}
