import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:efiling_balochistan/models/chat/chat_file_model.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/chat/message_model.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/repository/chat/chat_repo.dart';
import 'package:efiling_balochistan/services/record_audio_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String chatsCollection = "chats";
  static const String messagesCollection = "messages";
  final ChatRepo chatRepo = ChatRepo();

  final AudioRecordService audioRecorder = AudioRecordService();

  Future<String> createChatRoom({
    required int? fileId,
    required String? subject,
    required List<ChatParticipantModel> participants,
  }) async {
    String? chatId;

    if (fileId != null) {
      chatId = await getChatFromFile(fileId);
    }

    if (chatId != null) {
      //addParticipants(chatId: chatId, newParticipants: participants);
      return chatId;
    }

    // No chat exists → create new one
    final chatRef = await _firestore.collection(chatsCollection).add({
      'file_id': fileId,
      'file_barcode': subject,
      'created_at': DateTime.now(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'last_message': null,
    });

    // Add participants to subcollection
    final batch = _firestore.batch();
    for (final participant in participants) {
      final participantRef = chatRef
          .collection('participants')
          .doc(participant.userDesignationId.toString());
      final participantData = participant.toJson();
      participantData['user_designation_id'] = participant.userDesignationId;
      batch.set(participantRef, participantData);
    }
    await batch.commit();

    return chatRef.id;
  }

  Future<String?> getChatFromFile(int? fileId) async {
    final query = await _firestore
        .collection(chatsCollection)
        .where('file_id', isEqualTo: fileId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    return null;
  }

  Future<ChatModel?> getChat(String chatId) async {
    DocumentSnapshot ds =
        await _firestore.collection(chatsCollection).doc(chatId).get();
    if (!ds.exists) {
      return null;
    }
    return ChatModel.fromJson(ds.data() as Map<String, dynamic>, ds.id);
  }

  Future<void> addParticipants({
    required String chatId,
    required List<ChatParticipantModel> newParticipants,
  }) async {
    final chatDoc =
        await _firestore.collection(chatsCollection).doc(chatId).get();

    if (!chatDoc.exists) {
      throw Exception("Chat not found");
    }

    final chatData = chatDoc.data()!;
    final existingParticipants = (chatData['participants'] as List<dynamic>? ??
            [])
        .map((p) => ChatParticipantModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    final updatedParticipants =
        List<ChatParticipantModel>.from(existingParticipants);

    List<String> addedParticipantNames = [];
    List<String> restoredParticipantNames = [];

    for (final newP in newParticipants) {
      final index =
          existingParticipants.indexWhere((p) => p.userId == newP.userId);

      if (index == -1) {
        // 1. Not in list → add
        updatedParticipants.add(newP.copyWith(joinedAt: DateTime.now()));
        addedParticipantNames.add(newP.userTitle ?? 'Unknown User');
      } else {
        final existingP = existingParticipants[index];
        if (existingP.removed) {
          // 2. Already exists but removed → restore
          updatedParticipants[index] = ChatParticipantModel(
            userDesignationId: existingP.userDesignationId,
            userId: existingP.userId,
            userTitle: existingP.userTitle,
            designation: existingP.designation,
            joinedAt: existingP.joinedAt ?? DateTime.now(),
            removed: false,
            removedAt: null,
          );
          restoredParticipantNames.add(existingP.userTitle ?? 'Unknown User');
        }
        // 3. Already exists & active → do nothing
      }
    }

    // Only update if something changed
    if (updatedParticipants.length != existingParticipants.length ||
        !_listEquals(existingParticipants, updatedParticipants)) {
      await _firestore.collection(chatsCollection).doc(chatId).update({
        'participants': updatedParticipants.map((p) => p.toJson()).toList(),
      });

      // Update participants subcollection for added/restored participants
      final batch = _firestore.batch();

      for (final newP in newParticipants) {
        final participantRef = _firestore
            .collection(chatsCollection)
            .doc(chatId)
            .collection('participants')
            .doc(newP.userDesignationId.toString());

        final updatedParticipant = updatedParticipants.firstWhere(
          (p) => p.userDesignationId == newP.userDesignationId,
          orElse: () => newP,
        );

        final participantData = updatedParticipant.toJson();
        participantData['user_designation_id'] =
            updatedParticipant.userDesignationId;
        batch.set(participantRef, participantData);
      }

      await batch.commit();

      // Create system messages for added participants
      final chat = ChatModel.fromJson(chatData, chatId);

      for (final name in addedParticipantNames) {
        final systemMessage = MessageModel(
          id: const Uuid().v4(),
          text: "$name was added to the chat",
          userId: null,
          userDesignationId: 0,
          userName: name,
          sentAt: DateTime.now(),
          messageType: MessageType.info,
        );

        await _firestore
            .collection(chatsCollection)
            .doc(chatId)
            .collection(messagesCollection)
            .add(systemMessage.toJson(chat));
      }

      for (final name in restoredParticipantNames) {
        final systemMessage = MessageModel(
          id: const Uuid().v4(),
          text: "$name rejoined the chat",
          userId: null,
          userDesignationId: 0,
          userName: name,
          sentAt: DateTime.now(),
          messageType: MessageType.info,
        );

        await _firestore
            .collection(chatsCollection)
            .doc(chatId)
            .collection(messagesCollection)
            .add(systemMessage.toJson(chat));
      }
    }
  }

  bool _listEquals(List<ChatParticipantModel> a, List<ChatParticipantModel> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].toJson().toString() != b[i].toJson().toString()) {
        return false;
      }
    }
    return true;
  }

  Future<void> removeParticipant({
    required String chatId,
    required int userId,
  }) async {
    final chatDoc =
        await _firestore.collection(chatsCollection).doc(chatId).get();

    if (!chatDoc.exists) {
      throw Exception("Chat not found");
    }

    final chatData = chatDoc.data()!;
    final participants = (chatData['participants'] as List<dynamic>? ?? [])
        .map((p) => ChatParticipantModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    String? removedUserName;
    int? removedUserDesignationId;

    // Update the participant if found
    final updatedParticipants = participants.map((p) {
      if (p.userId == userId && !p.removed) {
        removedUserName = p.userTitle;
        removedUserDesignationId = p.userDesignationId;
        return ChatParticipantModel(
          userDesignationId: p.userDesignationId,
          userId: p.userId,
          userTitle: p.userTitle,
          designation: p.designation,
          joinedAt: p.joinedAt,
          removed: true,
          removedAt: DateTime.now(),
        );
      }
      return p;
    }).toList();

    // Save back to Firestore
    await _firestore.collection(chatsCollection).doc(chatId).update({
      'participants': updatedParticipants.map((p) => p.toJson()).toList(),
    });

    // Update participants subcollection if a participant was removed
    if (removedUserDesignationId != null) {
      final removedParticipant = updatedParticipants.firstWhere(
        (p) => p.userDesignationId == removedUserDesignationId,
      );

      final participantData = removedParticipant.toJson();
      participantData['user_designation_id'] =
          removedParticipant.userDesignationId;
      await _firestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection('participants')
          .doc(removedUserDesignationId.toString())
          .set(participantData);
    }

    // Create system message if a participant was actually removed
    if (removedUserName != null) {
      final chat = ChatModel.fromJson(chatData, chatId);

      final systemMessage = MessageModel(
        id: const Uuid().v4(),
        text: "$removedUserName left the chat",
        userId: null,
        userDesignationId: 0,
        userName: "System",
        sentAt: DateTime.now(),
        messageType: MessageType.info,
      );

      await _firestore
          .collection(chatsCollection)
          .doc(chatId)
          .collection(messagesCollection)
          .add(systemMessage.toJson(chat));
    }
  }

  bool isParticipantInChat({
    required ChatModel chat,
    required int userId,
  }) {
    return chat.participants.any((p) => p.userId == userId && !p.removed);
  }

  ChatParticipantModel? currentParticipant({
    required ChatModel chat,
    required int userId,
  }) {
    ChatParticipantModel p = chat.participants.firstWhere(
        (e) => e.userId == userId,
        orElse: () => ChatParticipantModel());
    if (p.userId == null) return null;
    return p;
  }

  Future<void> sendMessage({
    required ChatModel chat,
    required MessageModel message,
  }) async {
    final chatRef = _firestore.collection(chatsCollection).doc(chat.id);

    // Ensure sender is always marked as seen
    final updatedMessage = message.copyWith(
      seenBy: {...message.seenBy, message.userDesignationId}
          .toList(), // avoid duplicates
    );

    // Add to messages subcollection
    await chatRef
        .collection(messagesCollection)
        .add(updatedMessage.toJson(chat));

    // Update last_message in chat doc
    await chatRef.update({
      'last_message': updatedMessage.toJson(chat),
    });
  }

  Stream<ChatModel> readChatStream(String chatId) {
    return _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) {
        throw Exception("Chat not found");
      }
      return ChatModel.fromJson(data, doc.id);
    });
  }

  Stream<List<ChatModel>> getUserChatsStream({
    required int userId,
    required int userDesignationId,
  }) {
    return _firestore
        .collectionGroup('participants')
        .where('user_designation_id', isEqualTo: userDesignationId)
        .snapshots()
        .asyncExpand((participantSnapshot) {
      // Get unique chat IDs from participant documents
      final chatIds = participantSnapshot.docs
          .map((doc) => doc.reference.parent.parent!.id)
          .toSet()
          .toList();

      if (chatIds.isEmpty) return Stream.value(<ChatModel>[]);

      // Create streams for each chat document to listen to real-time changes
      final chatStreams = chatIds
          .map((chatId) => _firestore
                  .collection(chatsCollection)
                  .doc(chatId)
                  .snapshots()
                  .map((doc) {
                if (!doc.exists) return null;
                final chat = ChatModel.fromJson(doc.data()!, doc.id);
                // Filter by userId to ensure both userId and userDesignationId match
                if (chat.participants.any((p) =>
                    p.userId == userId &&
                    p.userDesignationId == userDesignationId)) {
                  return chat;
                }
                return null;
              }))
          .toList();

      // Combine all chat streams and filter out nulls
      return _combineLatestList(chatStreams).map((chats) {
        final validChats =
            chats.where((chat) => chat != null).cast<ChatModel>().toList();

        // Sort by last message time
        validChats.sort((a, b) {
          final aTime =
              a.lastMessage?.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime =
              b.lastMessage?.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime); // newest first
        });

        return validChats;
      });
    });
  }

  // Helper method to combine multiple streams
  Stream<List<T>> _combineLatestList<T>(List<Stream<T>> streams) {
    if (streams.isEmpty) return Stream.value(<T>[]);

    return Stream.multi((controller) {
      final values = List<T?>.filled(streams.length, null);
      final subscriptions = <StreamSubscription>[];
      var completedCount = 0;

      void checkAndEmit() {
        if (completedCount == streams.length) {
          controller.add(values.cast<T>());
        }
      }

      for (int i = 0; i < streams.length; i++) {
        subscriptions.add(streams[i].listen(
          (value) {
            bool wasNull = values[i] == null;
            values[i] = value;
            if (wasNull) completedCount++;
            checkAndEmit();
          },
          onError: controller.addError,
          onDone: () {
            if (values[i] == null) completedCount++;
            checkAndEmit();
          },
        ));
      }

      controller.onCancel = () {
        for (final sub in subscriptions) {
          sub.cancel();
        }
      };
    });
  }

  Stream<int> getUnreadChatsCountStream({
    required int? userDesignationId,
    required int userId,
  }) {
    if (userDesignationId == null) {
      return Stream.value(0);
    }
    return _firestore
        .collectionGroup('participants')
        .where('user_designation_id', isEqualTo: userDesignationId)
        .snapshots()
        .asyncMap((participantSnapshot) async {
      // Get unique chat IDs from participant documents
      final chatIds = participantSnapshot.docs
          .map((doc) => doc.reference.parent.parent!.id)
          .toSet()
          .toList();

      if (chatIds.isEmpty) return 0;

      int unreadCount = 0;
      for (final chatId in chatIds) {
        final chatDoc =
            await _firestore.collection(chatsCollection).doc(chatId).get();
        if (chatDoc.exists) {
          final data = chatDoc.data()!;

          // Check if user is a participant and not removed
          final participants = (data['participants'] as List<dynamic>? ?? [])
              .map((p) =>
                  ChatParticipantModel.fromJson(Map<String, dynamic>.from(p)))
              .toList();
          final isParticipant = participants.any(
            (p) =>
                p.userId == userId && p.userDesignationId == userDesignationId,
          );

          if (!isParticipant) continue;

          // Check if unread
          final lastMessage = data['last_message'];
          if (lastMessage != null) {
            final seenBy = List<int>.from(lastMessage['seen_by'] ?? []);
            if (!seenBy.contains(userDesignationId)) {
              unreadCount++;
            }
          }
        }
      }
      return unreadCount;
    });
  }

  Stream<int> getAllChatsCountStream({
    required int userId,
    required int userDesignationId,
  }) {
    return _firestore
        .collectionGroup('participants')
        .where('user_designation_id', isEqualTo: userDesignationId)
        .snapshots()
        .asyncMap((participantSnapshot) async {
      // Get unique chat IDs from participant documents
      final chatIds = participantSnapshot.docs
          .map((doc) => doc.reference.parent.parent!.id)
          .toSet()
          .toList();

      if (chatIds.isEmpty) return 0;

      int chatCount = 0;
      for (final chatId in chatIds) {
        final chatDoc =
            await _firestore.collection(chatsCollection).doc(chatId).get();
        if (chatDoc.exists) {
          final data = chatDoc.data()!;
          final participants = (data['participants'] as List<dynamic>? ?? [])
              .map((p) =>
                  ChatParticipantModel.fromJson(Map<String, dynamic>.from(p)))
              .toList();
          final isParticipant = participants.any((p) =>
              p.userId == userId && p.userDesignationId == userDesignationId);
          if (isParticipant) {
            chatCount++;
          }
        }
      }
      return chatCount;
    });
  }

  Stream<List<MessageModel>> readMessagesStream(String chatId) {
    return _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .orderBy('sent_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Stream<List<MessageModel>> readRecentMessagesStream(
    String chatId, {
    int limit = 20,
  }) {
    return _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .orderBy('sent_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
            .toList());
  }

  Future<List<MessageModel>> loadMoreMessages({
    required String chatId,
    required DocumentSnapshot lastDoc,
    int limit = 20,
  }) async {
    final snapshot = await _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .orderBy('sent_at', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => MessageModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> markAllMessagesAsRead({
    required String chatId,
    required int userDesignationId,
  }) async {
    try {
      final chatRef = _firestore.collection(chatsCollection).doc(chatId);

      // Get chat document (to check last_message)
      final chatDoc = await chatRef.get();
      final chatData = chatDoc.data();

      // Update last_message.seen_by if needed
      if (chatData != null && chatData['last_message'] != null) {
        final lastMessage = Map<String, dynamic>.from(chatData['last_message']);
        final seenBy = List<int>.from(lastMessage['seen_by'] ?? []);

        if (!seenBy.contains(userDesignationId)) {
          seenBy.add(userDesignationId);
          lastMessage['seen_by'] = seenBy;

          await chatRef.update({'last_message': lastMessage});
        }
      }

      // Update all messages in subcollection
      final messagesRef = chatRef.collection(messagesCollection);
      final snapshot = await messagesRef.get();

      final batch = _firestore.batch();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final seenBy = List<int>.from(data['seen_by'] ?? []);

        if (!seenBy.contains(userDesignationId)) {
          seenBy.add(userDesignationId);
          batch.update(doc.reference, {'seen_by': seenBy});
        }
      }

      await batch.commit();
    } catch (e, s) {
      print("ERRRR______${e}______$s");
    }
  }

  Stream<ChatModel> getChatRoomStream(String chatId) {
    return _firestore
        .collection(chatsCollection)
        .doc(chatId)
        .snapshots()
        .map((doc) => ChatModel.fromJson(doc.data()!, doc.id));
  }

  Future<void> startVoiceRecording() async {
    await audioRecorder.startRecordingToFile();
  }

  Future<void> stopAndSendVoiceMessage({
    required ChatModel chat,
    required int userId,
    required int userDesignationId,
    required String userTitle,
  }) async {
    try {
      final File? audioFile = await audioRecorder.stop();
      if (audioFile == null) return;

      final messageId = const Uuid().v4();
      final fileName = "voice_${DateTime.now().millisecondsSinceEpoch}.m4a";

      // First, create a "sending" message with placeholder
      final sendingMsg = MessageModel(
        id: messageId,
        text: "🎙️ Voice message",
        userId: userId,
        userName: userTitle,
        userDesignationId: userDesignationId,
        sentAt: DateTime.now(),
        attachments: [], // Empty during upload to avoid player errors
        seenBy: [userDesignationId],
      );

      // Add the "sending" message to Firestore immediately
      final docRef = _firestore
          .collection(chatsCollection)
          .doc(chat.id)
          .collection(messagesCollection)
          .doc(messageId);

      await docRef.set({
        ...sendingMsg.toJson(chat),
        'upload_status': 'sending',
        'local_files': [audioFile.path],
        'message_type': 'voice', // Add type indicator
      });

      // Update last_message with sending status
      await _firestore.collection(chatsCollection).doc(chat.id).update({
        'last_message': {
          ...sendingMsg.toJson(chat),
          'upload_status': 'sending',
          'message_type': 'voice', // Add type indicator
        },
      });

      log("Voice message created with sending status, starting upload...");

      // Now upload file in the background
      ChatFileModel model = await chatRepo.saveChatFile(
          filePath: audioFile.path, fileName: fileName);

      log("Upload completed. FileUrl: ${model.fileUrl}");

      if (model.fileUrl != null) {
        // Update the message with uploaded URL
        final completedMsg = sendingMsg.copyWith(
          text: model.fileUrl!,
          attachments: [model.fileUrl!],
        );

        try {
          await docRef.update({
            ...completedMsg.toJson(chat),
            'upload_status': 'sent',
          });

          // Update last_message with completed status
          await _firestore.collection(chatsCollection).doc(chat.id).update({
            'last_message': {
              ...completedMsg.toJson(chat),
              'upload_status': 'sent',
            },
          });

          log("Voice message uploaded successfully: ${model.fileUrl}");
        } catch (updateError, updateStack) {
          log("Error updating voice message status: $updateError");
          log("Stack trace: $updateStack");
        }
      } else {
        // Handle upload failure
        log("Voice message upload failed - no URL returned");
        await docRef.update({
          'upload_status': 'failed',
        });
      }
    } catch (e, s) {
      log("ERRR________${e}_______$s");
      // TODO: Update message status to 'failed' on error
    }
  }

  Future<void> sendMessageWithAttachment({
    required ChatModel chat,
    required int userId,
    required int userDesignationId,
    required String userTitle,
    required List<XFile> attachments,
  }) async {
    try {
      final messageId = const Uuid().v4();

      // First, create a "sending" message with local file paths
      final sendingMsg = MessageModel(
        id: messageId,
        text: "",
        userId: userId,
        userName: userTitle,
        userDesignationId: userDesignationId,
        sentAt: DateTime.now(),
        attachments: attachments.map((e) => e.path).toList(),
        seenBy: [userDesignationId],
      );

      // Add the "sending" message to Firestore immediately
      final docRef = _firestore
          .collection(chatsCollection)
          .doc(chat.id)
          .collection(messagesCollection)
          .doc(messageId);

      await docRef.set({
        ...sendingMsg.toJson(chat),
        'upload_status': 'sending',
        'local_files': attachments.map((e) => e.path).toList(),
      });

      // Update last_message with sending status
      await _firestore.collection(chatsCollection).doc(chat.id).update({
        'last_message': {
          ...sendingMsg.toJson(chat),
          'upload_status': 'sending',
        },
      });

      // Now upload files in the background
      List<String> attachmentUrls = [];

      for (final attachment in attachments) {
        ChatFileModel model = await chatRepo.saveChatFile(
            filePath: attachment.path, fileName: attachment.name);
        if (model.fileUrl != null) {
          attachmentUrls.add(model.fileUrl!);
        }
      }

      // Update the message with uploaded URLs
      final completedMsg = sendingMsg.copyWith(
        attachments: attachmentUrls,
      );

      await docRef.update({
        ...completedMsg.toJson(chat),
        'upload_status': 'sent',
      });

      // Update last_message with completed status
      await _firestore.collection(chatsCollection).doc(chat.id).update({
        'last_message': {
          ...completedMsg.toJson(chat),
          'upload_status': 'sent',
        },
      });
    } catch (e, s) {
      log("ERRR________${e}_______$s");
      // TODO: Update message status to 'failed' on error
    }
  }

  Future<void> cancelVoiceRecording() async {
    await audioRecorder.cancel();
  }

  Future<void> disposeRecorder() async {
    await audioRecorder.dispose();
  }
}
