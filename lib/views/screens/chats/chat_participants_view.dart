import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatParticipantsView extends ConsumerWidget {
  final String chatId;
  final List<ChatParticipantModel> participantsToAdd;
  final bool addMembers;
  final ChatService _chatService = ChatService();

  ChatParticipantsView({
    super.key,
    required this.chatId,
    required this.participantsToAdd,
    this.addMembers = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authController).id;
    return StreamBuilder<ChatModel>(
      stream: _chatService.readChatStream(chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData && participantsToAdd.isEmpty) {
          return const Center(child: Text("No participants found"));
        }

        final chat = snapshot.data!;

        final notInChatParticipants = participantsToAdd
            .where((p) => !chat.activeParticipants
                .any((ap) => ap.userId == p.userId && !ap.removed))
            .toList();

        final activeParticipants = chat.activeParticipants
            .where((ap) => !ap.removed)
            .toList()
          ..sort((a, b) => (b.joinedAt ?? DateTime.now())
              .compareTo(a.joinedAt ?? DateTime.now()));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: AppText.headlineSmall(
                      addMembers ? "Add Participants" : "Participants",
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      RouteHelper.pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                // padding: const EdgeInsets.symmetric(vertical: 12),
                child: addMembers
                    ? Column(
                        children: [
                          _NotAddedParticipantsWidget(
                            participants: notInChatParticipants,
                            chatService: _chatService,
                            chatId: chatId,
                            uid: uid!,
                          ),
                          Divider(
                            color: Colors.grey[200]!,
                            thickness: 4,
                            height: 16,
                          ),
                          _AddedParticipantsWidget(
                            participants: activeParticipants,
                            chatService: _chatService,
                            chatId: chatId,
                            uid: uid,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _AddedParticipantsWidget(
                            participants: activeParticipants,
                            chatService: _chatService,
                            chatId: chatId,
                            uid: uid!,
                          ),
                          const Divider(
                            color: AppColors.cardColor,
                            thickness: 1,
                            height: 0,
                          ),
                          _NotAddedParticipantsWidget(
                            participants: notInChatParticipants,
                            chatService: _chatService,
                            chatId: chatId,
                            uid: uid,
                            showUnavailableMessage: false,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NotAddedParticipantsWidget extends StatelessWidget {
  final List<ChatParticipantModel> participants;
  final ChatService chatService;
  final String chatId;
  final int uid;
  final bool showUnavailableMessage;

  const _NotAddedParticipantsWidget({
    required this.participants,
    required this.chatService,
    required this.chatId,
    required this.uid,
    this.showUnavailableMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    return participants.isEmpty && showUnavailableMessage
        ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: AppText.titleMedium(
                'No participants available to add',
                color: AppColors.textSecondary,
              ),
            ),
          )
        : ListView.separated(
            itemCount: participants.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final participant = participants[index];
              final isCurrentUser = uid == participant.userId;

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                dense: true,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  radius: 14,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                horizontalTitleGap: 10,
                title: Row(
                  children: [
                    Expanded(
                      child: AppText.titleMedium(
                        participant.userTitle ?? '',
                        fontSize: 14,
                      ),
                    ),
                    if (isCurrentUser) AppText.labelSmall("(You)")
                  ],
                ),
                subtitle: AppText.labelMedium(
                  participant.designation ?? '',
                  fontSize: 12,
                ),
                trailing: AppTextLinkButton(
                  onPressed: () {
                    chatService.addParticipants(
                      chatId: chatId,
                      newParticipants: [participant],
                    );
                  },
                  text: "Add +",
                  color: AppColors.primaryDark,
                  fontSize: 14,
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(
              color: AppColors.cardColor,
              endIndent: 16,
              indent: 16,
              thickness: 0.8,
              height: 0,
            ),
          );
  }
}

class _AddedParticipantsWidget extends StatelessWidget {
  final List<ChatParticipantModel> participants;
  final ChatService chatService;
  final String chatId;
  final int uid;

  const _AddedParticipantsWidget({
    required this.participants,
    required this.chatService,
    required this.chatId,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return participants.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: AppText.titleMedium(
                'No active participants',
                color: AppColors.textSecondary,
              ),
            ),
          )
        : ListView.separated(
            itemCount: participants.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final participant = participants[index];
              final isCurrentUser = uid == participant.userId;

              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                dense: true,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.secondary,
                  radius: 14,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                horizontalTitleGap: 10,
                title: Row(
                  children: [
                    Expanded(
                      child: AppText.titleMedium(
                        participant.userTitle ?? '',
                        fontSize: 14,
                      ),
                    ),
                    if (isCurrentUser) AppText.labelSmall("(You)")
                  ],
                ),
                subtitle: AppText.labelMedium(
                  participant.designation ?? '',
                  fontSize: 12,
                ),
                trailing: AppTextLinkButton(
                  onPressed: () {
                    chatService.removeParticipant(
                      chatId: chatId,
                      userId: participant.userId!,
                    );
                    // Navigate to chats screen if current user leaves
                    if (isCurrentUser) {
                      RouteHelper.pop();
                      RouteHelper.pop();
                    }
                  },
                  text: isCurrentUser
                      ? participant.removed
                          ? ""
                          : "Leave"
                      : "Remove",
                  color: AppColors.error,
                  fontSize: 14,
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(
              color: AppColors.cardColor,
              endIndent: 16,
              indent: 16,
              thickness: 0.8,
              height: 0,
            ),
          );
  }
}
