import 'dart:async';

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatParticipantsView extends ConsumerStatefulWidget {
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
  ConsumerState<ChatParticipantsView> createState() =>
      _ChatParticipantsViewState();
}

class _ChatParticipantsViewState extends ConsumerState<ChatParticipantsView> {
  late TextEditingController _searchController;
  late ChatModel _chatData;
  late StreamSubscription<ChatModel> _chatSubscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Initialize stream in initState
    _chatSubscription =
        widget._chatService.readChatStream(widget.chatId).listen((chatModel) {
      setState(() {
        _chatData = chatModel;
        _isLoading = false;
      });
    }, onError: (error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chatSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authController).id;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chatData == null && widget.participantsToAdd.isEmpty) {
      return const Center(child: Text("No participants found"));
    }

    final notInChatParticipants = widget.participantsToAdd
        .where((p) => !_chatData.activeParticipants
            .any((ap) => ap.userId == p.userId && !ap.removed))
        .toList();

    final activeParticipants = _chatData.activeParticipants
        .where((ap) => !ap.removed)
        .toList()
      ..sort((a, b) => (b.joinedAt ?? DateTime.now())
          .compareTo(a.joinedAt ?? DateTime.now()));

    // Filter participants based on search
    final searchQuery = _searchController.text.toLowerCase();
    final filteredNotInChat = notInChatParticipants
        .where((p) =>
            (p.userTitle?.toLowerCase().contains(searchQuery) ?? false) ||
            (p.designation?.toLowerCase().contains(searchQuery) ?? false))
        .toList();

    final filteredActive = activeParticipants
        .where((p) =>
            (p.userTitle?.toLowerCase().contains(searchQuery) ?? false) ||
            (p.designation?.toLowerCase().contains(searchQuery) ?? false))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: AppText.headlineSmall(
                  widget.addMembers ? "Add Participants" : "Participants",
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: AppTextField(
            controller: _searchController,
            hintText: 'Search participants',
            labelText: '',
            showLabel: false,
            prefix: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.refresh_outlined,
                      color: AppColors.secondaryLight,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            // padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                _AddedParticipantsWidget(
                  participants: filteredActive,
                  chatService: widget._chatService,
                  chatId: widget.chatId,
                  uid: uid!,
                ),
                const Divider(
                  color: AppColors.cardColor,
                  thickness: 1,
                  height: 0,
                ),
                _NotAddedParticipantsWidget(
                  participants: filteredNotInChat,
                  chatService: widget._chatService,
                  chatId: widget.chatId,
                  uid: uid,
                  showUnavailableMessage: false,
                ),
              ],
            ),
          ),
        ),
      ],
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
            padding: const EdgeInsets.all(0),
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
                subtitle: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppText.labelMedium(
                        participant.designation ?? '',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
            padding: const EdgeInsets.all(0),
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
                subtitle: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: AppText.labelMedium(
                        participant.designation ?? '',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
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
