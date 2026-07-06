import 'dart:async';
import 'dart:developer';

import 'package:efiling_balochistan/constants/keys.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/models/assistants/assistants.dart';
import 'package:openai_dart/src/models/runs/runs.dart';
import 'package:openai_dart/src/models/threads/threads.dart';
import 'package:openai_dart/src/models/vector_stores/vector_stores.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PdfChatRole { user, assistant }

class PdfAIMessage {
  final PdfChatRole role;
  final String content;
  final bool isError;

  PdfAIMessage({
    required this.role,
    required this.content,
    this.isError = false,
  });
}

/// Handles PDF-based Q&A using OpenAI Assistants API with File Search (RAG).
///
/// Supports multiple PDFs — each identified by your backend [fileId].
/// The assistant + vector store for each PDF are created once and persisted
/// in SharedPreferences, shared by all users of the same API key.
/// Each user session gets its own thread (conversation stays separate).
///
/// Lifecycle:
/// 1. Call [setupPDF] with your backend fileId + PDF bytes on session start.
///    Skips upload if this PDF was already indexed previously.
/// 2. Call [sendMessage] for each user query — streams back the response.
/// 3. Call [resetSession] on logout — clears the thread, keeps the PDF indexed.
/// 4. Call [deletePDF] only if you want to permanently remove a specific PDF.
class PDFAIAgent {
  PDFAIAgent._();

  static PDFAIAgent? _instance;
  static PDFAIAgent get instance => _instance ??= PDFAIAgent._();

  final OpenAIClient _client = OpenAIClient.withApiKey(Keys.openAIKey);

  static const _model = 'gpt-4o-mini';

  // Active session state
  String? _activeAssistantId;
  String? _threadId;
  int? _activeFileId;

  bool _isReady = false;
  bool get isReady => _isReady;

  final List<PdfAIMessage> _messageHistory = [];
  List<PdfAIMessage> get messageHistory => List.unmodifiable(_messageHistory);

  final _messageController = StreamController<List<PdfAIMessage>>.broadcast();
  Stream<List<PdfAIMessage>> get messagesStream => _messageController.stream;

  // SharedPreferences key helpers — scoped per backend fileId
  static String _keyAssistantId(int fileId) => 'pdf_agent_${fileId}_assistant_id';
  static String _keyVectorStoreId(int fileId) => 'pdf_agent_${fileId}_vector_store_id';
  static String _keyOpenAiFileId(int fileId) => 'pdf_agent_${fileId}_openai_file_id';

  void _notify() => _messageController.add(List.unmodifiable(_messageHistory));

  void _addMessage(PdfChatRole role, String content, {bool error = false}) {
    _messageHistory.add(PdfAIMessage(role: role, content: content, isError: error));
    _notify();
  }

  void _updateLast(String content) {
    if (_messageHistory.isNotEmpty) {
      _messageHistory.last = PdfAIMessage(
        role: _messageHistory.last.role,
        content: content,
        isError: _messageHistory.last.isError,
      );
      _notify();
    }
  }

  /// Sets up the assistant for a specific PDF identified by [fileId].
  ///
  /// - If this PDF was indexed before, reuses the existing assistant (no upload).
  /// - If this is a different PDF than the active one, switches context.
  /// - Always creates a fresh thread for the current user session.
  Future<bool> setupPDF({
    required int fileId,
    required List<int> pdfBytes,
    required String filename,
  }) async {
    try {
      // Already active for this same PDF in this session — just ensure thread exists
      if (_isReady && _activeFileId == fileId && _threadId != null) {
        return true;
      }

      // Switching to a different PDF — clear session state but keep persisted IDs
      if (_activeFileId != fileId) {
        _threadId = null;
        _isReady = false;
        _messageHistory.clear();
        _notify();
      }

      final prefs = await SharedPreferences.getInstance();
      final savedAssistantId = prefs.getString(_keyAssistantId(fileId));

      if (savedAssistantId != null) {
        // Reuse existing assistant for this PDF
        _activeAssistantId = savedAssistantId;
        log('PDFAIAgent: reusing assistant $savedAssistantId for fileId $fileId');
      } else {
        // First time for this PDF — upload and create everything
        log('PDFAIAgent: creating new assistant for fileId $fileId');

        final file = await _client.files.upload(
          bytes: pdfBytes,
          filename: filename,
          purpose: FilePurpose.assistants,
        );
        log('PDF uploaded: ${file.id}');

        final vs = await _client.beta.vectorStores.create(
          CreateVectorStoreRequest(name: '$filename-$fileId'),
        );
        log('Vector store created: ${vs.id}');

        await _client.beta.vectorStores.files.create(
          vs.id,
          CreateVectorStoreFileRequest(fileId: file.id),
        );

        await _pollUntilIndexed(vs.id, file.id);
        log('File indexed in vector store');

        final assistant = await _client.beta.assistants.create(
          CreateAssistantRequest(
            model: _model,
            instructions:
                'You are a helpful assistant. Answer questions based strictly on the uploaded PDF document. '
                'If the answer is not found in the document, say so clearly. '
                'Give your reply only in WYSIWYG HTML format, do not use markdown or any other format.',
            tools: [AssistantTool.fileSearch()],
            toolResources: ToolResources(
              fileSearch: FileSearchResources(vectorStoreIds: [vs.id]),
            ),
          ),
        );
        _activeAssistantId = assistant.id;
        log('Assistant created: ${assistant.id}');

        // Persist IDs so future calls for this fileId skip the upload
        await prefs.setString(_keyAssistantId(fileId), assistant.id);
        await prefs.setString(_keyVectorStoreId(fileId), vs.id);
        await prefs.setString(_keyOpenAiFileId(fileId), file.id);
      }

      // Always create a fresh thread per user session
      final thread = await _client.beta.threads.create();
      _threadId = thread.id;
      _activeFileId = fileId;
      _isReady = true;
      log('Thread created: ${thread.id}');

      return true;
    } catch (e, s) {
      log('PDFAIAgent setup error: $e\n$s');
      return false;
    }
  }

