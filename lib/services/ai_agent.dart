import 'dart:async';
import 'dart:developer';

import 'package:efiling_balochistan/constants/keys.dart';
import 'package:efiling_balochistan/models/file_details_model.dart';
import 'package:openai_dart/openai_dart.dart';

enum ChatRole { user, assistant }

class ChatMessage {
  final ChatRole role;
  final String content;
  final bool isError;
  final bool toShow;

  ChatMessage({
    required this.role,
    required this.content,
    this.isError = false,
    this.toShow = true,
  });
}

class AIAgent {
  static final AIAgent _instance = AIAgent._internal();

  factory AIAgent() {
    return _instance;
  }

  AIAgent._internal();

  final client = OpenAIClient(apiKey: Keys.openAIKey);
  static const aiModel = 'gpt-4o-mini';
  static const responseKey = 'Suggested Response: ';

  final List<ChatMessage> _messageHistory = [];
  final _messageController = StreamController<List<ChatMessage>>.broadcast();

  List<ChatMessage> get messageHistory => _messageHistory;
  static const String _reportFormat = '''Subject: {{subject}}

{{program_code}}
FILE NO: {{file_number}}

SUBJECT: {{short_subject}}

{{introduction_paragraph}}

The {{system_name}} aims to {{system_purpose}}. Key features of the system include:

- {{feature_1_title}}: {{feature_1_description}}
- {{feature_2_title}}: {{feature_2_description}}
- {{feature_3_title}}: {{feature_3_description}}
- {{feature_4_title}}: {{feature_4_description}}

{{further_details_paragraph}}

{{request_paragraph}}

Submitted for approval and further directions please.

{{submitted_by_name}}
({{submitted_by_designation}})
{{submitted_date}}
{{submitted_by_department}}
{{submitted_by_code}}
{{forwarder_comment}}

''';

  static String reportContext(Map<String, dynamic> file) =>
      'You are a helpful assistant that helps user to answer questions about the file.'
      'See the file param in three backticks, you Only answer questions regarding that file ```$file```'
      'The file is formatted in a Json/Map with two two keys, details as following:'
      '1. ${FileDetailsSchema.fileContent} - this contains a List of Json/Map which contains all info about the file content, who sent it who received it at what date etc'
      '2.  ${FileDetailsSchema.attachments} - this contains List of Flags linked to the file. Each Flag has a url and a title'
      'You must be able to answer question about collective content of individual file content and flags'
      'If there is a typo in the message make sure to ignore it and answer the question correctly.'
      'Only answer questions related to the file provided above.'
      'Give your reply only in WYSIWYG HTML format, do not use markdown or any other format.';

  //'If user tries to ask any other question that you know exactly are not typos, reply with "Sorry, I can only answer questions related to the provided file."';

  static String generateReportContext =
      '''You are a helpful assistant that generates a clear, official, file for the government user.

  You must:
  - Read the user’s message carefully.
  - ALWAYS write the file content following this format: $_reportFormat.
  - Fill in the required details using the user’s message.
  - feature list can be less or more than what's defined in the template. Get them from user's message
  - Make sure to write content in paragraphs for clarity.
  - Must write output in HTML with using only HTML tags — do not wrap the response in backticks.
  - Use official, professional English''';

  Stream<List<ChatMessage>> get messagesStream => _messageController.stream;

  /// Internal: notify listeners of updated messages
  void _notifyListeners() {
    _messageController.add(List.unmodifiable(_messageHistory));
  }

  /// Add a message to history
  void _addMessage(ChatRole role, String content,
      {bool error = false, bool toShow = true}) {
    _messageHistory.add(
      ChatMessage(
        role: role,
        content: content,
        isError: error,
        toShow: toShow,
      ),
    );
    _notifyListeners();
  }

  Future<void> sendMessage(
      String userMessage, Map<String, dynamic> fileStr) async {
    try {
      _addMessage(ChatRole.user, userMessage);

      _addMessage(ChatRole.assistant, "Reading file...");

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
      _messageHistory.removeWhere((m) =>
          m.role == ChatRole.assistant && m.content == "Reading file...");
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

  Stream<String> sendMessageStream(
      String userMessage, Map<String, dynamic>? fileStr,
      {bool sendAsUserMessage = true, bool suggestResponse = false}) async* {
    _addMessage(ChatRole.user, userMessage, toShow: sendAsUserMessage);

    try {
      String systemMessage = '';
      if (fileStr == null || fileStr.isEmpty) {
        systemMessage = generateReportContext;
        //yield "No report found for this file. Please upload a report first.";
      } else if (suggestResponse) {
        try {
          systemMessage = '''${reportContext(fileStr)}
       
          if user asks about a response read the whole report, read other peoples comments in the contents and only then suggest a reasonable response
        Ensure to give just a ONE LINE response do not exceed 50 characters and should not include details like Sender name, designation etc.
        The response should be in next line after the line '$responseKey'
        Only give the response if user asks for it
        ''';
        } catch (e, s) {
          print(s);
        }
      } else {
        systemMessage = reportContext(fileStr);
      }

      _addMessage(ChatRole.assistant, "Reading file...", error: true);
      yield "Reading file...";

      final stream = client.createChatCompletionStream(
        request: CreateChatCompletionRequest(
          model: const ChatCompletionModel.modelId(aiModel),
          messages: [
            ChatCompletionMessage.system(content: systemMessage),
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
      _messageHistory.removeWhere((m) =>
          m.role == ChatRole.assistant && m.content == "Reading file...");
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

  void resetMessages() {
    _messageHistory.clear();
  }
}
