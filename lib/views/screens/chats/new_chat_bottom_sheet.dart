import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewChatBottomSheet extends ConsumerStatefulWidget {
  const NewChatBottomSheet({super.key});

  @override
  ConsumerState<NewChatBottomSheet> createState() => _NewChatBottomSheetState();
}

class _NewChatBottomSheetState extends ConsumerState<NewChatBottomSheet> {
  late TextEditingController _searchController;
  List<ChatParticipantModel> _allParticipants = [];
  List<ChatParticipantModel> _filteredParticipants = [];
  ChatParticipantModel? _selectedParticipant;
  bool _isLoading = true;
  bool _isCreatingChat = false;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _fetchParticipants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchParticipants() async {
    try {
      setState(() => _isLoading = true);

      final currentUser = ref.read(authController);
      final participants = await ref
          .read(chatRepo)
          .getUsersForChat(currentUser.currentDesignation!.userDesgId!);

      // Filter out the current user from the list
      _allParticipants =
          participants.where((p) => p.userId != currentUser.id).toList();

      _filteredParticipants = List.from(_allParticipants);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  void _filterParticipants(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredParticipants = List.from(_allParticipants);
      } else {
        _filteredParticipants = _allParticipants
            .where((p) =>
                (p.userTitle?.toLowerCase().contains(query.toLowerCase()) ??
                    false) ||
                (p.designation?.toLowerCase().contains(query.toLowerCase()) ??
                    false))
            .toList();
      }

      // Clear selection if filtered participant is no longer in results
      if (_selectedParticipant != null &&
          !_filteredParticipants.contains(_selectedParticipant)) {
        _selectedParticipant = null;
      }
    });
  }

  void _selectParticipant(ChatParticipantModel participant) {
    setState(() {
      // Toggle selection - if same participant is selected, deselect them
      if (_selectedParticipant?.userId == participant.userId &&
          _selectedParticipant?.userDesignationId ==
              participant.userDesignationId) {
        _selectedParticipant = null;
      } else {
        _selectedParticipant = participant;
      }
    });
  }

  Future<void> _startChatWithSelectedUser() async {
    if (_selectedParticipant == null) return;

    await _createChatWithUser(_selectedParticipant!);
  }

  Future<void> _createChatWithUser(ChatParticipantModel selectedUser) async {
    try {
      setState(() => _isCreatingChat = true);

      final currentUser = ref.read(authController);

      // First, check if a direct chat already exists between these two users
      final existingChatId = await _chatService.getDirectChatBetweenUsers(
        currentUser.id!,
        selectedUser.userId!,
      );

      String chatId;

      if (existingChatId != null) {
        chatId = existingChatId;
      } else {
        final participants = [
          ChatParticipantModel(
            userDesignationId: currentUser.currentDesignation!.userDesgId!,
            userId: currentUser.id!,
            userTitle: currentUser.userTitle!,
            designation: currentUser.currentDesignation!.designation!,
            joinedAt: DateTime.now(),
            removed: false,
            removedAt: null,
          ),
          selectedUser.copyWith(
            joinedAt: DateTime.now(),
            removed: false,
            removedAt: null,
          ),
        ];

        chatId = await _chatService.createChatRoom(
          fileId: null,
          subject: "Chat with ${selectedUser.userTitle}",
          participants: participants,
          chatType: ChatType.direct,
        );
      }

      setState(() => _isCreatingChat = false);

      // Close the bottom sheet and navigate to the chat
      RouteHelper.pop();
      RouteHelper.push(Routes.fileChat(null, chatId));
    } catch (e) {
      setState(() => _isCreatingChat = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header with handle and title
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
                        "Start New Chat",
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => RouteHelper.pop(),
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondary),
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
              hintText: 'Search users',
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
                        _filterParticipants('');
                      },
                    )
                  : null,
              onChanged: _filterParticipants,
            ),
          ),

          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredParticipants.isEmpty
                    ? Center(
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
                                    ? 'No users available'
                                    : 'No users found',
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredParticipants.length,
                        itemBuilder: (context, index) {
                          final participant = _filteredParticipants[index];
                          final isSelected = _selectedParticipant?.userId ==
                                  participant.userId &&
                              _selectedParticipant?.userDesignationId ==
                                  participant.userDesignationId;
                          final isOtherSelected =
                              _selectedParticipant != null && !isSelected;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 0),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryDark.withAlpha(12)
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primaryDark, width: 1.2)
                                  : null,
                            ),
                            child: Opacity(
                              opacity: isOtherSelected ? 0.4 : 1.0,
                              child: ListTile(
                                contentPadding: isSelected
                                    ? const EdgeInsets.symmetric(horizontal: 8)
                                    : const EdgeInsets.all(0),
                                horizontalTitleGap: 8,
                                leading: CircleAvatar(
                                  backgroundColor: isSelected
                                      ? AppColors.primaryDark
                                      : AppColors.secondary,
                                  radius: 16,
                                  child: AppText.titleLarge(
                                    HelperUtils.firstTwoLetters(
                                        participant.userTitle ?? ''),
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                title: AppText.titleMedium(
                                  participant.userTitle ?? 'Unknown User',
                                  fontSize: 16,
                                  color:
                                      isSelected ? AppColors.primaryDark : null,
                                ),
                                subtitle: Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primaryDark
                                                    .withOpacity(0.1)
                                                : AppColors.cardColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: isSelected
                                                ? Border.all(
                                                    color: AppColors.primaryDark
                                                        .withOpacity(0.3))
                                                : null,
                                          ),
                                          child: AppText.labelMedium(
                                            participant.designation ?? '',
                                            fontSize: 12,
                                            color: isSelected
                                                ? AppColors.primaryDark
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: AppColors.primaryDark,
                                      )
                                    : const Icon(
                                        Icons.add_circle_outline,
                                        color: AppColors.textSecondary,
                                      ),
                                onTap: () {
                                  HelperUtils.hideKeyboard(context);
                                  _selectParticipant(participant);
                                },
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(
                          color: AppColors.cardColor,
                          thickness: 1,
                          height: 1,
                        ),
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
                  onPressed: (_selectedParticipant != null && !_isCreatingChat)
                      ? _startChatWithSelectedUser
                      : null,
                  backgroundColor:
                      (_selectedParticipant != null && !_isCreatingChat)
                          ? AppColors.primary
                          : AppColors.disabled,
                  text: _isCreatingChat
                      ? 'Creating Chat...'
                      : _selectedParticipant != null
                          ? 'Start Chat with ${_selectedParticipant!.userTitle}'
                          : 'Select a user to start chat',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
