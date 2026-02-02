import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelperUtils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static String firstTwoLetters(String str) {
    if (str.isEmpty) return '';

    //ifString contains space, get 1st letter of first two words
    if (str.contains(' ')) {
      List<String> words =
          str.split(' ').where((word) => word.trim().isNotEmpty).toList();
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
}
