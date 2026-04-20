import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FileMimeType {
  pdf,
  jpg,
  jpeg,
  png,
  gif,
  webp,
  svg,
  mp4,
  mov,
  avi,
  mkv,
  mp3,
  wav,
  aac,
  doc,
  docx,
  xls,
  xlsx,
  ppt,
  pptx,
  txt,
  csv,
  zip,
  rar,
  unknown,
}

enum FileCategory { image, video, pdf, file }

class HelperUtils {
  static const _imageTypes = {
    FileMimeType.jpg,
    FileMimeType.jpeg,
    FileMimeType.png,
    FileMimeType.gif,
    FileMimeType.webp,
    FileMimeType.svg,
  };

  static const _videoTypes = {
    FileMimeType.mp4,
    FileMimeType.mov,
    FileMimeType.avi,
    FileMimeType.mkv,
  };

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static String firstTwoLetters(String str) {
    if (str.isEmpty) return '';

    //ifString contains space, get 1st letter of first two words
    if (str.contains(' ')) {
      List<String> words = str
          .split(' ')
          .where((word) => word.trim().isNotEmpty)
          .toList();
      if (words.length >= 2 && words[0].isNotEmpty && words[1].isNotEmpty) {
        return (words[0][0] + words[1][0]).toUpperCase();
      } else if (words.isNotEmpty && words[0].isNotEmpty) {
        return words[0].length >= 2
            ? words[0].substring(0, 2).toUpperCase()
            : words[0][0].toUpperCase();
      }
      return '';
    }
    return str.length >= 2
        ? str.substring(0, 2).toUpperCase()
        : str[0].toUpperCase();
  }

  static Color getTagColor(String colorName) {
    Color tagColor = Colors.blue;
    if (colorName == 'danger') {
      tagColor = Colors.red[700]!;
    } else if (colorName == 'warning') {
      tagColor = Colors.amber[700]!;
    } else if (colorName == 'success') {
      tagColor = Colors.green[700]!;
    } else if (colorName == 'info') {
      tagColor = Colors.blue[700]!;
    } else if (colorName == 'primary') {
      tagColor = Colors.blue[700]!;
    } else if (colorName == 'secondary') {
      tagColor = Colors.grey[700]!;
    } else if (colorName == 'dark') {
      tagColor = Colors.black;
    }
    return tagColor;
  }

  static FileMimeType getFileTypeFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final lastDot = path.lastIndexOf('.');
      if (lastDot != -1 && lastDot < path.length - 1) {
        final ext = path.substring(lastDot + 1).toLowerCase();
        return FileMimeType.values.firstWhere(
          (e) => e.name == ext,
          orElse: () => FileMimeType.unknown,
        );
      }
    } catch (_) {}
    return FileMimeType.unknown;
  }

  static FileCategory getFileCategoryFromUrl(String url) {
    final type = getFileTypeFromUrl(url);
    if (_imageTypes.contains(type)) return FileCategory.image;
    if (_videoTypes.contains(type)) return FileCategory.video;
    if (type == FileMimeType.pdf) return FileCategory.pdf;
    return FileCategory.file;
  }
}
