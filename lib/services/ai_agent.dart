import 'dart:async';
import 'dart:developer';

import 'package:efiling_balochistan/constants/keys.dart';
import 'package:openai_dart/openai_dart.dart';

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  ChatMessage({required this.role, required this.content});
}

class AIAgent {
  final client = OpenAIClient(apiKey: Keys.openAIKey);
  static const aiModel = 'gpt-4o-mini';

  final List<ChatMessage> _messageHistory = [];
  final _messageController = StreamController<List<ChatMessage>>.broadcast();

  //static const String _fileTemplate = """... your file template here ...""";

  static String reportContext(String fileStr) =>
      'You are a helpful assistant that helps user to answer questions about the file.'
      'See the file text in three backticks, you Only answer questions regarding that file ```$fileStr```'
      'If user tries to ask any other question, reply with "Sorry, I can only answer questions related to the provided file."';

  /// Expose message history as a stream
  Stream<List<ChatMessage>> get messagesStream => _messageController.stream;

  /// Internal: notify listeners of updated messages
  void _notifyListeners() {
    _messageController.add(List.unmodifiable(_messageHistory));
  }

  /// Add a message to history
  void _addMessage(String role, String content) {
    _messageHistory.add(ChatMessage(role: role, content: content));
    _notifyListeners();
  }

  /// Send a user message and get AI's full response (non-streaming)
  Future<void> sendMessage(String userMessage, String fileStr) async {
    _addMessage('user', userMessage);

    final res = await client.createChatCompletion(
      request: CreateChatCompletionRequest(
        model: const ChatCompletionModel.modelId(aiModel),
        messages: [
          ChatCompletionMessage.system(content: reportContext(fileStr)),
          for (final m in _messageHistory)
            m.role == 'user'
                ? ChatCompletionMessage.user(
                    content: ChatCompletionUserMessageContent.string(m.content),
                  )
                : ChatCompletionMessage.assistant(content: m.content),
        ],
        temperature: 0,
      ),
    );

    final aiResponse = res.choices.first.message.content ?? '';
    log(aiResponse);
    _addMessage('assistant', aiResponse);
  }

  /// Send a user message and get AI's response as a stream (for typing effect)
  Stream<String> sendMessageStream(String userMessage, String? fileStr) async* {
    _addMessage('user', userMessage);

    if (fileStr == null || fileStr.isEmpty) {
      yield "No report found for this file. Please upload a report first.";
    }

    final stream = client.createChatCompletionStream(
      request: CreateChatCompletionRequest(
        model: const ChatCompletionModel.modelId(aiModel),
        messages: [
          ChatCompletionMessage.system(content: reportContext(fileStr!)),
          for (final m in _messageHistory)
            m.role == 'user'
                ? ChatCompletionMessage.user(
                    content: ChatCompletionUserMessageContent.string(m.content),
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
    _addMessage('assistant', fullResponse);
  }

  /// Dispose the stream controller
  void dispose() {
    _messageController.close();
  }
}
