import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:efiling_balochistan/models/chat/participant_model.dart';

import 'message_model.dart';

enum ChatType { direct, group }

class ChatModel {
  final String id;
  final int? fileId;
  final String? fileBarCode;
  final DateTime createdAt;
  final List<ChatParticipantModel> participants;
  final MessageModel? lastMessage;
  final ChatType? type;

  ChatModel({
    required this.id,
    this.fileId,
    required this.createdAt,
    required this.participants,
    required this.fileBarCode,
    this.lastMessage,
    this.type,
  });

  List<ChatParticipantModel> get activeParticipants =>
      participants.where((e) => e.removed != true).toList();

  factory ChatModel.fromJson(Map<String, dynamic> json, String docId,
      {List<ChatParticipantModel>? participants}) {
    return ChatModel(
      id: docId,
      fileId: json['file_id'],
      createdAt: (json['created_at'] as Timestamp).toDate(),
      participants: participants ??
          (json['participants'] as List<dynamic>? ?? [])
              .map((p) =>
                  ChatParticipantModel.fromJson(Map<String, dynamic>.from(p)))
              .toList(),
      fileBarCode: json['file_barcode'],
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(
              Map<String, dynamic>.from(json['last_message']),
              'last_message',
            )
          : null,
      type: _mapStringToType(json['type']),
    );
  }

  static ChatType? _mapStringToType(String? typeStr) {
    if (typeStr == null) return null;
    switch (typeStr.toLowerCase()) {
      case 'direct':
        return ChatType.direct;
      default:
        return ChatType.group;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
      'created_at': createdAt,
      'file_barcode': fileBarCode,
      if (lastMessage != null) 'last_message': lastMessage!.toJson(this),
      'type': type?.name ?? 'group',
    };
  }
}

extension ChatModelExtensions on ChatModel {
  bool hasUnread(int userDesignationId) {
    if (lastMessage == null) return false;
    return lastMessage!.seenBy.contains(userDesignationId) != true;
  }
}
