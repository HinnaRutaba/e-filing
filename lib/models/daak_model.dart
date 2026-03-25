import 'package:flutter/material.dart';

class DaakModel {
  final String title;
  final String status;
  final Color statusColor;
  final String department;
  final String letterNumber;
  final String daakNumber;
  final String letterDate;
  final String receivedBy;
  final String receivedDate;
  final String? pdfUrl;

  DaakModel({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.department,
    required this.letterNumber,
    required this.daakNumber,
    required this.letterDate,
    required this.receivedBy,
    required this.receivedDate,
    this.pdfUrl,
  });
}
