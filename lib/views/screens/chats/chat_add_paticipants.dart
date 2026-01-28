import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatAddParticipant extends ConsumerWidget {
  final int userDesgId;
  final String chatId;
  final ChatService _chatService = ChatService();
  ChatAddParticipant(
      {super.key, required this.userDesgId, required this.chatId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<ChatParticipantModel>>(
      future: ref.read(chatRepo).getUsersForChat(userDesgId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return const Center(child: Text("No participants found"));
        }

        final List<ChatParticipantModel> participants = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: AppText.headlineSmall(
                      "Add Participants",
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      RouteHelper.pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textPrimary,
                    ),
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
                    title: AppText.titleMedium(
                      participant.userTitle ?? '',
                      fontSize: 14,
                    ),
                    subtitle: AppText.labelMedium(
                      participant.designation ?? '',
                      fontSize: 12,
                    ),
                    trailing: AppTextLinkButton(
                      onPressed: () {
                        _chatService.addParticipants(
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
              ),
            ),
          ],
        );
      },
    );
  }
}
