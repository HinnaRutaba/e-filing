import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:efiling_balochistan/models/chat/chat_model.dart';

class MessageModel {
  final String id;
  final String text;
  final int? userId;
  final int userDesignationId;
  final String userName;
  final DateTime sentAt;
  final List<String?> attachments;
  final List<int> hiddenFrom;
  final List<int> seenBy;

  MessageModel({
    required this.id,
    required this.text,
    required this.userId,
    required this.userDesignationId,
    required this.userName,
    required this.sentAt,
    this.attachments = const [],
    this.hiddenFrom = const [],
    this.seenBy = const [],
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String docId) {
    try {
      return MessageModel(
        id: docId,
        text: json['text'] ?? '',
        userId: json['sent_by']?['user_id'],
        userDesignationId: json['sent_by']?['user_designation_id'] ?? 0,
        userName: json['sent_by']?['user_name'] ?? 'Unknown',
        sentAt: json['sent_at'] != null
            ? (json['sent_at'] as Timestamp).toDate()
            : DateTime.now(),
        attachments: (json['attachments'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        hiddenFrom: (json['hidden_from'] as List<dynamic>? ?? [])
            .map((e) => e as int)
            .toList(),
        seenBy: List<int>.from(json['seen_by'] ?? []),
      );
    } catch (e, s) {
      print("Message Model Error____${e}_____$s");
      return MessageModel(
        id: '',
        text: '',
        userId: null,
        userDesignationId: 0,
        userName: '',
        sentAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson(ChatModel chat) {
    return {
      'text': text,
      'sent_by': {
        'user_id': userId,
        'user_designation_id': userDesignationId,
        'user_name': userName,
      },
      'sent_at': sentAt,
      'attachments': attachments,
      'hidden_from': chat.participants
          .where((e) => e.removed)
          .map((e) => e.userDesignationId)
          .toList(),
      'seen_by': seenBy,
    };
  }

  MessageModel copyWith({
    String? id,
    String? text,
    int? userId,
    int? userDesignationId,
    String? userName,
    DateTime? sentAt,
    List<String>? attachments,
    List<int>? hiddenFrom,
    List<int>? seenBy,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      userId: userId ?? this.userId,
      userDesignationId: userDesignationId ?? this.userDesignationId,
      userName: userName ?? this.userName,
      sentAt: sentAt ?? this.sentAt,
      attachments: attachments ?? this.attachments,
      hiddenFrom: hiddenFrom ?? this.hiddenFrom,
      seenBy: seenBy ?? this.seenBy,
    );
  }
}
