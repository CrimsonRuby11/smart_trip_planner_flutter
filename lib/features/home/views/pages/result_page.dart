import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/config/custom_theme.dart';
import 'package:smart_trip_planner_flutter/config/utils.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';
import 'package:smart_trip_planner_flutter/features/home/views/cubits/result_cubit.dart';
import 'package:smart_trip_planner_flutter/features/home/views/pages/refine_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ResultPage extends StatefulWidget {
  final String prompt;
  final Trip? trip;

  const ResultPage({
    super.key,
    this.prompt = "",
    this.trip,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResultCubit()..initResult(widget.prompt, widget.trip),
      child: BlocConsumer<ResultCubit, ResultState>(
        listener: (context, state) {},
        builder: (context, state) => SafeArea(
          child: Scaffold(
            appBar: AppBar(
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarBrightness: Brightness.light,
                statusBarColor: Colors.transparent,
              ),
              title: Text(
                "Home",
                style: TextStyle(fontSize: 18),
              ),
              actionsPadding: EdgeInsets.only(right: 20),
              actions: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CustomTheme.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      "P",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    title(state),

                    SizedBox(height: 20),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(100),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(child: resultContent(state)),
                            state is ResultLoaded
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 20,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(98, 158, 158, 158),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Row(
                                      children: [
                                        mapsButton(state, context),
                                        Expanded(
                                          child: Text(
                                            " : ${state.trip!.title}",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),

                    followUpButton(state, widget.prompt),

                    SizedBox(height: 20),

                    state is ResultLoaded
                        ? saveOfflineButton(
                            context.read<ResultCubit>(),
                            state.readOnly,
                            state.trip!,
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector mapsButton(ResultState state, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        List latlng = state.trip!.days[0].items[0].location.split(",");
        double latitude = double.parse(latlng[0]);
        double longitude = double.parse(latlng[1]);

        Uri googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
        );

        if (await canLaunchUrl(googleMapsUrl)) {
          debugPrint("LAUNCHING MAPS: $googleMapsUrl");
          launchUrl(googleMapsUrl);
        } else {
          if (context.mounted) {
            Utils.showSnackBar(
              context,
              "Error launching Google maps",
            );
          }
        }
      },
      child: Row(
        children: [
          Icon(Icons.location_pin, color: Colors.red),
          Text(
            "Open in Maps",
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget resultContent(ResultState state) {
    return state is ResultLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Curating a perfect plan for you..."),
                SizedBox(height: 40),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(30),
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  state.outputString,
                ),
              ),
            ),
          );
  }

  GestureDetector saveOfflineButton(ResultCubit cubit, bool readOnly, Trip trip) {
    return GestureDetector(
      onTap: readOnly
          ? null
          : () async {
              final response = await cubit.saveTrip(trip);

              if (response.status && mounted) {
                Utils.showSnackBar(context, "Trip Saved!");
              } else {
                Utils.showSnackBar(context, "Error Occured! : ${response.data}");
              }
            },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.download_for_offline,
            color: readOnly ? Colors.grey : Colors.black,
          ),
          SizedBox(width: 10),
          Text(
            "Save Offline",
            style: TextStyle(
              fontSize: 18,
              color: readOnly ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector followUpButton(ResultState state, String prompt) {
    return GestureDetector(
      onTap: state.readOnly || state is ResultLoading
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RefinePage(prompt: prompt, trip: state.trip!),
                ),
              );
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: state is ResultLoading || state.readOnly
              ? CustomTheme.primaryDisabled
              : CustomTheme.primary,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              "Follow up to refine",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget title(ResultState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        state is ResultLoading ? "Creating Itinerary..." : "Itinerary Created!",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
