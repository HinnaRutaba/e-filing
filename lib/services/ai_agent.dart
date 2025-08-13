import 'dart:async';
import 'dart:developer';

import 'package:efiling_balochistan/constants/keys.dart';
import 'package:openai_dart/openai_dart.dart';

enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String content;
  final bool isError;

  ChatMessage({
    required this.role,
    required this.content,
    this.isError = false,
  });
}

class AIAgent {
  final client = OpenAIClient(apiKey: Keys.openAIKey);
  static const aiModel = 'gpt-4o-mini';

  final List<ChatMessage> _messageHistory = [];
  final _messageController = StreamController<List<ChatMessage>>.broadcast();

  static String reportContext(String fileStr) =>
      'You are a helpful assistant that helps user to answer questions about the file.'
      'See the file text in three backticks, you Only answer questions regarding that file ```$fileStr```'
      'If user tries to ask any other question, reply with "Sorry, I can only answer questions related to the provided file."';

  Stream<List<ChatMessage>> get messagesStream => _messageController.stream;

  /// Internal: notify listeners of updated messages
  void _notifyListeners() {
    _messageController.add(List.unmodifiable(_messageHistory));
  }

  /// Add a message to history
  void _addMessage(ChatRole role, String content, {bool error = false}) {
    _messageHistory.add(
      ChatMessage(
        role: role,
        content: content,
        isError: error,
      ),
    );
    _notifyListeners();
  }

  Future<void> sendMessage(String userMessage, String fileStr) async {
    try {
      _addMessage(ChatRole.user, userMessage);

      _addMessage(ChatRole.assistant, "Thinking...");

      final res = await client.createChatCompletion(
        request: CreateChatCompletionRequest(
          model: const ChatCompletionModel.modelId(aiModel),
          messages: [
            ChatCompletionMessage.system(content: reportContext(fileStr)),
            for (final m in _messageHistory)
              m.role == ChatRole.user
                  ? ChatCompletionMessage.user(
                      content:
                          ChatCompletionUserMessageContent.string(m.content),
                    )
                  : ChatCompletionMessage.assistant(content: m.content),
          ],
          temperature: 0,
        ),
      );

      final aiResponse = res.choices.first.message.content ?? '';
      log(aiResponse);
      _messageHistory.removeWhere(
          (m) => m.role == ChatRole.assistant && m.content == "Thinking...");
      if (aiResponse.isEmpty) {
        _addMessage(
          ChatRole.assistant,
          "Unable to generate a response right now",
          error: true,
        );
        return;
      }
      _addMessage(ChatRole.assistant, aiResponse);
    } catch (e, s) {
      log("AI AGENT ERROR____${e}_____$s");
      _messageHistory.removeWhere(
          (m) => m.role == ChatRole.assistant && m.content == "Thinking...");
      _addMessage(
        ChatRole.assistant,
        "Unable to generate a response right now",
        error: true,
      );
    }
  }

  Stream<String> sendMessageStream(String userMessage, String? fileStr) async* {
    _addMessage(ChatRole.user, userMessage);

    try {
      if (fileStr == null || fileStr.isEmpty) {
        yield "No report found for this file. Please upload a report first.";
      }

      _addMessage(ChatRole.assistant, "Thinking...", error: true);
      yield "Thinking...";

      final stream = client.createChatCompletionStream(
        request: CreateChatCompletionRequest(
          model: const ChatCompletionModel.modelId(aiModel),
          messages: [
            ChatCompletionMessage.system(content: reportContext(fileStr!)),
            for (final m in _messageHistory)
              m.role == ChatRole.user
                  ? ChatCompletionMessage.user(
                      content:
                          ChatCompletionUserMessageContent.string(m.content),
                    )
                  : ChatCompletionMessage.assistant(content: m.content),
          ],
        ),
      );

      final buffer = StringBuffer();
      await for (final res in stream) {
        final chunk = res.choices.first.delta.content ?? '';
        if (chunk.isNotEmpty) {
          buffer.write(chunk);
          yield buffer.toString(); // Emit partial content
        }
      }

      final fullResponse = buffer.toString();
      _messageHistory.removeWhere(
          (m) => m.role == ChatRole.assistant && m.content == "Thinking...");
      _addMessage(ChatRole.assistant, fullResponse);
    } catch (e, s) {
      log("AI AGENT STREAM ERROR____${e}_____$s");
      _messageHistory.removeWhere(
          (m) => m.role == ChatRole.assistant && m.content == "Thinking...");
      _addMessage(ChatRole.assistant, "Unable to generate a response right now",
          error: true);
      yield "Unable to generate a response right now";
    }
  }

  /// Dispose the stream controller
  void dispose() {
    _messageController.close();
  }
}
