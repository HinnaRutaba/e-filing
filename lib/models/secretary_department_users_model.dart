import 'package:efiling_balochistan/models/pagination_model.dart';
import 'package:flutter/foundation.dart';

/// `data` of `secretary/dashboard/users`: one page of department users with
/// their file counts, plus the filters the endpoint accepts.
class SecretaryDepartmentUsersModel {
  final List<SecretaryDepartmentUserModel> items;
  final PaginationModel? pagination;
  final SecretaryUsersFiltersModel? filters;

  SecretaryDepartmentUsersModel({
    this.items = const [],
    this.pagination,
    this.filters,
  });

  SecretaryDepartmentUsersModel copyWith({
    List<SecretaryDepartmentUserModel>? items,
    PaginationModel? pagination,
    SecretaryUsersFiltersModel? filters,
  }) {
    return SecretaryDepartmentUsersModel(
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
      filters: filters ?? this.filters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryDepartmentUsersSchema.items: items
          .map((e) => e.toJson())
          .toList(),
      SecretaryDepartmentUsersSchema.pagination: pagination?.toJson(),
      SecretaryDepartmentUsersSchema.filters: filters?.toJson(),
    };
  }

  factory SecretaryDepartmentUsersModel.fromJson(Map<String, dynamic> map) {
    return SecretaryDepartmentUsersModel(
      items: map[SecretaryDepartmentUsersSchema.items] != null
          ? List<SecretaryDepartmentUserModel>.from(
              (map[SecretaryDepartmentUsersSchema.items] as List).map(
                (e) => SecretaryDepartmentUserModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              ),
            )
          : [],
      pagination: map[SecretaryDepartmentUsersSchema.pagination] != null
          ? PaginationModel.fromJson(
              Map<String, dynamic>.from(
                map[SecretaryDepartmentUsersSchema.pagination],
              ),
            )
          : null,
      filters: map[SecretaryDepartmentUsersSchema.filters] != null
          ? SecretaryUsersFiltersModel.fromJson(
              Map<String, dynamic>.from(
                map[SecretaryDepartmentUsersSchema.filters],
              ),
            )
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryDepartmentUsersModel &&
        listEquals(other.items, items) &&
        other.pagination == pagination &&
        other.filters == filters;
  }

  @override
  int get hashCode => items.hashCode ^ pagination.hashCode ^ filters.hashCode;
}

class SecretaryDepartmentUsersSchema {
  static const String items = 'items';
  static const String pagination = 'pagination';
  static const String filters = 'filters';
}

// ---------------------------------------------------------------------------

class SecretaryDepartmentUserModel {
  final int? userDesgId;
  final String? userTitle;
  final String? designation;
  final int? sectionId;
  final String? section;
  final int? created;
  final int? pending;
  final int? disposedOff;
  final int? forwarded;

  SecretaryDepartmentUserModel({
    this.userDesgId,
    this.userTitle,
    this.designation,
    this.sectionId,
    this.section,
    this.created,
    this.pending,
    this.disposedOff,
    this.forwarded,
  });

  SecretaryDepartmentUserModel copyWith({
    int? userDesgId,
    String? userTitle,
    String? designation,
    int? sectionId,
    String? section,
    int? created,
    int? pending,
    int? disposedOff,
    int? forwarded,
  }) {
    return SecretaryDepartmentUserModel(
      userDesgId: userDesgId ?? this.userDesgId,
      userTitle: userTitle ?? this.userTitle,
      designation: designation ?? this.designation,
      sectionId: sectionId ?? this.sectionId,
      section: section ?? this.section,
      created: created ?? this.created,
      pending: pending ?? this.pending,
      disposedOff: disposedOff ?? this.disposedOff,
      forwarded: forwarded ?? this.forwarded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryDepartmentUserSchema.userDesgId: userDesgId,
      SecretaryDepartmentUserSchema.userTitle: userTitle,
      SecretaryDepartmentUserSchema.designation: designation,
      SecretaryDepartmentUserSchema.sectionId: sectionId,
      SecretaryDepartmentUserSchema.section: section,
      SecretaryDepartmentUserSchema.created: created,
      SecretaryDepartmentUserSchema.pending: pending,
      SecretaryDepartmentUserSchema.disposedOff: disposedOff,
      SecretaryDepartmentUserSchema.forwarded: forwarded,
    };
  }

