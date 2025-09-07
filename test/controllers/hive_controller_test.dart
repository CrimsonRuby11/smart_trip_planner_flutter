import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_trip_planner_flutter/controllers/hive_controller.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';

void main() {
  late Directory tempDir;

  // This setup runs once before all tests in the file.
  setUpAll(() {
    // Use a temporary directory for testing to avoid conflicts.
    print("Hello there");
    tempDir = Directory.systemTemp.createTempSync();

    // The static init() method registers adapters, but we must ensure
    // they are registered for the test environment before the first call.
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(TripAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(DayAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ItemAdapter());
  });

  // This runs after each test, which is crucial for static classes.
  tearDown(() async {
    // Deletes all boxes from disk to reset the state.
    await Hive.deleteFromDisk();
  });

  group('HiveController (Static)', () {
    test('init should open the box and load initial data', () async {
      // Act: Initialize the controller with the test path.
      await HiveController.init(path: tempDir.path);

      // Assert: Check that the box is open and the initial list is empty.
      expect(Hive.isBoxOpen('tripbox'), isTrue);
      expect(HiveController.trips, isEmpty);
    });

    test('addData should add a trip and loadData should reflect the change', () async {
      // Arrange
      await HiveController.init(path: tempDir.path);
      final trip = Trip(
        title: 'Static Test Trip',
        days: [],
        startDate: '2024-01-01',
        endDate: '2024-01-05',
      );

      // Act
      await HiveController.addData(trip);

      // Assert
      expect(HiveController.trips.length, 1);
      expect(HiveController.trips.first.title, 'Static Test Trip');
    });

    test('deleteData should remove a trip from the box', () async {
      // Arrange
      await HiveController.init(path: tempDir.path);
      final trip1 = Trip(
        title: 'Trip 1',
        days: [],
        startDate: '2024-01-01',
        endDate: '2024-01-05',
      );
      final trip2 = Trip(
        title: 'Trip 2',
        days: [],
        startDate: '2024-02-01',
        endDate: '2024-02-05',
      );

      // Add two trips. The keys will be 0 and 1.
      await HiveController.addData(trip1);
      await HiveController.addData(trip2);

      // Pre-condition check
      expect(HiveController.trips.length, 2);

      // Act: Delete the first trip at index/key 0.
      // Note: Your deleteData takes an int index, which matches the auto-increment key.
      await HiveController.deleteData(0);

      // Assert: The list should now contain only the second trip.
      expect(HiveController.trips.length, 1);
      expect(HiveController.trips.first.title, 'Trip 2');
    });
  });
}
