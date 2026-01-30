import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel currentUser = ref.read(authController);
    return BaseScreen(
      title: "Chats",
      enableBackButton: true,
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
  final ValueNotifier<String> _filter = ValueNotifier<String>("All");

  ChatsListView({
    super.key,
    required this.userId,
    required this.userDesignationId,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ValueListenableBuilder<String>(
            valueListenable: _filter,
            builder: (context, filter, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildFilterTile(
                        title: "All Chats",
                        countStream: _chatService.getAllChatsCountStream(),
                        isSelected: filter == "All",
                        onTap: () => _filter.value = "All",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterTile(
                        title: "Unread",
                        countStream: _chatService
                            .getUnreadChatsCountStream(userDesignationId),
                        isSelected: filter == "Unread",
                        onTap: () => _filter.value = "Unread",
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: _filter,
              builder: (context, filter, _) {
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
                    final filteredChats = filter == "Unread"
                        ? chats
                            .where((chat) => chat.hasUnread(userDesignationId))
                            .toList()
                        : chats;

                    return ListView.separated(
                      itemCount: filteredChats.length,
                      separatorBuilder: (ctx, i) {
                        if (i == filteredChats.length - 1) {
                          return const SizedBox.shrink();
                        }
                        return const Divider(
                          indent: 16,
                          endIndent: 16,
                          color: AppColors.cardColor,
                        );
                      },
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        final lastMsg = _chatService.isParticipantInChat(
                                    chat: chat, userId: userId) !=
                                true
                            ? "You are no longer in this discussion"
                            : chat.lastMessage?.text ?? "No messages yet";
                        final int activeUsers = chat.activeParticipants.length;

                        return Animate(
                          effects: [
                            FadeEffect(duration: 300.ms),
                            SlideEffect(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                              duration: 300.ms,
                            ),
                          ],
                          delay: (index * 100)
                              .ms, // Staggered delay based on index
                          child: Stack(
                            children: [
                              Badge(
                                backgroundColor: AppColors.secondary,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                label: const Text('New'),
                                offset: const Offset(-40, 2),
                                isLabelVisible:
                                    chat.hasUnread(userDesignationId),
                                child: ListTile(
                                  titleAlignment: ListTileTitleAlignment.top,
                                  leading: const CircleAvatar(
                                    backgroundColor: AppColors.secondaryDark,
                                    child: Icon(Icons.groups),
                                  ),
                                  title: AppText.titleMedium(
                                      "File: ${chat?.fileBarCode ?? chat.fileId}"),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      AppText.labelMedium(
                                        chat.lastMessage?.sentAt != null
                                            ? _formatTime(
                                                chat.lastMessage!.sentAt)
                                            : "",
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    RouteHelper.push(
                                        Routes.fileChat(chat.fileId));
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTile({
    required String title,
    required Stream<int> countStream,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: StreamBuilder<int>(
        stream: countStream,
        builder: (context, snapshot) {
          final count = snapshot.data ?? 0;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryDark : null,
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? null
                  : Border.all(
                      color: Colors.black26,
                      width: 1,
                    ),
            ),
            child: Column(
              children: [
                Text(
                  "$title ($count)",
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
