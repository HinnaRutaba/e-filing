import 'package:efiling_balochistan/config/router/route_helper.dart';
import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/services/ai_agent.dart';
import 'package:efiling_balochistan/views/widgets/app_text.dart';
import 'package:efiling_balochistan/views/widgets/buttons/solid_button.dart';
import 'package:efiling_balochistan/views/widgets/text_fields/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class AIAgentChatScreen extends StatefulWidget {
  final int? fileId;
  final String? file;
  const AIAgentChatScreen({super.key, this.fileId, this.file});

  @override
  _AIAgentChatScreenState createState() => _AIAgentChatScreenState();
}

class _AIAgentChatScreenState extends State<AIAgentChatScreen> {
  final TextEditingController promptController = TextEditingController();
  final types.User _currentUser = types.User(id: "user_1");
  final types.User _chatPartner = types.User(id: "assistant");

  final List<types.Message> _messages = [];
  final Uuid _uuid = Uuid();

  late final AIAgent _aiAgent;
  late final Stream<List<ChatMessage>> _aiStream;

  @override
  void initState() {
    super.initState();
    _aiAgent = AIAgent();
    _aiStream = _aiAgent.messagesStream;

    // Listen to AI Agent's message history and update chat UI
    _aiStream.listen((history) {
      _messages
        ..clear()
        ..addAll(
          history.reversed.map((msg) => types.TextMessage(
                author: msg.role == 'user' ? _currentUser : _chatPartner,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                id: _uuid.v4(),
                text: msg.content,
              )),
        );
      setState(() {});
    });
  }

  void _handleSendPressed() {
    final text = promptController.text.trim();
    if (text.isEmpty) return;

    promptController.clear();

    // Send message & get AI streaming response
    _aiAgent.sendMessageStream(text, widget.file).listen((partialResponse) {
      // Update last assistant message while typing
      if (_messages.isNotEmpty &&
          _messages.first.author.id == _chatPartner.id) {
        // Update existing last assistant message
        _messages[0] = (_messages[0] as types.TextMessage).copyWith(
          text: partialResponse,
        );
      } else {
        // Add a new assistant message with partial text
        _messages.insert(
          0,
          types.TextMessage(
            author: _chatPartner,
            createdAt: DateTime.now().millisecondsSinceEpoch,
            id: _uuid.v4(),
            text: partialResponse,
          ),
        );
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _aiAgent.dispose();
    promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText.headlineSmall(
          "AI Agent Chat",
          color: AppColors.secondaryDark,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => RouteHelper.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.secondaryDark,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? AppText.bodySmall(widget.file == null
                      ? "Ask AI to assist you"
                      : "Hi, I have info about the file ask me anything about it")
                  : ListView.builder(
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index] as types.TextMessage;
                        final isUser = message.author.id == _currentUser.id;
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? AppColors.secondary
                                  : AppColors.secondaryDark.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message.text,
                              style: TextStyle(
                                color: isUser ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            AppTextField(
              controller: promptController,
              labelText: '',
              hintText: "Enter your prompt",
              showLabel: false,
              maxLines: 4,
              onFieldSubmitted: (_) {
                _handleSendPressed();
              },
            ),
            const SizedBox(height: 16),
            AppSolidButton(
              onPressed: _handleSendPressed,
              text: "Generate Response",
              width: double.infinity,
              backgroundColor: AppColors.secondary,
              fontSize: 18,
              padding: const EdgeInsets.all(16),
            ),
          ],
        ),
      ),
    );
  }
}
