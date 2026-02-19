import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/services/record_audio_service.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/chats/new_chat_bottom_sheet.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/outline_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatsScreen extends ConsumerWidget {
  const ChatsScreen({super.key});

  void _showNewChatBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NewChatBottomSheet(),
    );
  }

  void _showCreateChatDialog(BuildContext context, UserModel currentUser) {
    final TextEditingController chatNameController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool creating = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AppText.titleMedium(
            'Create New Group Chat',
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      controller: chatNameController,
                      labelText: 'Group Chat Name',
                      hintText: 'Enter group chat name',
                      showLabel: false,
                      validator: (text) {
                        if (text == null || text.trim().isEmpty) {
                          return 'Group chat name cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            SizedBox(
              width: 124,
              child: AppOutlineButton(
                onPressed: () {
                  RouteHelper.pop();
                },
                text: 'Cancel',
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 124,
              child: StatefulBuilder(builder: (context, dState) {
                return creating
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : AppSolidButton(
                        onPressed: () async {
                          if (formKey.currentState?.validate() != true) {
                            return;
                          }
                          dState(() {
                            creating = true;
                          });
                          final chatName = chatNameController.text.trim();
                          if (chatName.isNotEmpty) {
                            String chatId = await ChatService().createChatRoom(
                              fileId: null,
                              subject: chatName,
                              chatType: ChatType.group,
                              participants: [
                                ChatParticipantModel(
                                  userDesignationId: currentUser
                                      .currentDesignation!.userDesgId!,
                                  userId: currentUser.id!,
                                  userTitle: currentUser.userTitle!,
                                  designation: currentUser
                                      .currentDesignation!.designation!,
                                  joinedAt: DateTime.now(),
                                  removed: false,
                                  removedAt: null,
                                ),
                              ],
                            );
                            dState(() {
                              creating = false;
                            });
                            RouteHelper.pop();
                            RouteHelper.push(Routes.fileChat(null, chatId));
                          }
                        },
                        text: 'Create',
                      );
              }),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel currentUser = ref.read(authController);
    return BaseScreen(
      title: "Chats",
      enableBackButton: true,
      actions: [
        InkWell(
          onTap: () => _showNewChatBottomSheet(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                color: AppColors.secondaryDark,
                size: 20,
              ),
              AppText.labelMedium(
                "New Chat",
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () => _showCreateChatDialog(context, currentUser),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.group_add_outlined,
                color: AppColors.secondaryDark,
                size: 20,
              ),
              AppText.labelMedium(
                "New Group",
                color: AppColors.secondaryDark,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ],
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
                        countStream: _chatService.getAllChatsCountStream(
                          userId: userId,
                          userDesignationId: userDesignationId,
                        ),
                        isSelected: filter == "All",
                        onTap: () => _filter.value = "All",
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildFilterTile(
                        title: "Unread",
                        countStream: _chatService.getUnreadChatsCountStream(
                          userId: userId,
                          userDesignationId: userDesignationId,
                        ),
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
                        String lastMsg;

                        if (_chatService.isParticipantInChat(
                                chat: chat, userId: userId) !=
                            true) {
                          lastMsg = "You are no longer in this discussion";
                        } else if (chat.lastMessage != null) {
                          // Check if user joined after the last message was sent
                          final userParticipant = chat.participants
                              .where((p) =>
                                  p.userId == userId &&
                                  p.userDesignationId == userDesignationId)
                              .firstOrNull;

                          if (userParticipant != null &&
                              userParticipant.joinedAt != null &&
                              userParticipant.joinedAt
                                      ?.isAfter(chat.lastMessage!.sentAt) ==
                                  true) {
                            // User joined after this message was sent, don't show message content
                            lastMsg = "No messages yet";
                          } else {
                            // Check if the message was sent by current user
                            final isCurrentUser =
                                chat.lastMessage!.userId == userId;
                            final senderName = isCurrentUser
                                ? "You"
                                : chat.lastMessage!.userName;

                            // Check for attachments
                            if (chat.lastMessage!.attachments.isNotEmpty) {
                              final hasAudio = chat.lastMessage!.attachments
                                  .any((attachment) =>
                                      attachment != null &&
                                      AudioRecordService.audioExtensions.any(
                                          (ext) => attachment.endsWith(ext)));

                              if (hasAudio) {
                                lastMsg = "$senderName sent an audio";
                              } else {
                                lastMsg = "$senderName sent an attachment";
                              }
                            } else if (chat.lastMessage!.text.isNotEmpty) {
                              lastMsg =
                                  "$senderName: ${chat.lastMessage!.text}";
                            } else {
                              lastMsg = "No messages yet";
                            }
                          }
                        } else {
                          lastMsg = "No messages yet";
                        }

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
                                  titleAlignment: ListTileTitleAlignment.center,
                                  horizontalTitleGap: 8,
                                  leading: const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.secondaryDark,
                                    child: Icon(
                                      Icons.groups,
                                      size: 20,
                                    ),
                                  ),
                                  title: AppText.titleMedium(
                                      ChatService.getChatTitle(chat, userId)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText.bodyMedium(
                                        lastMsg,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.grey[600],
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
                                        Routes.fileChat(chat.fileId, chat.id));
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
