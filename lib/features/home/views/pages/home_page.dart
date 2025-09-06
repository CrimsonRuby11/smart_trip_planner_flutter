import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_trip_planner_flutter/config/custom_theme.dart';
import 'package:smart_trip_planner_flutter/config/utils.dart';
import 'package:smart_trip_planner_flutter/features/home/views/cubits/home_cubit.dart';
import 'package:smart_trip_planner_flutter/features/home/views/pages/result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..initHome(),
      child: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {},
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            actionsPadding: EdgeInsets.only(right: 20),
            actions: [
              profileIcon(),
            ],
            title: Text(
              "Hey! User 👋",
              style: TextStyle(
                color: CustomTheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    whatsUrVision(),

                    SizedBox(height: 20),

                    queryField(controller),

                    SizedBox(height: 20),

                    createTripButton(context.read<HomeCubit>()),

                    SizedBox(height: 20),

                    Center(
                      child: Text(
                        "Offline Saved Itineraries",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    state is HomeLoading
                        ? CircularProgressIndicator()
                        : Container(
                            height: 200,
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
                                        builder: (context) =>
                                            ResultPage(trip: state.history[index]),
                                      ),
                                    );
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
                                        Text("${state.history[index].title}"),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container profileIcon() {
    return Container(
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
    );
  }

  GestureDetector createTripButton(homeCubit) {
    return GestureDetector(
      onTap: () async {
        if (controller.text.isEmpty) {
          Utils.showSnackBar(context, "Prompt cannot be empty!");
          return;
        }

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ResultPage(prompt: controller.text),
          ),
        );

        homeCubit.reloadData();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: CustomTheme.primary,
        ),
        child: Center(
          child: Text(
            "Create my Itinerary!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  TextField queryField(TextEditingController controller) {
    return TextField(
      controller: controller,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      keyboardType: TextInputType.multiline,
      minLines: 5,
      maxLines: 8,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: CustomTheme.primary, width: 2),
        ),
        suffixIcon: Icon(
          Icons.mic,
          color: CustomTheme.primary,
        ),
      ),
    );
  }

  Padding whatsUrVision() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        "What's your vision for this trip?",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
