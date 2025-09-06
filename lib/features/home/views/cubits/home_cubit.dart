import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/controllers/hive_controller.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';

class HomeState {
  final List<Trip> history;

  HomeState({
    this.history = const [],
  });
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  HomeLoaded({
    required super.history,
  });
}

class HomeError extends HomeState {}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeLoading());

  late List<Trip> trips;

  toggleLoading(bool b) {
    if (b) {
      emit(HomeLoading());
    } else {
      emit(HomeLoaded(history: trips));
    }
  }

  initHome() async {
    emit(HomeLoading());

    HiveController.init();
    trips = HiveController.trips;

    emit(HomeLoaded(history: trips));
  }

  reloadData() async {
    emit(HomeLoading());

    await HiveController.loadData();
    trips = HiveController.trips;

    emit(HomeLoaded(history: trips));
  }
}
