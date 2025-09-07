import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/controllers/hive_controller.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';
import 'package:smart_trip_planner_flutter/features/home/repo/result_repo.dart';

class ResultState {
  final Trip? trip;
  final String outputString;
  final bool readOnly;
  final int requestTokens;
  final int responseTokens;

  ResultState({
    this.trip,
    this.outputString = "",
    this.readOnly = false,
    this.requestTokens = 0,
    this.responseTokens = 0,
  });
}

class ResultLoading extends ResultState {}

class ResultLoaded extends ResultState {
  ResultLoaded({
    required super.trip,
    super.readOnly = false,
    super.outputString = "",
    required super.requestTokens,
    required super.responseTokens,
  });
}

class ResultStreaming extends ResultState {
  ResultStreaming({
    super.readOnly = false,
    super.outputString = "",
  });
}

class ResultError extends ResultState {
  final String message;
  ResultError({
    this.message = "An unknown error occurred.",
  });
}

class ResultCubit extends Cubit<ResultState> {
  ResultCubit() : super(ResultLoading());

  final resultRepo = ResultRepo();

  String resultString = "";
  int requestTokens = 0;
  int responseTokens = 0;

  String getTripString(Trip trip) {
    String resultString = "";

    for (int i = 0; i < trip.days.length; i++) {
      resultString += "Day ${i + 1}: ${trip.days[i].summary}\n";

      for (int j = 0; j < trip.days[i].items.length; j++) {
        resultString +=
            "  - ${trip.days[i].items[j].time} : ${trip.days[i].items[j].activity}\n";
      }

      resultString += "\n";
    }

    return resultString;
  }

  initResult(String prompt, Trip? trip) async {
    emit(ResultLoading());

    if (trip != null) {
      resultString = getTripString(trip);

      emit(
        ResultLoaded(
          trip: trip,
          outputString: resultString,
          readOnly: true,
          requestTokens: requestTokens,
          responseTokens: responseTokens,
        ),
      );
      return;
    }

    try {
      final responseStream = resultRepo.searchPromptStream(prompt);
      String fullResponse = "";

      await for (final streamedResponse in responseStream) {
        if (streamedResponse.isFinal) {
          debugPrint("Request Tokens: ${streamedResponse.requestTokens}");
          debugPrint("Response Tokens: ${streamedResponse.responseTokens}");
          requestTokens = streamedResponse.requestTokens!;
          responseTokens = streamedResponse.responseTokens!;
        }
        resultString += streamedResponse.textChunk;
        fullResponse += streamedResponse.textChunk;
        emit(ResultStreaming(outputString: resultString));
      }

      // JSON parsing logic from your original searchPrompt
      final rawJson = fullResponse;
      Map<String, dynamic> parsedJson = {};
      final startIndex = rawJson.indexOf('{');
      final endIndex = rawJson.lastIndexOf('}') + 1;

      if (startIndex != -1 && endIndex != 0 && endIndex > startIndex) {
        parsedJson = jsonDecode(rawJson.substring(startIndex, endIndex));

        if (parsedJson['status'] == 'failure') {
          emit(ResultError());
          return;
        }

        Trip currTrip = Trip.fromJson(parsedJson);
        emit(
          ResultLoaded(
            trip: currTrip,
            outputString: getTripString(currTrip),
            requestTokens: requestTokens,
            responseTokens: responseTokens,
          ),
        );
      } else {
        emit(ResultError());
      }
    } catch (e) {
      String errorMessage = "An error occurred during generation.";
      if (e is SocketException) {
        errorMessage = "Network error. Please check your connection.";
      } else if (e is FormatException) {
        errorMessage = "There was an issue with the server's response format.";
      } else {
        errorMessage = "An unexpected error occurred";
      }
      emit(ResultError(message: errorMessage));
    }
  }

  Future<ResultResponse> saveTrip(Trip trip) async {
    try {
      await HiveController.addData(trip);
      return ResultResponse(status: ResultStatus.success);
    } catch (e) {
      return ResultResponse(status: ResultStatus.failure, data: e.toString());
    }
  }
}
