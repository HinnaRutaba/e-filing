import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';

class Validators {
  static const String datePattern =
      r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$';

  static var onlyDigits =
      FilteringTextInputFormatter.deny(RegExp(r'^[a-z A-Z,.\-]+$'));

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  static String? notEmptyValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10 || !value.startsWith('+')) {
      return 'Phone number must be at least 10 characters long and start with +';
    }
    return null;
  }

  static String? dateValidator(String? value) {
    final RegExp regExp = RegExp(datePattern);
    if (value == null || value.isEmpty) {
      return 'Date is required';
    } else if (!regExp.hasMatch(value)) {
      return 'Enter a valid date in DD/MM/YYYY format';
    }
    return null;
  }
}
