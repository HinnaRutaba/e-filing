import 'voice_note_upload_model.dart';

class SummaryVoiceNoteModel {
  final int id;
  final String streamUrl;
  final int durationSec;
  final VoiceNoteVisibility visibility;
  final VoiceNoteContext context;
  final String uploadedBy;
  final DateTime? uploadedAt;

  const SummaryVoiceNoteModel({
    required this.id,
    required this.streamUrl,
    required this.durationSec,
    required this.visibility,
    required this.context,
    required this.uploadedBy,
    this.uploadedAt,
  });

  String get formattedDuration {
    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  factory SummaryVoiceNoteModel.fromJson(Map<String, dynamic> json) {
    return SummaryVoiceNoteModel(
      id: json['id'],
      streamUrl: json['stream_url'],
      durationSec: json['duration_sec'],
      visibility: VoiceNoteVisibility.values.firstWhere(
        (e) => e.value == json['visibility'],
      ),
      context: VoiceNoteContext.values.firstWhere(
        (e) => e.value == json['context'],
      ),
      uploadedBy: json['uploaded_by'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'])
          : null,
    );
  }
}
