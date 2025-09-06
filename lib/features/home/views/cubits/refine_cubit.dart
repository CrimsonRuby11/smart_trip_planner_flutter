import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';
import 'package:smart_trip_planner_flutter/features/home/repo/result_repo.dart';

class RefineState {
  final List<String> chatStrings;
  final List<Trip> tripHistory;

  RefineState({
    this.chatStrings = const [],
    this.tripHistory = const [],
  });
}

class RefineLoading extends RefineState {
  RefineLoading({
    super.chatStrings = const [],
    super.tripHistory = const [],
  });
}

class RefineLoaded extends RefineState {
  RefineLoaded({
    super.chatStrings = const [],
    super.tripHistory = const [],
  });
}

class RefineError extends RefineState {
  RefineError({
    super.chatStrings = const [],
    super.tripHistory = const [],
  });
}

class RefineCubit extends Cubit<RefineState> {
  RefineCubit() : super(RefineLoading());

  final repo = ResultRepo();

  String prompt = "";
  String tripString = "";

  List<Trip> chatHistory = [];
  List<String> chatStrings = [];

  initRefine(String prompt, Trip trip) async {
    emit(RefineLoading());

    debugPrint("$prompt, $trip");

    chatHistory = [];
    chatHistory.add(trip);
    this.prompt = prompt;
    tripString = getTripString(trip);
    chatStrings = [tripString];

    debugPrint("$chatStrings");

    emit(RefineLoaded(chatStrings: chatStrings, tripHistory: chatHistory));
  }

  String getTripString(Trip trip) {
    String resultString = "";

    for (int i = 0; i < trip.days.length; i++) {
      resultString += "Day ${i + 1}: ${trip.days[i].summary}\n";

      for (int j = 0; j < trip.days[i].items.length; j++) {
        resultString +=
            "  - ${trip.days[i].items[j].time} : ${trip.days[i].items[j].activity}\n";
      }
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
      if (response.status) {
        chatHistory.add(Trip.fromJson(response.data));
        chatStrings.add(getTripString(chatHistory.last));
        emit(RefineLoaded(chatStrings: chatStrings, tripHistory: chatHistory));
      } else {
        emit(RefineError(chatStrings: chatStrings, tripHistory: chatHistory));
      }
    } catch (e) {
      emit(RefineError(chatStrings: chatStrings, tripHistory: chatHistory));
    }
  }
}
