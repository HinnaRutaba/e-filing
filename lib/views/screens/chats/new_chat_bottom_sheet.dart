import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/config/router/routes.dart';
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

class NewChatBottomSheet extends ConsumerStatefulWidget {
  const NewChatBottomSheet({super.key});

  @override
  ConsumerState<NewChatBottomSheet> createState() => _NewChatBottomSheetState();
}

class _NewChatBottomSheetState extends ConsumerState<NewChatBottomSheet> {
  late TextEditingController _searchController;
  List<ChatParticipantModel> _allParticipants = [];
  List<ChatParticipantModel> _filteredParticipants = [];
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
    });
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
      height: MediaQuery.of(context).size.height * 0.8,
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppText.headlineSmall(
                        "Start New Chat",
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => RouteHelper.pop(),
                      icon: const Icon(Icons.close),
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

                          return ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: AppColors.secondary,
                              radius: 20,
                              child: Text(
                                (participant.userTitle?.isNotEmpty == true)
                                    ? participant.userTitle![0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: AppText.titleMedium(
                              participant.userTitle ?? 'Unknown User',
                              fontSize: 16,
                            ),
                            subtitle: AppText.labelMedium(
                              participant.designation ?? '',
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            trailing: _isCreatingChat
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(
                                    Icons.chat_bubble_outline,
                                    color: AppColors.primaryDark,
                                  ),
                            onTap: _isCreatingChat
                                ? null
                                : () => _createChatWithUser(participant),
                          );
                        },
                        separatorBuilder: (_, __) => const Divider(
                          color: AppColors.cardColor,
                          thickness: 1,
                          height: 1,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
