import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';

class ResultResponse {
  final bool status;
  final dynamic data;
  final int requestTokens;
  final int responseTokens;

  ResultResponse({
    required this.status,
    this.requestTokens = 0,
    this.responseTokens = 0,
    this.data,
  });
}

class ResultRepo {
  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
    tools: [
      Tool.googleSearch(),
    ],
  );

  Future<ResultResponse> refinePrompt(String tripString, String prompt) async {
    try {
      debugPrint("STARTING REFINE QUERY: $prompt");

      final text = [
        Content.text('''
Given the trip details, refine the trip according to the prompt and give me an itinerary, set status to 'failure' if given prompt text is not relevant to refining a trip itinerary, in the following json format:
{
  "status": "success",
  "title": "Kyoto 5-Day Solo Trip",
  "startDate": "2025-04-10",
  "endDate": "2025-04-15",
  "days": [
    {
      "date": "2025-04-10",
      "summary": "Fushimi Inari & Gion",
      "items": [
        { 
          "time": "09:00",
          "activity": "Climb Fushimi Inari Shrine",
          "location": "34.9671,135.7727"
        },
        { 
          "time": "09:00",
          "activity": "Climb Fushimi Inari Shrine",
          "location": "34.9671,135.7727"
        },
        { 
          "time": "09:00",
          "activity": "Climb Fushimi Inari Shrine",
          "location": "34.9671,135.7727"
        },
      ]
    }
  ]
}

location string must be latitude and longitude in the format "lat,lng"

this is the prompt:
$prompt
this is the trip details
$tripString

set 'status' value to failure if given prompt is not related to generating an itinerary, or if there is any errors.
'''),
      ];

      final response = await model.generateContent(text);
      debugPrint("PROMPT RESPONSE: ${response.text}");

      final rawJson = response.text;
      Map<String, dynamic> parsedJson = {};
      if (rawJson != null) {
        final startIndex = rawJson.indexOf('{');
        final endIndex = rawJson.lastIndexOf('}') + 1;

        if (startIndex != -1 && endIndex != 0 && endIndex > startIndex) {
          parsedJson = jsonDecode(rawJson.substring(startIndex, endIndex));

          if (parsedJson['status'] == 'failure') {
            return ResultResponse(
              status: false,
              data: parsedJson,
            );
          }
          return ResultResponse(
            status: true,
            data: parsedJson,
            requestTokens: response.usageMetadata!.promptTokenCount!,
            responseTokens: response.usageMetadata!.candidatesTokenCount!,
          );
        }
      }
      return ResultResponse(status: false);
    } catch (e) {
      rethrow;
    }
  }

  Stream<String> searchPromptStream(String prompt) async* {
    debugPrint("STARTING STREAMING QUERY: $prompt");

    final text = [
      Content.text('''
For this prompt, give me an itinerary for a trip in the following json format:
{
  "status": "success",
  "title": "Kyoto 5-Day Solo Trip",
  "startDate": "2025-04-10",
  "endDate": "2025-04-15",
  "days": [
    {
      "date": "2025-04-10",
      "summary": "Fushimi Inari & Gion",
      "items": [
        { 
          "time": "09:00",
          "activity": "Climb Fushimi Inari Shrine",
          "location": "34.9671,135.7727"
        }
      ]
    }
  ]
}

location string must be latitude and longitude in the format "lat,lng"

this is the prompt:
$prompt

set 'status' value to failure if given prompt is not related to generating an itinerary, or if there is any errors.

'''),
    ];

    final responseStream = model.generateContentStream(text);

    await for (final response in responseStream) {
      if (response.text != null) {
        yield response.text!;
      }
    }
  }

  Future<ResultResponse> searchPrompt(String prompt) async {
    try {
      debugPrint("STARTING QUERY: $prompt");

      final text = [
        Content.text('''
For this prompt, give me an itinerary for a trip in the following json format:
{
  "status": "success",
  "title": "Kyoto 5-Day Solo Trip",
  "startDate": "2025-04-10",
  "endDate": "2025-04-15",
  "days": [
    {
      "date": "2025-04-10",
      "summary": "Fushimi Inari & Gion",
      "items": [
        { 
          "time": "09:00",
          "activity": "Climb Fushimi Inari Shrine",
          "location": "34.9671,135.7727"
        },
        { 
          "time": "09:00",
          "activity": "Climb Fushimi Inari Shrine",
          "location": "34.9671,135.7727"
        },
        { 
          "time": "09:00",
          "activity": "Climb Fushimi Inari Shrine",
          "location": "34.9671,135.7727"
        },
      ]
    }
  ]
}

location string must be latitude and longitude in the format "lat,lng"

this is the prompt:
$prompt

set 'status' value to failure if given prompt is not related to generating an itinerary, or if there is any errors.

'''),
      ];

      final response = await model.generateContent(text);
      debugPrint("PROMPT RESPONSE: ${response.text}");

      final rawJson = response.text;
      Map<String, dynamic> parsedJson = {};
      if (rawJson != null) {
        final startIndex = rawJson.indexOf('{');
        final endIndex = rawJson.lastIndexOf('}') + 1;

        if (startIndex != -1 && endIndex != 0 && endIndex > startIndex) {
          parsedJson = jsonDecode(rawJson.substring(startIndex, endIndex));

          if (parsedJson['status'] == 'failure') {
            return ResultResponse(
              status: false,
              data: parsedJson,
            );
          }
          return ResultResponse(
            status: true,
            data: parsedJson,
            requestTokens: response.usageMetadata!.promptTokenCount!,
            responseTokens: response.usageMetadata!.candidatesTokenCount!,
          );
        }
      }
      return ResultResponse(status: false);
    } catch (e) {
      rethrow;
    }
  }
}
