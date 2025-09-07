import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_trip_planner_flutter/features/home/views/cubits/home_cubit.dart';
import 'package:smart_trip_planner_flutter/features/home/views/pages/result_page.dart';

class OfflineList extends StatelessWidget {
  const OfflineList({
    super.key,
    required this.controller,
    required this.state,
  });

  final TextEditingController controller;
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ListView.builder(
        physics: ScrollPhysics(),
        shrinkWrap: true,
        itemCount: state.history.length,
        itemBuilder: (context, index) {
          debugPrint(state.history.length.toString());
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ResultPage(trip: state.history[index]),
                ),
              );

              controller.clear();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color.fromARGB(94, 158, 158, 158),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    "assets/icons/greendot.svg",
                    width: 10,
                    height: 10,
                  ),
                  SizedBox(width: 10),
                  Text(state.history[index].title),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
