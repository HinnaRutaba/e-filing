// ================= SCHEMA =================
import 'package:efiling_balochistan/models/file_model.dart';

class NewFileDataSchema {
  static const String data = "data";
  static const String fileTypes = "file_types";
  static const String tags = "tags";
}

class FileTypeSchema {
  static const String id = "id";
  static const String title = "title";
}

// class TagSchema {
//   static const String id = "id";
//   static const String title = "title";
//   static const String color = "color";
// }

// ================= MODELS =================

class FileTypeModel {
  final int? id;
  final String? title;

  FileTypeModel({this.id, this.title});

  factory FileTypeModel.fromJson(Map<String, dynamic> json) {
    return FileTypeModel(
      id: json[FileTypeSchema.id] as int?,
      title: json[FileTypeSchema.title] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      FileTypeSchema.id: id,
      FileTypeSchema.title: title,
    };
  }
}

// class TagModel {
//   final int? id;
//   final String? title;
//   final String? color;
//
//   TagModel({this.id, this.title, this.color});
//
//   factory TagModel.fromJson(Map<String, dynamic> json) {
//     return TagModel(
//       id: json[TagSchema.id] as int?,
//       title: json[TagSchema.title] as String?,
//       color: json[TagSchema.color] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       TagSchema.id: id,
//       TagSchema.title: title,
//       TagSchema.color: color,
//     };
//   }
// }

class NewFileDataModel {
  final List<FileTypeModel>? fileTypes;
  final List<TagModel>? tags;

  NewFileDataModel({
    this.fileTypes,
    this.tags,
  });

  factory NewFileDataModel.fromJson(Map<String, dynamic> json) {
    final data = json[NewFileDataSchema.data] as Map<String, dynamic>?;

    return NewFileDataModel(
      fileTypes: (data?[NewFileDataSchema.fileTypes] as List<dynamic>?)
          ?.map((e) => FileTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      tags: (data?[NewFileDataSchema.tags] as List<dynamic>?)
          ?.map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      NewFileDataSchema.fileTypes: fileTypes?.map((e) => e.toJson()).toList(),
      NewFileDataSchema.tags: tags?.map((e) => e.toJson()).toList(),
    };
  }
}
