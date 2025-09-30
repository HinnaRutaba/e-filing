import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/services/chat_service.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel currentUser = ref.read(authController);
    return BaseScreen(
      title: "Chats",
      body: ChatsListView(
        userId: currentUser.id!,
        userDesignationId: currentUser.currentDesignation!.userDesgId!,
      ),
    );
  }
}

class ChatsListView extends StatelessWidget {
  final int userId;
  final int userDesignationId;
  final ChatService _chatService = ChatService();

  ChatsListView({
    super.key,
    required this.userId,
    required this.userDesignationId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatModel>>(
      stream: _chatService.getUserChatsStream(
        userId: userId,
        userDesignationId: userDesignationId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No chats found"));
        }

        final chats = snapshot.data!;

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final lastMsg =
                _chatService.isParticipantInChat(chat: chat, userId: userId) !=
                        true
                    ? "You are no longer in this discussion"
                    : chat.lastMessage?.text ?? "No messages yet";
            final int activeUsers = chat.activeParticipants.length;

            return Stack(
              children: [
                Badge(
                  backgroundColor: AppColors.secondaryDark,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  label: const Text('New'),
                  offset: const Offset(-28, 2),
                  isLabelVisible: chat.hasUnread(userDesignationId),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryDark,
                      child: Icon(Icons.groups),
                    ),
                    title: AppText.titleMedium(
                        "File: ${chat?.fileBarCode ?? chat.fileId}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.labelMedium(
                          "$activeUsers participant${activeUsers > 1 ? 's' : ''}",
                          maxLines: 1,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          color: AppColors.secondaryDark,
                        ),
                        const SizedBox(height: 4),
                        AppText.bodyMedium(
                          lastMsg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.grey[800],
                        )
                      ],
                    ),
                    trailing: AppText.labelMedium(
                      chat.lastMessage?.sentAt != null
                          ? _formatTime(chat.lastMessage!.sentAt)
                          : "",
                    ),
                    onTap: () {
                      RouteHelper.push(Routes.fileChat(chat.fileId));
                    },
                  ),
                ),
                // Container(
                //   width: 24,
                //   height: 24,
                //   decoration: BoxDecoration(
                //     color: AppColors.secondaryDark,
                //     shape: BoxShape.circle,
                //   ),
                // )
              ],
            );
          },
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}
