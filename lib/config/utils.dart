import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static String serpKey = "";
}

class Utils {
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class ApiResponse {
  final bool status;
  final dynamic data;

  ApiResponse({
    required this.status,
    this.data,
  });
}

class Prefs {
  // INSTANCE
  static SharedPreferences? instance;

  static String requestTokens = "request_tokens";
  static String responseTokens = "response_tokens";

  static void setValue(String key, String value) {
    if (instance == null) {
      debugPrint("PREFS INSTANCE IS NULL");
      return;
    }

    debugPrint("SETTING PREFS: $key: $value");
    instance!.setString(key, value);
  }

  static String getValue(String key) {
    if (instance == null) {
      debugPrint("PREFS INSTANCE IS NULL");
      return "";
    }

    if (instance!.getString(key) == null) {
      debugPrint("KEY VALUE IS NULL");
      return "";
    }

    return instance!.getString(key)!;
  }
}
