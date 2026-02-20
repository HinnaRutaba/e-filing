import 'dart:async';

import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
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
  bool _isProcessing = false;

  // Selection lists
  final List<ChatParticipantModel> _selectedToAdd = [];
  final List<ChatParticipantModel> _selectedToRemove = [];

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

  bool _isSelectedToAdd(ChatParticipantModel participant) {
    return _selectedToAdd.any((p) =>
        p.userId == participant.userId &&
        p.userDesignationId == participant.userDesignationId);
  }

  bool _isSelectedToRemove(ChatParticipantModel participant) {
    return _selectedToRemove.any((p) =>
        p.userId == participant.userId &&
        p.userDesignationId == participant.userDesignationId);
  }

  void _toggleAddSelection(ChatParticipantModel participant) {
    HelperUtils.hideKeyboard(context);
    setState(() {
      if (_isSelectedToAdd(participant)) {
        _selectedToAdd.removeWhere((p) =>
            p.userId == participant.userId &&
            p.userDesignationId == participant.userDesignationId);
      } else {
        _selectedToAdd.add(participant);
      }
    });
  }

  void _toggleRemoveSelection(ChatParticipantModel participant) {
    HelperUtils.hideKeyboard(context);
    setState(() {
      if (_isSelectedToRemove(participant)) {
        _selectedToRemove.removeWhere((p) =>
            p.userId == participant.userId &&
            p.userDesignationId == participant.userDesignationId);
      } else {
        _selectedToRemove.add(participant);
      }
    });
  }

  Future<void> _processSelections() async {
    final uid = ref.read(authController).id;
    if (_selectedToAdd.isEmpty && _selectedToRemove.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // Process additions
      if (_selectedToAdd.isNotEmpty) {
        await widget._chatService.addParticipants(
          chatId: widget.chatId,
          newParticipants: _selectedToAdd,
          addedByUserId: uid!,
        );
      }

      // Process removals
      for (final participant in _selectedToRemove) {
        await widget._chatService.removeParticipant(
          chatId: widget.chatId,
          userId: participant.userId!,
          removedByUserId: uid!,
        );
      }

      // Check if current user left
      final currentUserLeft = _selectedToRemove.any((p) => p.userId == uid);

      setState(() {
        _selectedToAdd.clear();
        _selectedToRemove.clear();
        _isProcessing = false;
      });

      // Navigate away if current user left
      if (currentUserLeft) {
        RouteHelper.pop();
        RouteHelper.pop();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _getButtonText() {
    if (_isProcessing) return 'Processing...';

    final addCount = _selectedToAdd.length;
    final removeCount = _selectedToRemove.length;

    if (addCount > 0 && removeCount > 0) {
      return 'Add $addCount & Remove $removeCount';
    } else if (addCount > 0) {
      return 'Add $addCount Participant${addCount > 1 ? 's' : ''}';
    } else if (removeCount > 0) {
      return 'Remove $removeCount Participant${removeCount > 1 ? 's' : ''}';
    }
    return 'Select participants';
  }

  Color _getButtonColor() {
    if (_selectedToAdd.isEmpty && _selectedToRemove.isEmpty) {
      return AppColors.disabled;
    }
    if (_selectedToRemove.isNotEmpty && _selectedToAdd.isEmpty) {
      return Colors.orange[900]!;
    }
    return AppColors.primaryDark;
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(authController).id;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chatData.activeParticipants.isEmpty &&
        widget.participantsToAdd.isEmpty) {
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

    final hasSelection =
        _selectedToAdd.isNotEmpty || _selectedToRemove.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: AppText.titleLarge(
                      widget.addMembers
                          ? "Add Participants"
                          : "Manage Participants",
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => RouteHelper.pop(),
                    icon:
                        const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: AppTextField(
            controller: _searchController,
            hintText: 'Search participants',
            labelText: '',
            showLabel: false,
            prefix: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear,
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

        // Participants lists
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // Active participants section
              if (filteredActive.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: AppText.labelMedium(
                    'In Chat (${filteredActive.length})',
                    color: AppColors.textSecondary,
                  ),
                ),
                ...filteredActive.map((participant) {
                  final isSelected = _isSelectedToRemove(participant);
                  final isCurrentUser = uid == participant.userId;

                  return _ParticipantTile(
                    key: ValueKey(
                        '${participant.userId}_${participant.userDesignationId}'),
                    participant: participant,
                    isSelected: isSelected,
                    isCurrentUser: isCurrentUser,
                    isInChat: true,
                    onTap: () => _toggleRemoveSelection(participant),
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Not in chat section
              if (filteredNotInChat.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: AppText.labelMedium(
                    'Available to Add (${filteredNotInChat.length})',
                    color: AppColors.textSecondary,
                  ),
                ),
                ...filteredNotInChat.map((participant) {
                  final isSelected = _isSelectedToAdd(participant);

                  return _ParticipantTile(
                    key: ValueKey(
                        'add_${participant.userId}_${participant.userDesignationId}'),
                    participant: participant,
                    isSelected: isSelected,
                    isCurrentUser: false,
                    isInChat: false,
                    onTap: () => _toggleAddSelection(participant),
                  );
                }),
              ],

              // Empty state
              if (filteredActive.isEmpty && filteredNotInChat.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        AppText.titleMedium(
                          _searchController.text.isEmpty
                              ? 'No participants available'
                              : 'No participants found',
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Bottom button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: AppSolidButton(
                onPressed: (hasSelection && !_isProcessing)
                    ? _processSelections
                    : null,
                backgroundColor: _getButtonColor(),
                text: _getButtonText(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final ChatParticipantModel participant;
  final bool isSelected;
  final bool isCurrentUser;
  final bool isInChat;
  final VoidCallback onTap;

  const _ParticipantTile({
    super.key,
    required this.participant,
    required this.isSelected,
    required this.isCurrentUser,
    required this.isInChat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectionColor =
        isInChat ? Colors.orange[800]! : AppColors.primaryDark;

    return Container(
      // duration: const Duration(milliseconds: 200),
      // curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? selectionColor.withAlpha(8) : null,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: selectionColor, width: 0) : null,
      ),
      child: ListTile(
        contentPadding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 8, vertical: 0)
            : EdgeInsets.zero,
        horizontalTitleGap: 8,
        leading: CircleAvatar(
          backgroundColor: isSelected ? selectionColor : AppColors.secondary,
          radius: 16,
          child: AppText.titleLarge(
            HelperUtils.firstTwoLetters(participant.userTitle ?? ''),
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: AppText.titleMedium(
                participant.userTitle ?? 'Unknown User',
                fontSize: 16,
                color: isSelected ? selectionColor : null,
              ),
            ),
            if (isCurrentUser)
              AppText.labelSmall(
                "(You)",
                color: isSelected ? selectionColor : AppColors.textSecondary,
              ),
          ],
        ),
        subtitle: Container(
          margin: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectionColor.withOpacity(0.1)
                        : AppColors.cardColor,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: selectionColor.withOpacity(0.3))
                        : null,
                  ),
                  child: AppText.labelMedium(
                    participant.designation ?? '',
                    fontSize: 12,
                    color:
                        isSelected ? selectionColor : AppColors.textSecondary,
                  ),
                ),
              ),
              if (isInChat) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppText.labelSmall(
                    'Member',
                    fontSize: 10,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: isSelected
            ? Icon(
                isInChat ? Icons.remove_circle : Icons.check_circle,
                color: selectionColor,
              )
            : Icon(
                isInChat
                    ? Icons.remove_circle_outline
                    : Icons.add_circle_outline,
                color: AppColors.textSecondary,
              ),
        onTap: onTap,
      ),
    );
  }
}
