import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/views/screens/files/preview_file.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/text_link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:uuid/uuid.dart';

class FileChatScreen extends StatefulWidget {
  final int? fileId;

  const FileChatScreen({super.key, this.fileId});

  @override
  _FileChatScreenState createState() => _FileChatScreenState();
}

class _FileChatScreenState extends State<FileChatScreen> {
  final List<types.Message> _messages = [];
  final types.User _currentUser = types.User(id: "user_1");
  final types.User _chatPartner = types.User(id: "user_2");
  final Uuid _uuid = Uuid();

  void _handleSendPressed(types.PartialText message) {
    FocusScope.of(context).unfocus();
    final textMessage = types.TextMessage(
      author: _currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: message.text,
    );
    _messages.insert(0, textMessage);
    setState(() {});
    Future.delayed(const Duration(milliseconds: 2700), () {
      _messages.insert(
        0,
        types.TextMessage(
          author: _chatPartner,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: _uuid.v4(),
          text: "Hello!",
        ),
      );
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: AppText.headlineSmall(
          "File Discussion (FN-08980)",
          color: AppColors.primaryDark,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () {
            RouteHelper.pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: AppTextLinkButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.9),
                  showDragHandle: false,
                  isScrollControlled: true,
                  backgroundColor: AppColors.background,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppText.headlineSmall(
                                  "File Preview",
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
                          const PreviewFile(),
                        ],
                      ),
                    );
                  },
                );
              },
              text: "Open File",
              color: AppColors.secondary,
            ),
          )
        ],
        //backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Chat(
            messages: _messages,
            onSendPressed: _handleSendPressed,
            user: _currentUser,
            theme: const DefaultChatTheme(
              inputBackgroundColor: AppColors.white,
              inputTextDecoration: InputDecoration(
                fillColor: Colors.transparent,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: AppColors.primaryDark,
                ),
              ),
              primaryColor: AppColors.primary,
              secondaryColor: AppColors.secondary,
              inputTextColor: AppColors.textPrimary,
              sendButtonIcon: Icon(
                Icons.send_sharp,
                color: AppColors.primaryDark,
                size: 32,
              ),
              inputPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              inputElevation: 18,
              inputMargin: EdgeInsets.zero,
              inputTextCursorColor: AppColors.primaryDark,
              inputContainerDecoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  topLeft: Radius.circular(16),
                ),
              ),
              bubbleMargin: EdgeInsets.only(bottom: 16, left: 16, right: 0),
              backgroundColor: AppColors.background,
              sentMessageBodyTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              receivedMessageBodyTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
