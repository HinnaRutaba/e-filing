import 'package:efiling_balochistan/controllers/base_controller.dart';
import 'package:efiling_balochistan/models/daak_model.dart';

import 'package:flutter/material.dart';

class DaakState {
  final List<DaakModel> allDaak;
  final String searchText;
  final List<DaakModel> filteredDaak;

  DaakState({
    required this.allDaak,
    this.searchText = '',
    List<DaakModel>? filteredDaak,
  }) : filteredDaak = filteredDaak ?? allDaak;

  DaakState copyWith({
    List<DaakModel>? allDaak,
    String? searchText,
    List<DaakModel>? filteredDaak,
  }) {
    return DaakState(
      allDaak: allDaak ?? this.allDaak,
      searchText: searchText ?? this.searchText,
      filteredDaak: filteredDaak ?? this.filteredDaak,
    );
  }
}

class DaakController extends BaseControllerState<DaakState> {
  DaakController(super.state, super.ref);

  static final List<DaakModel> _dummyDaakList = [
    DaakModel(
      title: 'Letter regarding annual report',
      status: 'Pending',
      statusColor: const Color(0xFF336699),
      department: 'Finance',
      letterNumber: 'L-2026-001',
      daakNumber: 'D-1001',
      letterDate: '2026-03-20',
      receivedBy: 'Ali Khan',
      receivedDate: '2026-03-21',
      pdfUrl: null,
    ),
    DaakModel(
      title: 'Meeting Invitation',
      status: 'Approved',
      statusColor: const Color(0xFF1D9165),
      department: 'Admin',
      letterNumber: 'L-2026-002',
      daakNumber: 'D-1002',
      letterDate: '2026-03-18',
      receivedBy: 'Sara Baloch',
      receivedDate: '2026-03-19',
      pdfUrl: null,
    ),
    // Add more dummy data as needed
  ];

  DaakState get daakState => state ?? DaakState(allDaak: _dummyDaakList);

  List<DaakModel> get allDaak => daakState.allDaak;

  String get searchText => daakState.searchText;
  set searchText(String value) {
    state = daakState.copyWith(
      searchText: value,
      filteredDaak: daakState.allDaak.where((daak) {
        final query = value.toLowerCase();
        return daak.title.toLowerCase().contains(query) ||
            daak.department.toLowerCase().contains(query) ||
            daak.letterNumber.toLowerCase().contains(query) ||
            daak.daakNumber.toLowerCase().contains(query) ||
            daak.receivedBy.toLowerCase().contains(query);
      }).toList(),
    );
  }

  List<DaakModel> get filteredDaak => daakState.filteredDaak;
}
