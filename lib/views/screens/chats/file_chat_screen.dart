import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/controllers/controllers.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/chat/message_model.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:efiling_balochistan/models/user_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_service.dart';
import 'package:efiling_balochistan/utils/helper_utils.dart';
import 'package:efiling_balochistan/views/screens/chats/chat_input_bar.dart';
import 'package:efiling_balochistan/views/screens/chats/chat_participants_view.dart';
import 'package:efiling_balochistan/views/screens/files/flag_attachement/read_only_flag_attachment.dart';
import 'package:efiling_balochistan/views/screens/files/preview_file.dart';
import 'package:efiling_balochistan/views/screens/sticky_tag_drawer.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class FileChatScreen extends ConsumerStatefulWidget {
  final int fileId;
  final FileDetailsModel? fileDetails;

  const FileChatScreen(
      {super.key, required this.fileId, required this.fileDetails});

  @override
  _FileChatScreenState createState() => _FileChatScreenState();
}

class _FileChatScreenState extends ConsumerState<FileChatScreen> {
  final ChatService chatService = ChatService();
  FileDetailsModel? file;
  final Uuid _uuid = const Uuid();
  List<ChatParticipantModel> potentialParticipantsToAdd = [];
  List<MessageModel> _olderMessages = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoadingMore = false;

  ChatModel? chat;
  bool _loading = true;

  UserModel get _currentUser => ref.read(authController);

  Future<void> _loadMore() async {
    if (_isLoadingMore || _lastDoc == null) return;
    setState(() => _isLoadingMore = true);

    final older = await chatService.loadMoreMessages(
      chatId: chat!.id,
      lastDoc: _lastDoc!,
    );

    if (older.isNotEmpty) {
      setState(() {
        _olderMessages.addAll(older);
        _lastDoc = null; // update with snapshot.docs.last
      });
    }

    setState(() => _isLoadingMore = false);
  }

  types.Message _mapMessage(MessageModel message) {
    if (message.attachments.isNotEmpty) {
      final url = message.attachments.first;

      if (url.endsWith(".m4a") ||
          url.endsWith(".aac") ||
          url.endsWith(".mp3")) {
        return types.AudioMessage(
          id: message.id,
          author: types.User(
            id: message.userId.toString(),
            firstName: message.userName,
          ),
          createdAt: message.sentAt.millisecondsSinceEpoch,
          name: url.split('/').last,
          size: 0,
          uri: url,
          duration: const Duration(),
        );
      }
    }

    return types.TextMessage(
      id: message.id,
      author: types.User(
        id: message.userId.toString(),
        firstName: message.userName,
      ),
      createdAt: message.sentAt.millisecondsSinceEpoch,
      text: message.text,
    );
  }

  void _handleSendPressed(types.PartialText message) async {
    if (chat?.id == null) return;

    final msg = MessageModel(
      id: _uuid.v4(),
      text: message.text,
      userId: _currentUser.id!,
      userName: _currentUser.userTitle!,
      userDesignationId: _currentUser.currentDesignation!.userDesgId!,
      sentAt: DateTime.now(),
    );

    await chatService.sendMessage(chat: chat!, message: msg);
  }

  Future<void> _getChatRoom() async {
    try {
      String? chatId = await chatService.getChatFromFile(widget.fileId);
      if (chatId == null) {
        setState(() {
          _loading = false;
        });
      } else {
        _initChatRoom();
      }
    } catch (e, s) {
      print("Error getting chat room: $e \n $s");
    }
  }

  Future<void> _initChatRoom() async {
    try {
      setState(() {
        _loading = true;
      });
      await _fetchFileDetails();
      final participants = [
        ChatParticipantModel(
          userDesignationId: _currentUser.currentDesignation!.userDesgId!,
          userId: _currentUser.id!,
          userTitle: _currentUser.userTitle!,
          designation: _currentUser.currentDesignation!.designation!,
          joinedAt: DateTime.now(),
          removed: false,
          removedAt: null,
        ),
      ];

      String subject = '';
      if (file != null &&
          file!.content != null &&
          file!.content!.isNotEmpty &&
          file!.content!.first.subject != null) {
        subject = file!.content!.first.subject!;
      }

      final chatId = await chatService.createChatRoom(
        fileId: widget.fileId,
        subject: subject,
        participants: participants,
      );

      chat = await chatService.getChat(chatId);

      chatService.markAllMessagesAsRead(
        chatId: chat!.id,
        userDesignationId: _currentUser.currentDesignation!.userDesgId!,
      );

      setState(() {
        _loading = false;
      });
    } catch (e, s) {
      print("Error init chat room: $e \n $s");
    }
  }

