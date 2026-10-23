import 'dart:math' as math;

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/department/department_user_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/services/record_audio_service.dart';
import 'package:efiling_balochistan/views/gradient_scaffold.dart';
import 'package:efiling_balochistan/views/screens/base_screen/base_screen.dart';
import 'package:efiling_balochistan/views/screens/chats/new_chat_bottom_sheet.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
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
              child: StatefulBuilder(
                builder: (context, dState) {
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
                              String chatId = await ChatService()
                                  .createChatRoom(
                                    fileId: null,
                                    subject: chatName,
                                    chatType: ChatType.group,
                                    participants: [
                                      DepartmentUserModel(
                                        userDesignationId: currentUser
                                            .currentDesignation!
                                            .userDesgId!,
                                        userId: currentUser.id!,
                                        userTitle: currentUser.userTitle!,
                                        designation: currentUser
                                            .currentDesignation!
                                            .designation!,
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
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel currentUser = ref.read(authController);
    return GradientScaffold(
      child: BaseScreen(
        bgColor: Colors.transparent,
        isdash: false,
        title: "Chats",
        enableBackButton: true,
        actions: [
          InkWell(
            onTap: () => _showNewChatBottomSheet(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: AppColors.secondaryDark, size: 20),
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
              return _ChatFilterBar(
                allCountStream: _chatService.getAllChatsCountStream(
                  userId: userId,
                  userDesignationId: userDesignationId,
                ),
                unreadCountStream: _chatService.getUnreadChatsCountStream(
                  userId: userId,
                  userDesignationId: userDesignationId,
                ),
                selected: filter,
                onChanged: (value) => _filter.value = value,
              );
            },
          ),
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

                    final chats = snapshot.data ?? const <ChatModel>[];
                    final filteredChats = filter == "Unread"
                        ? chats
                              .where(
                                (chat) => chat.hasUnread(userDesignationId),
                              )
                              .toList()
                        : chats;

                    if (filteredChats.isEmpty) {
                      return _EmptyChats(unreadOnly: filter == "Unread");
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filteredChats.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final chat = filteredChats[index];
                        return _ChatTile(
                              chat: chat,
                              title: ChatService.getChatTitle(chat, userId),
                              lastMessage: _lastMessageText(chat),
                              hasUnread: chat.hasUnread(userDesignationId),
                              onTap: () => RouteHelper.push(
                                Routes.fileChat(chat.fileId, chat.id),
                              ),
                            )
                            .animate(delay: (math.min(index, 8) * 50).ms)
                            .fadeIn(duration: 300.ms)
                            .slideY(
                              begin: 0.15,
                              end: 0,
                              duration: 300.ms,
                              curve: Curves.easeOutCubic,
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

  String _lastMessageText(ChatModel chat) {
    if (!_chatService.isParticipantInChat(chat: chat, userId: userId)) {
      return "You are no longer in this discussion";
    }

    final lastMessage = chat.lastMessage;
    if (lastMessage == null) return "No messages yet";

    // Don't show messages sent before the user joined.
    final userParticipant = chat.participants
        .where(
          (p) => p.userId == userId && p.userDesignationId == userDesignationId,
        )
        .firstOrNull;
    if (userParticipant?.joinedAt?.isAfter(lastMessage.sentAt) == true) {
      return "No messages yet";
    }

    final senderName = lastMessage.userId == userId
        ? "You"
        : lastMessage.userName;

    if (lastMessage.attachments.isNotEmpty) {
      final hasAudio = lastMessage.attachments.any(
        (attachment) =>
            attachment != null &&
            AudioRecordService.audioExtensions.any(
              (ext) => attachment.endsWith(ext),
            ),
      );
      return hasAudio
          ? "$senderName sent an audio"
          : "$senderName sent an attachment";
    }
    if (lastMessage.text.isNotEmpty) return "$senderName: ${lastMessage.text}";
    return "No messages yet";
  }
}

/// Compact filter chips for "All" / "Unread", each with a live count.
class _ChatFilterBar extends StatelessWidget {
  const _ChatFilterBar({
    required this.allCountStream,
    required this.unreadCountStream,
    required this.selected,
    required this.onChanged,
  });

  final Stream<int> allCountStream;
  final Stream<int> unreadCountStream;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          _FilterChip(
            label: "All",
            value: "All",
            countStream: allCountStream,
            selected: selected == "All",
            onTap: onChanged,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: "Unread",
            value: "Unread",
            countStream: unreadCountStream,
            selected: selected == "Unread",
            onTap: onChanged,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.countStream,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final Stream<int> countStream;
  final bool selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fg = selected ? Colors.white : colors.textSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? colors.primaryDark
                : colors.border.withValues(alpha: 0.8),
          ),
        ),
        child: StreamBuilder<int>(
          stream: countStream,
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return Text(
              count > 0 ? "$label  $count" : label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.title,
    required this.lastMessage,
    required this.hasUnread,
    required this.onTap,
  });

  final ChatModel chat;
  final String title;
  final String lastMessage;
  final bool hasUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final sentAt = chat.lastMessage?.sentAt;
    final barcode = chat.fileBarCode;

    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              _ChatAvatar(chat: chat, title: title),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        if (sentAt != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(sentAt),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: hasUnread
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: hasUnread
                                  ? colors.primaryDark
                                  : colors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            barcode != null && barcode.isNotEmpty
                                ? "$barcode · $lastMessage"
                                : lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: hasUnread
                                  ? colors.textPrimary
                                  : colors.textSecondary,
                            ),
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) {
      return "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }
    if (diff == 1) return "Yesterday";
    return "${dt.day}/${dt.month}/${dt.year}";
  }
}

/// Soft tinted circle with initials (direct) or a group icon.
class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.chat, required this.title});

  final ChatModel chat;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDirect = chat.type == ChatType.direct;

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.secondaryDark.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: isDirect
          ? Text(
              _initials(title),
              style: TextStyle(
                color: colors.secondaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            )
          : Icon(Icons.groups_rounded, color: colors.secondaryDark, size: 20),
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats({required this.unreadOnly});

  final bool unreadOnly;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.primaryDark.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                unreadOnly
                    ? Icons.mark_chat_read_outlined
                    : Icons.chat_bubble_outline_rounded,
                size: 32,
                color: colors.primaryDark,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              unreadOnly ? "You're all caught up" : "No chats yet",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              unreadOnly
                  ? "No unread conversations."
                  : "Start a new chat or group to get going.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