  /// Sends a user message and streams back the assistant response.
  Stream<String> sendMessage(String userMessage) async* {
    if (!_isReady || _activeAssistantId == null || _threadId == null) {
      yield 'PDF not ready. Please call setupPDF first.';
      return;
    }

    _addMessage(PdfChatRole.user, userMessage);
    _addMessage(PdfChatRole.assistant, 'Reading document...');
    yield 'Reading document...';

    try {
      await _client.beta.threads.messages.create(
        _threadId!,
        CreateMessageRequest.user(userMessage),
      );

      final stream = _client.beta.threads.runs.createStream(
        _threadId!,
        CreateRunRequest(assistantId: _activeAssistantId!),
      );

      final buffer = StringBuffer();

      await for (final event in stream) {
        final eventType = event['event'] as String?;
        if (eventType == 'thread.message.delta') {
          final data = event['data'] as Map<String, dynamic>?;
          final delta = data?['delta'] as Map<String, dynamic>?;
          final contentList = delta?['content'] as List<dynamic>?;
          for (final part in contentList ?? []) {
            final text = (part as Map<String, dynamic>?)?['text'] as Map<String, dynamic>?;
            final value = text?['value'] as String?;
            if (value != null && value.isNotEmpty) {
              buffer.write(value);
              _updateLast(buffer.toString());
              yield buffer.toString();
            }
          }
        }
      }

      if (buffer.isEmpty) {
        _updateLast('Unable to generate a response right now');
        yield 'Unable to generate a response right now';
      }
    } catch (e, s) {
      log('PDFAIAgent sendMessage error: $e\n$s');
      _updateLast('Unable to generate a response right now');
      yield 'Unable to generate a response right now';
    }
  }

  /// Call on user logout — clears the active session.
  /// All PDF assistants remain on OpenAI and are reused on next login.
  void resetSession() {
    _threadId = null;
    _activeAssistantId = null;
    _activeFileId = null;
    _isReady = false;
    _messageHistory.clear();
    _notify();
  }

  /// Permanently deletes the assistant, vector store, and file for a specific PDF.
  /// Also removes its persisted IDs from SharedPreferences.
  /// Use only if you want to stop using a PDF and free up OpenAI storage.
  Future<void> deletePDF(int fileId) async {
    if (_activeFileId == fileId) resetSession();

    try {
      final prefs = await SharedPreferences.getInstance();

      final assistantId = prefs.getString(_keyAssistantId(fileId));
      final vectorStoreId = prefs.getString(_keyVectorStoreId(fileId));
      final openAiFileId = prefs.getString(_keyOpenAiFileId(fileId));

      if (assistantId != null) {
        await _client.beta.assistants.delete(assistantId);
        log('Assistant deleted: $assistantId');
      }
      if (vectorStoreId != null && openAiFileId != null) {
        await _client.beta.vectorStores.files.delete(vectorStoreId, openAiFileId);
      }
      if (vectorStoreId != null) {
        await _client.beta.vectorStores.delete(vectorStoreId);
        log('Vector store deleted: $vectorStoreId');
      }
      if (openAiFileId != null) {
        await _client.files.delete(openAiFileId);
        log('File deleted: $openAiFileId');
      }

      await prefs.remove(_keyAssistantId(fileId));
      await prefs.remove(_keyVectorStoreId(fileId));
      await prefs.remove(_keyOpenAiFileId(fileId));
    } catch (e, s) {
      log('PDFAIAgent deletePDF error: $e\n$s');
    }
  }

  void resetMessages() {
    _messageHistory.clear();
    _notify();
  }

  void dispose() {
    _messageController.close();
  }

  Future<void> _pollUntilIndexed(String vectorStoreId, String fileId) async {
    const maxAttempts = 30;
    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 2));
      final vsFile = await _client.beta.vectorStores.files.retrieve(vectorStoreId, fileId);
      if (vsFile.isReady) return;
      if (vsFile.isFailed) throw Exception('Vector store file indexing failed');
    }
    throw Exception('Timed out waiting for PDF to be indexed');
  }
}
