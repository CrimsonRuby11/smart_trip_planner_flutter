import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

class ApiDriver {
  static Future<ApiResponse> get(Uri url) async {
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return ApiResponse(status: true, data: jsonDecode(response.body));
      } else {
        return ApiResponse(status: false, data: jsonDecode(response.body));
      }
    } catch (e) {
      return ApiResponse(status: false);
    }
  }
}

class Prefs {
  // INSTANCE
  static SharedPreferences? instance;

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
