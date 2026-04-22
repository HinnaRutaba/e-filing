class AttachmentModel {
  final int? id;
  final String? attachmentType;
  final String? originalName;
  final String? mimeType;
  final int? fileSize;
  final String? fileUrl;
  final DateTime? uploadedAt;

  AttachmentModel({
    this.id,
    this.attachmentType,
    this.originalName,
    this.mimeType,
    this.fileSize,
    this.fileUrl,
    this.uploadedAt,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'],
      attachmentType: json['attachment_type'],
      originalName: json['original_name'],
      mimeType: json['mime_type'],
      fileSize: json['file_size'],
      fileUrl: json['file_url'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'])
          : null,
    );
  }

  bool get isSupporting =>
      originalName != null && originalName!.trimLeft().startsWith('[Flag:');

  bool get isMainAttachment => !isSupporting;

  String? get fileSizeText {
    if (fileSize == null) return null;
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    if (fileSize! >= gb) {
      return '${(fileSize! / gb).toStringAsFixed(2)} GB';
    } else if (fileSize! >= mb) {
      return '${(fileSize! / mb).toStringAsFixed(2)} MB';
    } else if (fileSize! >= kb) {
      return '${(fileSize! / kb).toStringAsFixed(1)} KB';
    } else {
      return '$fileSize B';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attachment_type': attachmentType,
      'original_name': originalName,
      'mime_type': mimeType,
      'file_size': fileSize,
      'file_url': fileUrl,
      'uploaded_at': uploadedAt?.toIso8601String(),
    };
  }
}
