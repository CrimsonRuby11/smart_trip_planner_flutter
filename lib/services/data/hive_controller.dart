import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';

class HiveController {
  static late Box<Trip> tripsBox;
  static List<Trip> trips = <Trip>[];

  static Future<void> init({String? path}) async {
    if (path == null) {
      await Hive.initFlutter();
    } else {
      Hive.init(path);
    }
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
    try {
      await tripsBox.add(trip);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loadData();
    }
  }

  static deleteData(int index) async {
    try {
      await tripsBox.delete(index);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loadData();
    }
  }
}
