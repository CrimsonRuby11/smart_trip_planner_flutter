import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/controllers/hive_controller.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';
import 'package:smart_trip_planner_flutter/features/home/repo/result_repo.dart';

class ResultState {
  final Trip? trip;
  final String outputString;
  final bool readOnly;

  ResultState({
    this.trip,
    this.outputString = "",
    this.readOnly = false,
  });
}

class ResultLoading extends ResultState {}

class ResultLoaded extends ResultState {
  ResultLoaded({
    required super.trip,
    super.readOnly = false,
    super.outputString = "",
  });
}

class ResultError extends ResultState {}

class ResultResponse {
  final bool status;
  final dynamic data;

  ResultResponse({
    required this.status,
    this.data,
  });
}

class ResultCubit extends Cubit<ResultState> {
  ResultCubit() : super(ResultLoading());

  final resultRepo = ResultRepo();

  String resultString = "";

  initResult(String prompt, Trip? trip) async {
    emit(ResultLoading());

    if (trip != null) {
      Trip currTrip = trip;
      resultString = "";

      for (int i = 0; i < currTrip.days.length; i++) {
        resultString += "Day ${i + 1}: ${currTrip.days[i].summary}\n";

        for (int j = 0; j < currTrip.days[i].items.length; j++) {
          resultString +=
              "  - ${currTrip.days[i].items[j].time} : ${currTrip.days[i].items[j].activity}\n";
        }
      }
      emit(
        ResultLoaded(
          trip: trip,
          outputString: resultString,
          readOnly: true,
        ),
      );
      return;
    }

    final response = await resultRepo.searchPrompt(prompt);

    if (!response.status) {
      emit(ResultError());
      return;
    }

    Trip currTrip = Trip.fromJson(response.data);

    resultString = "";

    for (int i = 0; i < currTrip.days.length; i++) {
      resultString += "Day ${i + 1}: ${currTrip.days[i].summary}\n";

      for (int j = 0; j < currTrip.days[i].items.length; j++) {
        resultString +=
            "  - ${currTrip.days[i].items[j].time} : ${currTrip.days[i].items[j].activity}\n";
      }
    }

    emit(ResultLoaded(trip: currTrip, outputString: resultString));
  }

  Future<ResultResponse> saveTrip(Trip trip) async {
    try {
      await HiveController.addData(trip);
      return ResultResponse(status: true);
    } catch (e) {
      return ResultResponse(status: false, data: e.toString());
    }
  }
}
