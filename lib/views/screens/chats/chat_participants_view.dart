import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/services/chat_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatParticipantsView extends ConsumerWidget {
  final String chatId;
  final ChatService _chatService = ChatService();

  ChatParticipantsView({super.key, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(authController).id;
    return StreamBuilder<ChatModel>(
      stream: _chatService.readChatStream(chatId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No chat found"));
        }

        final chat = snapshot.data!;
        final List<ParticipantModel> participants = chat.activeParticipants;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: AppText.headlineSmall(
                      "Participants",
                      color: AppColors.secondaryDark,
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

            // Participants List
            Expanded(
              child: ListView.separated(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      radius: 16,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    title: AppText.titleMedium(
                      participant.userTitle ?? '',
                    ),
                    subtitle: AppText.labelMedium(
                      participant.designation ?? '',
                    ),
                    trailing: AppTextLinkButton(
                      onPressed: () {
                        _chatService.removeParticipant(
                          chatId: chatId,
                          userId: participant.userId!,
                        );
                      },
                      text: uid == participant.userId ? "Leave" : "Remove",
                      color: AppColors.error,
                      fontSize: 14,
                    ),
                  );
                },
                separatorBuilder: (_, __) => const Divider(
                  color: AppColors.disabled,
                  endIndent: 16,
                  indent: 16,
                  thickness: 0.8,
                  height: 0,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
