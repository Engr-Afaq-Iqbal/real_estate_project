import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';
import '../../../presentation/theme/app_colors.dart';
import '../../../presentation/theme/app_dimensions.dart';
import '../../../presentation/theme/app_text_styles.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('MC', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
                Text('Malik Construction', style: AppTextStyles.h3(context)),
              ],
            ),
            Text('Active project: DHA House', style: AppTextStyles.caption(context)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined, size: 22)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline_rounded, size: 22)),
        ],
      ),
      body: Column(
        children: [
          // Project progress banner
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePaddingH,
              vertical: AppDimensions.sm,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.home_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'DHA House — Gray Structure · 68%',
                  style: AppTextStyles.labelMedium(context),
                ),
                const Spacer(),
                const Text('68%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pagePaddingH,
                  vertical: AppDimensions.sm,
                ),
                itemCount: controller.messages.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Today', style: TextStyle(fontSize: 11, color: AppColors.textTertiaryLight)),
                      ),
                    );
                  }
                  final msg = controller.messages[i - 1];
                  if (msg.isSystemMessage == true) {
                    return _SystemMessageBubble(
                      title: msg.systemTitle ?? '',
                      body: msg.systemBody ?? '',
                    );
                  }
                  return _MessageBubble(message: msg);
                },
              ),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePaddingH,
              vertical: AppDimensions.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              border: Border(top: BorderSide(color: AppColors.dividerLight)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondaryLight),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.messageCtrl,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        isDense: true,
                      ),
                      onSubmitted: controller.sendMessage,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  GestureDetector(
                    onTap: () => controller.sendMessage(controller.messageCtrl.text),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.only(bottom: AppDimensions.sm),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : AppColors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          border: isMe ? null : Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: isMe ? Colors.white : AppTextStyles.bodyMedium(context).color,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('h:mm a').format(message.time),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white60 : AppColors.textTertiaryLight,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 2),
                  const Text('✓✓', style: TextStyle(fontSize: 10, color: Colors.white60)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemMessageBubble extends StatelessWidget {
  final String title;
  final String body;
  const _SystemMessageBubble({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: const Border(
          left: BorderSide(color: AppColors.success, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 16),
              const SizedBox(width: 6),
              Text(title, style: AppTextStyles.h4(context).copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 4),
          Text(body, style: AppTextStyles.bodySmall(context)),
          const SizedBox(height: 4),
          const Text('View Details →', style: TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
