import 'package:efiling_balochistan/utils/date_time_helper.dart';
import 'package:image_picker/image_picker.dart';

class CreateDaakModel {
  final int? userDesgId;
  final String? subject;
  final String? letterNo;
  final DateTime? letterDate;
  final int? sourceDepartmentId;
  final String? sourceDepartmentName;
  final int? toSecretaryUserDesgId;
  final XFile? incomingScan;

  CreateDaakModel({
    this.userDesgId,
    this.subject,
    this.letterNo,
    this.letterDate,
    this.sourceDepartmentId,
    this.sourceDepartmentName,
    this.toSecretaryUserDesgId,
    this.incomingScan,
  });

  CreateDaakModel copyWith({
    int? userDesgId,
    String? subject,
    String? letterNo,
    DateTime? letterDate,
    int? sourceDepartmentId,
    String? sourceDepartmentName,
    int? toSecretaryUserDesgId,
    XFile? incomingScan,
  }) {
    return CreateDaakModel(
      userDesgId: userDesgId ?? this.userDesgId,
      subject: subject ?? this.subject,
      letterNo: letterNo ?? this.letterNo,
      letterDate: letterDate ?? this.letterDate,
      sourceDepartmentId: sourceDepartmentId ?? this.sourceDepartmentId,
      sourceDepartmentName: sourceDepartmentName ?? this.sourceDepartmentName,
      toSecretaryUserDesgId:
          toSecretaryUserDesgId ?? this.toSecretaryUserDesgId,
      incomingScan: incomingScan ?? this.incomingScan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      CreateDaakSchema.userDesgId: userDesgId,
      CreateDaakSchema.subject: subject,
      if (letterNo != null && letterNo!.isNotEmpty)
        CreateDaakSchema.letterNo: letterNo,
      if (letterDate != null)
        CreateDaakSchema.letterDate: DateTimeHelper.apiFormat(letterDate),
      CreateDaakSchema.sourceDepartmentId: sourceDepartmentId,
      // Required only when sourceDepartmentId is 0 (i.e. "Other Department").
      if (sourceDepartmentId == 0 &&
          sourceDepartmentName != null &&
          sourceDepartmentName!.isNotEmpty)
        CreateDaakSchema.sourceDepartmentName: sourceDepartmentName,
      CreateDaakSchema.toSecretaryUserDesgId: toSecretaryUserDesgId,
    };
  }
}

class CreateDaakSchema {
  static const String userDesgId = 'userDesgID';
  static const String subject = 'subject';
  static const String letterNo = 'letter_no';
  static const String letterDate = 'letter_date';
  static const String sourceDepartmentId = 'source_department_id';
  static const String sourceDepartmentName = 'source_department_name';
  static const String toSecretaryUserDesgId = 'to_secretary_user_desg_id';
  static const String incomingScan = 'incoming_scan';
}
