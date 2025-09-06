import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';

class HiveController {
  static late Box<Trip> tripsBox;
  static List<Trip> trips = <Trip>[];

  static init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(ItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DayAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TripAdapter());
    }

    await Hive.openBox<Trip>("tripbox");
    tripsBox = Hive.box<Trip>("tripbox");
    debugPrint("$tripsBox");
    loadData();
  }

  static loadData() {
    trips = tripsBox.values.toList();
    debugPrint("$trips");
  }

  static addData(Trip trip) async {
    await tripsBox.add(trip);
    loadData();
  }

  static deleteData(int index) async {
    await tripsBox.delete(index);
    loadData();
  }
}