  Future<void> _fetchFileDetails() async {
    try {
      if (widget.fileDetails != null) {
        file = widget.fileDetails;
      } else {
        file = await ref.read(chatRepo).getFileDetailsForChat(widget.fileId);
      }
      setState(() {});
    } catch (e) {
      print("Error fetching file details: $e");
    }
  }

  Future<void> fetchParticipants() async {
    potentialParticipantsToAdd = await ref
        .read(chatRepo)
        .getUsersForChat(_currentUser.currentDesignation!.userDesgId!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchParticipants();
    _getChatRoom();
    //_initChatRoom();
  }

  ChatParticipantModel? get participant => chat == null
      ? null
      : chatService.currentParticipant(chat: chat!, userId: _currentUser.id!);

  String _formatMessageTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return DateFormat('HH:mm').format(dt);
    }
    return DateFormat('dd MMM, HH:mm').format(dt);
  }

  String _getDeliveryStatus(types.Message message) {
    final isMe = message.author.id == _currentUser.id.toString();
    if (!isMe) return '';

    if (chat == null) return '';

    if (message.status == null) return '✓';

    // Check if message has status property and return appropriate indicator
    switch (message.status!) {
      case types.Status.sending:
        return '•';
      case types.Status.sent:
        return '✓';
      case types.Status.delivered:
        return '✓✓';
      case types.Status.seen:
        return '✓✓';
      case types.Status.error:
        return '⚠';
    }
  }

  @override
  Widget build(BuildContext context) {
    return chat == null
        ? Scaffold(
            appBar: AppBar(
              title: AppText.headlineSmall(
                "File Discussion",
                color: AppColors.primaryDark,
              ),
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: 0,
              backgroundColor: AppColors.background,
              leading: IconButton(
                onPressed: () => RouteHelper.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            body: Center(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText.bodyMedium(" No chat available for this file."),
                        AppSolidButton(
                            onPressed: () {
                              _initChatRoom();
                            },
                            text: "Start Chat"),
                      ],
                    ),
            ),
          )
        : Scaffold(
            //backgroundColor: Colors.grey[900],
            appBar: AppBar(
              title: StreamBuilder<ChatModel>(
                  stream: chat == null
                      ? null
                      : chatService.readChatStream(chat!.id),
                  builder: (context, snapshot) {
                    final Widget title = AppText.headlineSmall(
                      "File Discussion",
                      color: AppColors.primaryDark,
                    );
                    if (!snapshot.hasData) {
                      return title;
                    }
                    final chat = snapshot.data!;
                    bool isUserActive = chatService.isParticipantInChat(
                      chat: chat,
                      userId: _currentUser.id!,
                    );
                    return !isUserActive
                        ? title
                        : Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: chat.activeParticipants.isEmpty == true
                                      ? null
                                      : () {
                                          showModalBottomSheet(
                                            context: context,
                                            constraints: BoxConstraints(
                                              maxHeight:
                                                  MediaQuery.sizeOf(context)
                                                          .height *
                                                      0.9,
                                            ),
                                            isScrollControlled: true,
                                            enableDrag: false,
                                            backgroundColor:
                                                AppColors.background,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(16),
                                                topRight: Radius.circular(16),
                                              ),
                                            ),
                                            builder: (BuildContext context) {
                                              return ChatParticipantsView(
                                                chatId: chat.id,
                                                participantsToAdd:
                                                    potentialParticipantsToAdd,
                                              );
                                            },
                                          );
                                        },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      title,
                                      AppText.labelMedium(
                                        "${chat.activeParticipants.length} ${chat.activeParticipants.length > 1 ? "Participants" : "Participant"}",
                                        color: AppColors.textPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ...[
                                IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.sizeOf(context).height *
                                                0.9,
                                      ),
                                      isScrollControlled: true,
                                      enableDrag: false,
                                      backgroundColor: AppColors.background,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      builder: (BuildContext context) {
                                        return ChatParticipantsView(
                                          chatId: chat.id,
                                          participantsToAdd:
                                              potentialParticipantsToAdd,
                                          addMembers: true,
                                        );
                                        //   ChatAddParticipant(
                                        //   chatId: chat!.id,
                                        //   userDesgId: _currentUser
                                        //       .currentDesignation!.userDesgId!,
                                        // );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.person_add_rounded,
                                    size: 22,
                                  ),
                                  color: AppColors.secondaryDark,
                                ),
                                IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.sizeOf(context).height *
                                                0.9,
                                      ),
                                      isScrollControlled: true,
                                      backgroundColor: AppColors.background,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                      ),
                                      builder: (BuildContext context) {
                                        return StickyTagDrawer(
                                          mainContent: SingleChildScrollView(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child:
                                                          AppText.headlineSmall(
                                                              "File Preview"),
                                                    ),
                                                    IconButton(
                                                      onPressed: () =>
                                                          RouteHelper.pop(),
                                                      icon: const Icon(
                                                        Icons.close,
                                                        color: AppColors
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                PreviewFile(
                                                  content: file?.content,
                                                ),
                                              ],
                                            ),
                                          ),
                                          flagText: "Flags",
                                          panelContent: SingleChildScrollView(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      16, 0, 16, 16),
                                              child: file?.attachments !=
                                                          null &&
                                                      file!.attachments
                                                          .isNotEmpty
                                                  ? ReadOnlyFlagAttachmentList(
                                                      header:
                                                          AppText.titleMedium(
                                                              "Attached Flags"),
                                                      data: file!.attachments,
                                                    )
                                                      .animate(delay: 100.ms)
                                                      .fade(
                                                          duration: 400.ms,
                                                          curve:
                                                              Curves.easeInOut)
                                                      .slide(
                                                          begin: const Offset(
                                                              1, 0),
                                                          end: Offset.zero)
                                                  : Center(
                                                      child: AppText.bodyMedium(
                                                          "No flags available"),
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.file_copy_outlined,
                                    size: 22,
                                  ),
                                  color: AppColors.secondaryDark,
                                ),
                              ],
                            ],
                          );
                  }),
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: 0,
              backgroundColor: AppColors.background,
              leading: IconButton(
                onPressed: () => RouteHelper.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            body: _loading
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<MessageModel>>(
                    stream: chatService.readRecentMessagesStream(chat!.id),
                    builder: (context, snapshot) {
                      //print("ERRR______${snapshot.error}_____${snapshot.stackTrace}");
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final latest = snapshot.data!
                          .where((e) => !(e.hiddenFrom?.contains(_currentUser!
                                  .currentDesignation!.userDesgId) ??
                              false))
                          .toList();

                      final allMessages = [..._olderMessages, ...latest]
                          .map(_mapMessage)
                          .toList();

                      chatService.markAllMessagesAsRead(
                        chatId: chat!.id,
                        userDesignationId:
                            _currentUser.currentDesignation!.userDesgId!,
                      );

                      return Chat(
                        messages: allMessages,
                        // messages
                        //     .where((m) => participant?.removedAt == null
                        //         ? true
                        //         : m.createdAt! <
                        //             participant!
                        //                 .removedAt!.millisecondsSinceEpoch)
                        //     .toList(),
                        onSendPressed: (text) {
                          _handleSendPressed(text);
                        },
                        user: types.User(id: _currentUser.id.toString()),
                        onEndReached: _loadMore,
                        onEndReachedThreshold: 0.5,
                        timeFormat: DateFormat('HH:mm'),
                        dateFormat: DateFormat('dd MMM yyyy'),
                        customBottomWidget: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom,
                          ),
                          child: StreamBuilder<ChatModel>(
                              stream: chat == null
                                  ? null
                                  : chatService.readChatStream(chat!.id),
                              builder: (context, snapshot) {
                                if (snapshot.data == null) {
                                  return const SizedBox.shrink();
                                }
                                final chat = snapshot.data!;
                                this.chat = chat;
                                return !chatService.isParticipantInChat(
                                  chat: chat,
                                  userId: _currentUser.id!,
                                )
                                    ? Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: AppText.bodyMedium(
                                            "You are no longer part of this conversation."),
                                      )
                                    : Container(
                                        decoration: const BoxDecoration(
                                          color: AppColors.appBarColor,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(16),
                                            topLeft: Radius.circular(16),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              offset: Offset(0, -2),
                                              blurRadius: 2,
                                            )
                                          ],
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 8,
                                        ),
                                        child: ChatInputBar(
                                          chat: chat!,
                                          chatService: chatService,
                                          userId: _currentUser.id!,
                                          userDesignationId: _currentUser
                                              .currentDesignation!.userDesgId!,
                                          userTitle: _currentUser.userTitle!,
                                          onSendText: (text) {
                                            _handleSendPressed(
                                                types.PartialText(text: text));
                                          },
                                          onAttachmentPressed: () {
                                            // later: pick image/video/docs
                                          },
                                        ),
                                      );
                              }),
                        ),
                        theme: const DefaultChatTheme(
                          primaryColor: AppColors.secondaryLight,
                          secondaryColor: AppColors.cardColor,
                          inputTextColor: AppColors.textPrimary,
                          inputPadding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                          inputElevation: 18,
                          inputMargin: EdgeInsets.zero,
                          userNameTextStyle: TextStyle(
                            color: AppColors.secondaryDark,
                            fontSize: 12,
                            //fontWeight: FontWeight.w500,
                          ),
                          userAvatarNameColors: [
                            AppColors.secondary,
                            AppColors.primaryDark,
                            AppColors.secondaryDark,
                          ],
                          inputTextCursorColor: AppColors.primaryDark,
                          userAvatarImageBackgroundColor: AppColors.secondary,
                          bubbleMargin:
                              EdgeInsets.only(bottom: 8, left: 8, right: 0),
                          backgroundColor: AppColors.background,
                          sentMessageBodyTextStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          receivedMessageBodyTextStyle: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        showUserNames: true,
                        showUserAvatars: true,
                        avatarBuilder: (user) {
                          return Container(
                            alignment: Alignment.topLeft,
                            padding: const EdgeInsets.only(
                              bottom: 28,
                              left: 4,
                              right: 8,
                            ),
                            child: GestureDetector(
                              // onTap: () => onAvatarTap?.call(),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.secondary,
                                child: Text(
                                  HelperUtils.firstTwoLetters(
                                      "${user.firstName ?? ''} ${user.lastName ?? ''}"),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        bubbleBuilder: (child,
                            {required message, required nextMessageInGroup}) {
                          final isMe =
                              message.author.id == _currentUser.id.toString();
                          final dt = DateTime.fromMillisecondsSinceEpoch(
                              message.createdAt ??
                                  DateTime.now().millisecondsSinceEpoch);
                          final timeText = _formatMessageTime(dt);
                          final status = _getDeliveryStatus(message);

                          return Column(
                            crossAxisAlignment: isMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isMe)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    right: 4,
                                    bottom: 2,
                                  ),
                                  child: Text(
                                    [
                                      message.author.firstName ?? '',
                                      message.author.lastName ?? '',
                                    ]
                                        .where((part) => part.trim().isNotEmpty)
                                        .join(' '),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              Container(
                                margin: EdgeInsets.only(
                                  bottom: 0,
                                  left: isMe ? 8 : 0,
                                  right: isMe ? 0 : 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: isMe
                                      ? AppColors.secondaryLight
                                      : AppColors.cardColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: SelectableText(
                                  message is types.TextMessage
                                      ? message.text
                                      : message is types.AudioMessage
                                          ? '🎵 ${message.name}'
                                          : 'Message',
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      timeText,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    if (status.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        status,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          );
  }
}
