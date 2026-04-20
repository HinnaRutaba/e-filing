import 'package:efiling_balochistan/constants/app_colors.dart';
import 'package:efiling_balochistan/models/active_user_desg_model.dart';
import 'package:flutter/material.dart';

enum DaakTags {
  confidential("Confidential", 3, Colors.orange),
  normal("Normal", 2, AppColors.primary),
  urgent("Urgent", 1, Colors.red);

  final String label;
  final int value;
  final Color color;
  const DaakTags(this.label, this.value, this.color);

  static DaakTags? fromValue(int value) {
    return DaakTags.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DaakTags.normal,
    );
  }
}

enum DaakStatus {
  inProgress1("In Progress", 1, Colors.blue),
  inProgress2("In Progress", 2, Colors.blue),
  inProgress3("In Progress", 3, Colors.blue),
  forwarded("Forwarded", 4, Colors.orange),
  nfa("NFA", 5, AppColors.textSecondary),
  filePutup("In Progress (File Putup)", 6, AppColors.secondary),
  disposedOff("Disposed Off", 7, Colors.red);

  final String label;
  final int value;
  final Color color;
  const DaakStatus(this.label, this.value, this.color);

  static DaakStatus? fromValue(int value) {
    return DaakStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DaakStatus.inProgress1,
    );
  }
}

class DaakMeta {
  final Map<String, List<String>>? statusMap;
  final Map<String, String>? statusFilterOptions;
  final List<DepartmentUser>? departmentUsers;
  final List<FileType>? fileTypes;
  final List<Tag>? tags;
  final ActiveUserDesg? activeUserDesg;

  DaakMeta({
    this.statusMap,
    this.statusFilterOptions,
    this.departmentUsers,
    this.fileTypes,
    this.tags,
    this.activeUserDesg,
  });

  factory DaakMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DaakMeta();
    return DaakMeta(
      statusMap: json['status_map'] != null
          ? Map<String, List<String>>.from(
              json['status_map'].map(
                (k, v) => MapEntry(k, List<String>.from(v)),
              ),
            )
          : null,
      statusFilterOptions: json['status_filter_options'] != null
          ? Map<String, String>.from(json['status_filter_options'])
          : null,
      departmentUsers: json['department_users'] != null
          ? (json['department_users'] as List)
                .map((i) => DepartmentUser.fromJson(i))
                .toList()
          : null,
      fileTypes: json['file_types'] != null
          ? (json['file_types'] as List)
                .map((i) => FileType.fromJson(i))
                .toList()
          : null,
      tags: json['tags'] != null
          ? (json['tags'] as List).map((i) => Tag.fromJson(i)).toList()
          : null,
      activeUserDesg: json['active_user_desg'] != null
          ? ActiveUserDesg.fromJson(json['active_user_desg'])
          : null,
    );
  }
}

class DepartmentUser {
  final int? id;
  final String? name;
  final String? designation;
  final String? section;
  final String? role;

  DepartmentUser({
    this.id,
    this.name,
    this.designation,
    this.section,
    this.role,
  });

  factory DepartmentUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DepartmentUser();
    return DepartmentUser(
      id: json['id'],
      name: json['name'],
      designation: json['designation'],
      section: json['section'],
      role: json['role'],
    );
  }
}

class FileType {
  final int? id;
  final String? title;

  FileType({this.id, this.title});

  factory FileType.fromJson(Map<String, dynamic>? json) {
    if (json == null) return FileType();
    return FileType(id: json['id'], title: json['title']);
  }
}

class Tag {
  final int? id;
  final String? title;

  Tag({this.id, this.title});

  factory Tag.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Tag();
    return Tag(id: json['id'], title: json['title']);
  }
}
