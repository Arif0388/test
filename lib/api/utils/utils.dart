// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:intl/intl.dart';

class Utils {
  static const int SECOND_MILLIS = 1000;
  static const int MINUTE_MILLIS = 60 * SECOND_MILLIS;
  static const int HOUR_MILLIS = 60 * MINUTE_MILLIS;
  static const int DAY_MILLIS = 24 * HOUR_MILLIS;

  static String getTimeAgo(DateTime dateTime) {
    // Convert the given DateTime to local time
    DateTime localDateTime = dateTime.toLocal();

    int time = localDateTime.millisecondsSinceEpoch;
    int now = DateTime.now().millisecondsSinceEpoch;

    if (time > now || time <= 0) {
      return "just now";
    }

    final int diff = now - time;
    if (diff < MINUTE_MILLIS) {
      return "just now";
    } else if (diff < 2 * MINUTE_MILLIS) {
      return "a minute ago";
    } else if (diff < 50 * MINUTE_MILLIS) {
      return "${(diff / MINUTE_MILLIS).floor()} minutes ago";
    } else if (diff < 90 * MINUTE_MILLIS) {
      return "an hour ago";
    } else if (diff < 24 * HOUR_MILLIS) {
      return "${(diff / HOUR_MILLIS).floor()} hours ago";
    } else if (diff < 48 * HOUR_MILLIS) {
      return "yesterday";
    } else if (diff < 8 * DAY_MILLIS) {
      return "${(diff / DAY_MILLIS).floor()} days ago";
    } else {
      DateFormat formatter = DateFormat('dd/MM/yyyy');
      DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
      return formatter.format(date.toLocal());
    }
  }

  static isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String getDateString(DateTime date) {
    DateTime localTime = date.toLocal();
    DateTime now = DateTime.now();

    // Check if the date is today
    if (localTime.year == now.year &&
        localTime.month == now.month &&
        localTime.day == now.day) {
      return "Today";
    }
    return DateFormat('dd MMM yyyy').format(localTime);
  }

  static String getTimeString(DateTime date) {
    DateTime localTime = date.toLocal();
    return DateFormat('hh:mm a').format(localTime);
  }

  static String formatDate(DateTime? dateTime) {
    DateFormat outputFormat = DateFormat('MMM d, yyyy  h:mm a');
    if (dateTime == null) {
      return outputFormat.format(DateTime.now());
    }
    try {
      String formattedDate = outputFormat.format(dateTime.toLocal());
      return formattedDate;
    } catch (e) {
      return outputFormat.format(DateTime.now());
    }
  }

  static String formatBytes(int a, int b) {
    if (a < 0) {
      return "Invalid size";
    }

    if (a == 0) {
      return "0 Bytes";
    }

    final List<String> units = [
      "Bytes",
      "KB",
      "MB",
      "GB",
      "TB",
      "PB",
      "EB",
      "ZB",
      "YB"
    ];
    int d = (log(a) / log(1024)).floor();
    double size = a / pow(1024, d);
    NumberFormat numberFormat = NumberFormat("#.##");

    return "${numberFormat.format(size)} ${units[d]}";
  }
}
