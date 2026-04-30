sealed class SignForwardModel {
  final int targetDepartmentId;
  final int? targetUserDesgId;
  final String secretarySignaturePath;

  const SignForwardModel({
    required this.targetDepartmentId,
    this.targetUserDesgId,
    required this.secretarySignaturePath,
  });

  Map<String, dynamic> toJson(int userDesgId);
}

final class TypedSignForwardModel extends SignForwardModel {
  final String remarks;

  const TypedSignForwardModel({
    required super.targetDepartmentId,
    super.targetUserDesgId,
    required super.secretarySignaturePath,
    required this.remarks,
  });

  @override
  Map<String, dynamic> toJson(int userDesgId) {
    return {
      'userDesgID': userDesgId,
      'target_department_id': targetDepartmentId,
      'target_user_desg_id': targetUserDesgId,
      'remarks': remarks,
      'body': remarks,
      'secretary_signature_path': secretarySignaturePath,
      'handwritten_mode': 'type',
    };
  }
}

final class HandwrittenSignForwardModel extends SignForwardModel {
  final String handwrittenStrokesJson;
  final String handwrittenPngBase64;
  final int handwrittenWidth;
  final int handwrittenHeight;
  final String handwrittenPenColor;

  const HandwrittenSignForwardModel({
    required super.targetDepartmentId,
    super.targetUserDesgId,
    required super.secretarySignaturePath,
    required this.handwrittenStrokesJson,
    required this.handwrittenPngBase64,
    required this.handwrittenWidth,
    required this.handwrittenHeight,
    required this.handwrittenPenColor,
  });

  @override
  Map<String, dynamic> toJson(int userDesgId) {
    return {
      'userDesgID': userDesgId,
      'target_department_id': targetDepartmentId,
      'target_user_desg_id': targetUserDesgId,
      'remarks': '',
      'body': '',
      'secretary_signature_path': secretarySignaturePath,
      'handwritten_mode': 'write',
      'handwritten_strokes_json': handwrittenStrokesJson,
      'handwritten_png_base64': handwrittenPngBase64,
      'handwritten_width': handwrittenWidth,
      'handwritten_height': handwrittenHeight,
      'handwritten_pen_color': handwrittenPenColor,
    };
  }
}
