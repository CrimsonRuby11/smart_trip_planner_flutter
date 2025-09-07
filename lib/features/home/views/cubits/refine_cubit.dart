import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/controllers/hive_controller.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';
import 'package:smart_trip_planner_flutter/features/home/repo/result_repo.dart';

class RefineState {
  final List<String> chatStrings;
  final Map<int, Trip> tripHistory;
  final Map<int, int> requestTokens;
  final Map<int, int> responseTokens;

  RefineState({
    this.chatStrings = const [],
    this.tripHistory = const {},
    this.requestTokens = const {},
    this.responseTokens = const {},
  });
}

class RefineLoading extends RefineState {
  RefineLoading({
    super.chatStrings = const [],
    super.tripHistory = const {},
  });
}

class RefineLoaded extends RefineState {
  RefineLoaded({
    super.chatStrings = const [],
    super.tripHistory = const {},
    super.requestTokens = const {},
    super.responseTokens = const {},
  });
}

class RefineError extends RefineState {
  final String message;
  RefineError({
    this.message = "An unknown error occurred.",
    super.chatStrings = const [],
    super.tripHistory = const {},
  });
}

class RefineInit extends RefineState {}

class RefineCubit extends Cubit<RefineState> {
  RefineCubit() : super(RefineInit());

  final repo = ResultRepo();

  String prompt = "";
  String tripString = "";

  Map<int, Trip> chatHistory = {};
  List<String> chatStrings = [];
  Map<int, int> requestTokens = {};
  Map<int, int> responseTokens = {};

  initRefine(String prompt, Trip trip, int requestTokens, int responseTokens) async {
    emit(RefineInit());

    debugPrint("$prompt, $trip");

    chatHistory = {};
    chatHistory[0] = trip;
    this.prompt = prompt;
    tripString = getTripString(trip);
    chatStrings = [tripString];
    this.requestTokens[0] = requestTokens;
    this.responseTokens[0] = responseTokens;

    debugPrint("$chatStrings");

    emit(
      RefineLoaded(
        chatStrings: chatStrings,
        tripHistory: chatHistory,
        requestTokens: this.requestTokens,
        responseTokens: this.responseTokens,
      ),
    );
  }

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

  Future<void> startRefine(String prompt) async {
    try {
      // add prompt card
      String lastTripString = chatStrings.last;
      chatStrings.add(prompt);
      emit(RefineLoading(chatStrings: chatStrings, tripHistory: chatHistory));

      // start prompt with ai
      final response = await repo.refinePrompt(lastTripString, prompt);
      if (response.status == ResultStatus.success) {
        Trip t = Trip.fromJson(response.data);
        chatHistory[chatStrings.length] = t;
        requestTokens[chatStrings.length] = response.requestTokens;
        responseTokens[chatStrings.length] = response.responseTokens;
        chatStrings.add(getTripString(t));
        emit(
          RefineLoaded(
            chatStrings: chatStrings,
            tripHistory: chatHistory,
            requestTokens: requestTokens,
            responseTokens: responseTokens,
          ),
        );
      } else {
        String errorMessage = "An error occurred.";
        switch (response.status) {
          case ResultStatus.networkError:
            errorMessage = "Network error. Please check your connection.";
            break;
          case ResultStatus.unauthorized:
            errorMessage = "Authentication failed. Please log in again.";
            break;
          case ResultStatus.rateLimitExceeded:
            errorMessage = "You've made too many requests. Please try again later.";
            break;
          case ResultStatus.jsonError:
            errorMessage = "There was an issue with the server's response.";
            break;
          default:
            errorMessage = "Failed to process prompt";
        }
        emit(
          RefineError(
            chatStrings: chatStrings,
            tripHistory: chatHistory,
            message: errorMessage,
          ),
        );
      }
    } catch (e) {
      emit(
        RefineError(
          chatStrings: chatStrings,
          tripHistory: chatHistory,
          message: e.toString(),
        ),
      );
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
