import 'package:hive/hive.dart';

part 'trip.g.dart';

@HiveType(typeId: 1)
class Trip {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String startDate;
  @HiveField(2)
  final String endDate;
  @HiveField(3)
  final List<Day> days;

  Trip({
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      title: json['title'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      days: (json['days'] as List<dynamic>).map((d) => Day.fromJson(d)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'days': days.map((day) => day.toJson()),
    };
  }
}

@HiveType(typeId: 2)
class Day {
  @HiveField(0)
  final String date;
  @HiveField(1)
  final String summary;
  @HiveField(2)
  final List<Item> items;

  Day({
    required this.date,
    required this.summary,
    required this.items,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      date: json['date'],
      items: ((json['items']) as List<dynamic>).map((i) => Item.fromJson(i)).toList(),
      summary: json["summary"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'items': items.map((i) => i.toJson()),
      'summary': summary,
    };
  }
}

@HiveType(typeId: 3)
class Item {
  @HiveField(0)
  final String time;
  @HiveField(1)
  final String activity;
  @HiveField(2)
  final String location;

  Item({
    required this.time,
    required this.activity,
    required this.location,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      time: json['time'],
      activity: json['activity'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'activity': activity,
      'location': location,
    };
  }
}
