class SummaryFileModel {
  final int? id;
  final String? referenceNo;
  final String? barcode;
  final String? subject;
  final String? date;

  SummaryFileModel({
    this.id,
    this.referenceNo,
    this.barcode,
    this.subject,
    this.date,
  });

  factory SummaryFileModel.fromJson(Map<String, dynamic> json) {
    return SummaryFileModel(
      id: json['id'],
      referenceNo: json['reference_no'],
      barcode: json['barcode'],
      subject: json['subject'],
      date: json['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference_no': referenceNo,
      'barcode': barcode,
      'subject': subject,
      'date': date,
    };
  }

  SummaryFileModel copyWith({
    int? id,
    String? referenceNo,
    String? barcode,
    String? subject,
    String? date,
  }) {
    return SummaryFileModel(
      id: id ?? this.id,
      referenceNo: referenceNo ?? this.referenceNo,
      barcode: barcode ?? this.barcode,
      subject: subject ?? this.subject,
      date: date ?? this.date,
    );
  }
}
