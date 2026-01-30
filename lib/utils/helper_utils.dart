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
      List<String> words = str.split(' ');
      if (words.length >= 2) {
        return (words[0][0] + words[1][0]).toUpperCase();
      } else {
        return words[0][0].toUpperCase();
      }
    }
    return str.length >= 2
        ? str.substring(0, 2).toUpperCase()
        : str[0].toUpperCase();
  }
}
