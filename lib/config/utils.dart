import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