  factory SecretaryDepartmentUserModel.fromJson(Map<String, dynamic> map) {
    return SecretaryDepartmentUserModel(
      userDesgId: map[SecretaryDepartmentUserSchema.userDesgId]?.toInt(),
      userTitle: map[SecretaryDepartmentUserSchema.userTitle],
      designation: map[SecretaryDepartmentUserSchema.designation],
      sectionId: map[SecretaryDepartmentUserSchema.sectionId]?.toInt(),
      section: map[SecretaryDepartmentUserSchema.section],
      created: map[SecretaryDepartmentUserSchema.created]?.toInt(),
      pending: map[SecretaryDepartmentUserSchema.pending]?.toInt(),
      disposedOff: map[SecretaryDepartmentUserSchema.disposedOff]?.toInt(),
      forwarded: map[SecretaryDepartmentUserSchema.forwarded]?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryDepartmentUserModel &&
        other.userDesgId == userDesgId &&
        other.userTitle == userTitle &&
        other.designation == designation &&
        other.sectionId == sectionId &&
        other.section == section &&
        other.created == created &&
        other.pending == pending &&
        other.disposedOff == disposedOff &&
        other.forwarded == forwarded;
  }

  @override
  int get hashCode =>
      userDesgId.hashCode ^
      userTitle.hashCode ^
      designation.hashCode ^
      sectionId.hashCode ^
      section.hashCode ^
      created.hashCode ^
      pending.hashCode ^
      disposedOff.hashCode ^
      forwarded.hashCode;
}

class SecretaryDepartmentUserSchema {
  static const String userDesgId = 'user_desg_id';
  static const String userTitle = 'user_title';
  static const String designation = 'designation';
  static const String sectionId = 'section_id';
  static const String section = 'section';
  static const String created = 'created';
  static const String pending = 'pending';
  static const String disposedOff = 'disposed_off';
  static const String forwarded = 'forwarded';
}

// ---------------------------------------------------------------------------

class SecretaryUsersFiltersModel {
  final List<SecretaryFilterSectionModel> sections;
  final List<String> sortOptions;

  SecretaryUsersFiltersModel({
    this.sections = const [],
    this.sortOptions = const [],
  });

  SecretaryUsersFiltersModel copyWith({
    List<SecretaryFilterSectionModel>? sections,
    List<String>? sortOptions,
  }) {
    return SecretaryUsersFiltersModel(
      sections: sections ?? this.sections,
      sortOptions: sortOptions ?? this.sortOptions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryUsersFiltersSchema.sections: sections
          .map((e) => e.toJson())
          .toList(),
      SecretaryUsersFiltersSchema.sortOptions: sortOptions,
    };
  }

  factory SecretaryUsersFiltersModel.fromJson(Map<String, dynamic> map) {
    return SecretaryUsersFiltersModel(
      sections: map[SecretaryUsersFiltersSchema.sections] != null
          ? List<SecretaryFilterSectionModel>.from(
              (map[SecretaryUsersFiltersSchema.sections] as List).map(
                (e) => SecretaryFilterSectionModel.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              ),
            )
          : [],
      sortOptions: map[SecretaryUsersFiltersSchema.sortOptions] != null
          ? List<String>.from(
              (map[SecretaryUsersFiltersSchema.sortOptions] as List).map(
                (e) => e.toString(),
              ),
            )
          : [],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryUsersFiltersModel &&
        listEquals(other.sections, sections) &&
        listEquals(other.sortOptions, sortOptions);
  }

  @override
  int get hashCode => sections.hashCode ^ sortOptions.hashCode;
}

class SecretaryUsersFiltersSchema {
  static const String sections = 'sections';
  static const String sortOptions = 'sort_options';
}

// ---------------------------------------------------------------------------

class SecretaryFilterSectionModel {
  final int? id;
  final String? title;

  SecretaryFilterSectionModel({this.id, this.title});

  SecretaryFilterSectionModel copyWith({int? id, String? title}) {
    return SecretaryFilterSectionModel(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SecretaryFilterSectionSchema.id: id,
      SecretaryFilterSectionSchema.title: title,
    };
  }

  factory SecretaryFilterSectionModel.fromJson(Map<String, dynamic> map) {
    return SecretaryFilterSectionModel(
      id: map[SecretaryFilterSectionSchema.id]?.toInt(),
      title: map[SecretaryFilterSectionSchema.title],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretaryFilterSectionModel &&
        other.id == id &&
        other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ title.hashCode;
}

class SecretaryFilterSectionSchema {
  static const String id = 'id';
  static const String title = 'title';
}
