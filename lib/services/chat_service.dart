import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';
import 'package:efiling_balochistan/models/chat/message_model.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';
import 'package:efiling_balochistan/services/record_audio_service.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String chatsCollection = "chats";
  static const String messagesCollection = "messages";

  final AudioRecordService audioRecorder = AudioRecordService();

  Future<String> createChatRoom({
    required int fileId,
    required String? barcode,
    required List<ParticipantModel> participants,
  }) async {
    final query = await _firestore
        .collection(chatsCollection)
        .where('file_id', isEqualTo: fileId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final chatId = query.docs.first.id;
      addParticipants(chatId: chatId, newParticipants: participants);
      return chatId;
    }

    // No chat exists → create new one
    final chatRef = await _firestore.collection(chatsCollection).add({
      'file_id': fileId,
      'file_barcode': barcode,
      'created_at': DateTime.now(),
      'participants': participants.map((p) => p.toJson()).toList(),
      'last_message': null,
    });

    return chatRef.id;
  }

  Future<ChatModel> getChat(String chatId) async {
    DocumentSnapshot ds =
        await _firestore.collection(chatsCollection).doc(chatId).get();
    return ChatModel.fromJson(ds.data() as Map<String, dynamic>, ds.id);
  }

  Future<void> addParticipants({
    required String chatId,
    required List<ParticipantModel> newParticipants,
  }) async {
    final chatDoc =
        await _firestore.collection(chatsCollection).doc(chatId).get();

    if (!chatDoc.exists) {
      throw Exception("Chat not found");
    }

    final chatData = chatDoc.data()!;
    final existingParticipants =
        (chatData['participants'] as List<dynamic>? ?? [])
            .map((p) => ParticipantModel.fromJson(Map<String, dynamic>.from(p)))
            .toList();

    final updatedParticipants =
        List<ParticipantModel>.from(existingParticipants);

    for (final newP in newParticipants) {
      final index =
          existingParticipants.indexWhere((p) => p.userId == newP.userId);

      if (index == -1) {
        // 1. Not in list → add
        updatedParticipants.add(newP.copyWith(joinedAt: DateTime.now()));
      } else {
        final existingP = existingParticipants[index];
        if (existingP.removed) {
          // 2. Already exists but removed → restore
          updatedParticipants[index] = ParticipantModel(
            userDesignationId: existingP.userDesignationId,
            userId: existingP.userId,
            userTitle: existingP.userTitle,
            designation: existingP.designation,
            joinedAt: existingP.joinedAt ?? DateTime.now(),
            removed: false,
            removedAt: null,
          );
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
    }
  }

  bool _listEquals(List<ParticipantModel> a, List<ParticipantModel> b) {
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
        .map((p) => ParticipantModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();

    // Update the participant if found
    final updatedParticipants = participants.map((p) {
      if (p.userId == userId) {
        return ParticipantModel(
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
  }

  bool isParticipantInChat({
    required ChatModel chat,
    required int userId,
  }) {
    return chat.participants.any((p) => p.userId == userId && !p.removed);
  }

  ParticipantModel? currentParticipant({
    required ChatModel chat,
    required int userId,
  }) {
    ParticipantModel p = chat.participants.firstWhere((e) => e.userId == userId,
        orElse: () => ParticipantModel());
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
    return _firestore.collection(chatsCollection).snapshots().map((snapshot) {
      final chats = snapshot.docs
          .map((doc) => ChatModel.fromJson(doc.data(), doc.id))
          .toList();

      // Filter by participants (regardless of removed status)
      return chats.where((chat) {
        return chat.participants.any(
          (p) => p.userId == userId && p.userDesignationId == userDesignationId,
        );
      }).toList()
        ..sort((a, b) {
          final aTime =
              a.lastMessage?.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime =
              b.lastMessage?.sentAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime); // newest first
        });
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
    final File? audioFile = await audioRecorder.stop();
    if (audioFile == null) return;

    // Upload to Firebase Storage
    final fileName = "voice_${DateTime.now().millisecondsSinceEpoch}.m4a";

    //TODO: Replace with the url from the api
    // final ref = _storage.ref().child("chat_audio").child(chatId).child(fileName);
    //
    // await ref.putFile(audioFile);
    // final url = await ref.getDownloadURL();
    final url = '';

    // Build a MessageModel
    final msg = MessageModel(
      id: const Uuid().v4(),
      text: "", // voice message doesn't carry text
      userId: userId,
      userName: userTitle,
      userDesignationId: userDesignationId,
      sentAt: DateTime.now(),
      attachments: [url],
    );

    await _firestore
        .collection(chatsCollection)
        .doc(chat.id)
        .collection(messagesCollection)
        .add(msg.toJson(chat));

    await _firestore.collection(chatsCollection).doc(chat.id).update({
      'last_message': msg.toJson(chat),
    });
  }

  Future<void> cancelVoiceRecording() async {
    await audioRecorder.cancel();
  }

  Future<void> disposeRecorder() async {
    await audioRecorder.dispose();
  }
}
