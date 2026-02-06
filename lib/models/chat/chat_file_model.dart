class ChatFileModel {
  final int? fileId;
  final String? originalFilename;
  final String? storedFilename;
  final String? fileUrl;
  final String? fileSize;
  final int? fileSizeBytes;
  final String? mimeType;
  final String? createdAt;

  ChatFileModel({
    this.fileId,
    this.originalFilename,
    this.storedFilename,
    this.fileUrl,
    this.fileSize,
    this.fileSizeBytes,
    this.mimeType,
    this.createdAt,
  });

  factory ChatFileModel.fromJson(Map<String, dynamic> json) {
    return ChatFileModel(
      fileId: json['file_id'],
      originalFilename: json['original_filename'],
      storedFilename: json['stored_filename'],
      fileUrl: json['file_url'],
      fileSize: json['file_size'],
      fileSizeBytes: json['file_size_bytes'],
      mimeType: json['mime_type'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_id': fileId,
      'original_filename': originalFilename,
      'stored_filename': storedFilename,
      'file_url': fileUrl,
      'file_size': fileSize,
      'file_size_bytes': fileSizeBytes,
      'mime_type': mimeType,
      'created_at': createdAt,
    };
  }
}
