class SummaryDaakModel {
  final int? id;
  final String? diaryNo;
  final String? letterNo;
  final String? subject;
  final String? date;
  final String? source;

  SummaryDaakModel({
    this.id,
    this.diaryNo,
    this.letterNo,
    this.subject,
    this.date,
    this.source,
  });

  factory SummaryDaakModel.fromJson(Map<String, dynamic> json) {
    return SummaryDaakModel(
      id: json['id'],
      diaryNo: json['diary_no'],
      letterNo: json['letter_no'],
      subject: json['subject'],
      date: json['date'],
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diary_no': diaryNo,
      'letter_no': letterNo,
      'subject': subject,
      'date': date,
      'source': source,
    };
  }

  SummaryDaakModel copyWith({
    int? id,
    String? diaryNo,
    String? letterNo,
    String? subject,
    String? date,
    String? source,
  }) {
    return SummaryDaakModel(
      id: id ?? this.id,
      diaryNo: diaryNo ?? this.diaryNo,
      letterNo: letterNo ?? this.letterNo,
      subject: subject ?? this.subject,
      date: date ?? this.date,
      source: source ?? this.source,
    );
  }
}
