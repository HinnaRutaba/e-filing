import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
import 'package:efiling_balochistan/config/theme/theme.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/department/department_user_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
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
  List<DepartmentUserModel> _allParticipants = [];
  List<DepartmentUserModel> _filteredParticipants = [];
  DepartmentUserModel? _selectedParticipant;
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

      _allParticipants = participants
          .where((p) => p.userId != currentUser.id)
          .toList();

      _filteredParticipants = List.from(_allParticipants);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
      }
    }
  }

  void _filterParticipants(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredParticipants = List.from(_allParticipants);
      } else {
        _filteredParticipants = _allParticipants
            .where(
              (p) =>
                  (p.userTitle?.toLowerCase().contains(query.toLowerCase()) ??
                      false) ||
                  (p.designation?.toLowerCase().contains(query.toLowerCase()) ??
                      false),
            )
            .toList();
      }

      if (_selectedParticipant != null &&
          !_filteredParticipants.contains(_selectedParticipant)) {
        _selectedParticipant = null;
      }
    });
  }

  void _selectParticipant(DepartmentUserModel participant) {
    setState(() {
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

  Future<void> _createChatWithUser(DepartmentUserModel selectedUser) async {
    try {
      setState(() => _isCreatingChat = true);

      final currentUser = ref.read(authController);

      final existingChatId = await _chatService.getDirectChatBetweenUsers(
        currentUser.id!,
        selectedUser.userId!,
      );

      String chatId;

      if (existingChatId != null) {
        chatId = existingChatId;
      } else {
        final participants = [
          DepartmentUserModel(
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

      RouteHelper.pop();
      RouteHelper.push(Routes.fileChat(null, chatId));
    } catch (e) {
      setState(() => _isCreatingChat = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating chat: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.90,
      child: Column(
        children: [
          // Header with handle and title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: appColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppText.titleLarge(
                        "Start New Chat",
                        color: appColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => RouteHelper.pop(),
                      icon: Icon(
                        Icons.close,
                        color: appColors.textSecondary,
                      ),
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
                      icon: Icon(
                        Icons.clear,
                        color: appColors.secondaryLight,
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
                            color: appColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          AppText.titleMedium(
                            _searchController.text.isEmpty
                                ? 'No users available'
                                : 'No users found',
                            color: appColors.textSecondary,
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
                      final isSelected =
                          _selectedParticipant?.userId == participant.userId &&
                          _selectedParticipant?.userDesignationId ==
                              participant.userDesignationId;
                      final isOtherSelected =
                          _selectedParticipant != null && !isSelected;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? appColors.primaryDark.withAlpha(12)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color: appColors.primaryDark,
                                  width: 1.2,
                                )
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
                                  ? appColors.primaryDark
                                  : colorScheme.secondary,
                              radius: 16,
                              child: AppText.titleLarge(
                                HelperUtils.firstTwoLetters(
                                  participant.userTitle ?? '',
                                ),
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            title: AppText.titleMedium(
                              participant.userTitle ?? 'Unknown User',
                              fontSize: 16,
                              color: isSelected ? appColors.primaryDark : null,
                            ),
                            subtitle: Container(
                              margin: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? appColors.primaryDark
                                                .withValues(alpha:0.1)
                                            : appColors.cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: isSelected
                                            ? Border.all(
                                                color: appColors.primaryDark
                                                    .withValues(alpha:0.3),
                                              )
                                            : null,
                                      ),
                                      child: AppText.labelMedium(
                                        participant.designation ?? '',
                                        fontSize: 12,
                                        color: isSelected
                                            ? appColors.primaryDark
                                            : appColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: appColors.primaryDark,
                                  )
                                : Icon(
                                    Icons.add_circle_outline,
                                    color: appColors.textSecondary,
                                  ),
                            onTap: () {
                              HelperUtils.hideKeyboard(context);
                              _selectParticipant(participant);
                            },
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => Divider(
                      color: appColors.cardColor,
                      thickness: 1,
                      height: 1,
                    ),
                  ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: appColors.border)),
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
                      ? colorScheme.primary
                      : appColors.disabled,
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
