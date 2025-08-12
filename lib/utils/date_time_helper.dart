import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  DateTimeHelper._();

  static const String _dateFormatterEEEddMMMyyyySpaces = "EEE dd MMM yyyy";
  static const String _dateFormatterEEEEddMMMyyyySpaces = "EEEE dd MMM yyyy";
  static const String _dateFormatterddMMMyyyySpaces = "dd MMM yyyy";
  static const String _dateFormatterSlash = "dd/MM/yyyy";
  static const String _dateFormatterSlashShort = "dd/MM/yy";
  static const String _dateFormatterEEEE = "EEEE";
  static const String _dateFormatterEEE = "EEE";
  static const String _dateFormatterEEEDD = "EEE dd";
  static const String _dateFormatterEEEDDMM = "EEE\n dd/MM";
  static const String _yyyyMMDD = "yyyy-MM-dd";
  static const String _dateFormatterddSpaces = "dd";

  static DateTime? parseDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return null;
    return DateTime.tryParse(date.toString());
  }

  static DateTime? toDate(DateTime? date) {
    if (date == null || date.toString().isEmpty) return null;
    return DateTime(date.year, date.month, date.day);
  }

  static TimeOfDay? parseTime(String? timeStr) {
    if (timeStr == null || !timeStr.contains(":")) return null;
    final parts = timeStr.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static bool isWithin(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final t = time.hour * 60 + time.minute;
    final s = start.hour * 60 + start.minute;
    final e = end.hour * 60 + end.minute;
    return s <= t && t < e;
  }

  static DateTime? combineDateAndTime(DateTime? date, String? timeStr) {
    if (date == null || timeStr == null || !timeStr.contains(":")) return null;

    try {
      final parts = timeStr.split(":");
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
    } catch (e) {
      print("Error parsing time: $e");
      return null;
    }
  }

  static String formatToAmPm(String? timeStr) {
    if (timeStr == null) return '';
    if (!timeStr.contains(":")) return timeStr;

    try {
      final parts = timeStr.split(":");
      int hour = int.parse(parts[0]);
      final minute = parts[1].padLeft(2, '0');

      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;

      return '$hour:$minute $period';
    } catch (e) {
      print("Error formatting time: $e");
      return timeStr;
    }
  }

  static String datFormatSlash(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date unspecified';
    }
    return DateFormat(_dateFormatterSlash).format(dateTime);
  }

  static String datFormatSlashShort(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date unspecified';
    }
    return DateFormat(_dateFormatterSlashShort).format(dateTime);
  }

  static String dateFormatEEEDD(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date unspecified';
    }
    return DateFormat(_dateFormatterEEEDD).format(dateTime);
  }

  static String dateFormatEEEDDMM(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date unspecified';
    }
    return DateFormat(_dateFormatterEEEDDMM).format(dateTime);
  }

  static String dayNameDMYFormat(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date unspecified';
    }
    return DateFormat(_dateFormatterEEEddMMMyyyySpaces).format(dateTime);
  }

  static String dayFullNameDMYFormat(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date unspecified';
    }
    return DateFormat(_dateFormatterEEEEddMMMyyyySpaces).format(dateTime);
  }

  static String dateDMYFormat(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date unspecified';
    }
    return DateFormat(_dateFormatterddMMMyyyySpaces).format(dateTime);
  }

  static String dayNameFormat(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date unspecified';
    }
    return DateFormat(_dateFormatterEEEE).format(dateTime);
  }

  static String dayMinNameFormat(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date unspecified';
    }
    return DateFormat(_dateFormatterEEE).format(dateTime);
  }

  static String apiFormat(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    return DateFormat(_yyyyMMDD).format(dateTime);
  }

  static String timeGreeting(DateTime dateTime) {
    var hour = dateTime.hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }

  static TimeOfDay durationToTimeOfDay(Duration duration) {
    final int hours = duration.inHours;
    final int minutes = duration.inMinutes.remainder(60);
    return TimeOfDay(hour: hours, minute: minutes);
  }

  static String timeOfDayToString(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String dayNameddFormat(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date unspecified';
    }
    return DateFormat(_dateFormatterddSpaces).format(dateTime);
  }
}
