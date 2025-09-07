import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/config/custom_theme.dart';
import 'package:smart_trip_planner_flutter/config/utils.dart';
import 'package:smart_trip_planner_flutter/features/home/views/cubits/home_cubit.dart';
import 'package:smart_trip_planner_flutter/features/home/views/pages/components/offline_list.dart';
import 'package:smart_trip_planner_flutter/features/home/views/pages/components/profile_icon.dart';
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
              ProfileIcon(context: context),
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
                        : OfflineList(controller: controller, state: state),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createTripButton(homeCubit) {
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

        controller.clear();
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
