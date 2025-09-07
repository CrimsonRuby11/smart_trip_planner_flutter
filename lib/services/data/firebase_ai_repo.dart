import 'dart:convert';
import 'dart:io';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_trip_planner_flutter/services/domain/genai_repo.dart';

enum ResultStatus {
  success,
  failure,
  unauthorized,
  rateLimitExceeded,
  networkError,
  jsonError,
}

class ResultResponse {
  final ResultStatus status;
  final dynamic data;
  final int requestTokens;
  final int responseTokens;

  ResultResponse({
    required this.status,
    this.requestTokens = 0, //
    this.responseTokens = 0,
    this.data,
  });
}

class StreamResponse {
  final String textChunk;
  final int? requestTokens;
  final int? responseTokens;
  final bool isFinal;

  StreamResponse({
    required this.textChunk,
    this.requestTokens,
    this.responseTokens,
    this.isFinal = false,
  });
}

/// Concrete implementation of [GenAiRepo] using the Firebase AI SDK (Gemini).
class FirebaseAiRepo extends GenAiRepo {
  final _model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-1.5-flash',
    tools: [Tool.googleSearch()],
  );

  @override
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

      final response = await _model.generateContent(text);
      debugPrint("PROMPT RESPONSE: ${response.text}");

      final rawJson = response.text;
      Map<String, dynamic> parsedJson = {};
      if (rawJson != null) {
        final startIndex = rawJson.indexOf('{');
        final endIndex = rawJson.lastIndexOf('}') + 1;

        if (startIndex != -1 && endIndex != 0 && endIndex > startIndex) {
          parsedJson = jsonDecode(rawJson.substring(startIndex, endIndex));

          if (parsedJson['status'] == 'failure') {
            return ResultResponse(status: ResultStatus.failure, data: parsedJson);
          }
          return ResultResponse(
            status: ResultStatus.success,
            data: parsedJson,
            requestTokens: response.usageMetadata!.promptTokenCount!,
            responseTokens: response.usageMetadata!.candidatesTokenCount!,
          );
        }
      }
      return ResultResponse(
        status: ResultStatus.jsonError,
        data: "Could not parse JSON from response.",
      );
    } on SocketException {
      return ResultResponse(
        status: ResultStatus.networkError,
        data: "No Internet connection",
      );
    } on FormatException {
      return ResultResponse(
        status: ResultStatus.jsonError,
        data: "Invalid JSON format received.",
      );
    } catch (e) {
      return ResultResponse(status: ResultStatus.failure, data: e.toString());
    }
  }

  @override
  Stream<StreamResponse> searchPromptStream(String prompt) async* {
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

    final responseStream = _model.generateContentStream(text);

    // The final response contains the usage metadata. We'll capture it here.
    GenerateContentResponse? finalResponse;

    await for (final response in responseStream) {
      finalResponse = response;
      if (response.text != null) {
        yield StreamResponse(textChunk: response.text!);
      }
    }

    // The last response chunk should have the usage metadata.
    if (finalResponse?.usageMetadata != null) {
      yield StreamResponse(
        textChunk: '', // No more text, just metadata
        isFinal: true,
        requestTokens: finalResponse!.usageMetadata!.promptTokenCount,
        responseTokens: finalResponse.usageMetadata!.candidatesTokenCount,
      );
    }
  }

  @override
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

      final response = await _model.generateContent(text);
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
              status: ResultStatus.failure,
              data: parsedJson,
            );
          }
          return ResultResponse(
            status: ResultStatus.success,
            data: parsedJson,
            requestTokens: response.usageMetadata!.promptTokenCount!,
            responseTokens: response.usageMetadata!.candidatesTokenCount!,
          );
        }
      }
      return ResultResponse(
        status: ResultStatus.jsonError,
        data: "Could not parse JSON from response.",
      );
    } on SocketException {
      return ResultResponse(
        status: ResultStatus.networkError,
        data: "No Internet connection",
      );
    } on FormatException {
      return ResultResponse(
        status: ResultStatus.jsonError,
        data: "Invalid JSON format received.",
      );
    } catch (e) {
      return ResultResponse(status: ResultStatus.failure, data: e.toString());
    }
  }
}
