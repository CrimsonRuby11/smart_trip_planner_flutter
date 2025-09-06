import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/config/custom_theme.dart';
import 'package:smart_trip_planner_flutter/config/utils.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';
import 'package:smart_trip_planner_flutter/features/home/views/cubits/refine_cubit.dart';

class RefinePage extends StatefulWidget {
  final Trip trip;
  final String prompt;

  const RefinePage({
    super.key,
    required this.trip,
    required this.prompt,
  });

  @override
  State<RefinePage> createState() => _RefinePageState();
}

class _RefinePageState extends State<RefinePage> {
  Container profileIcon(double size) {
    return Container(
      width: size,
      height: size,
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

  Container aiIcon() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 162, 97, 0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Icon(
          Icons.message_rounded,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
  }

  final controller = TextEditingController();
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RefineCubit()..initRefine(widget.prompt, widget.trip),
      child: BlocConsumer<RefineCubit, RefineState>(
        listener: (context, state) => {},
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            actionsPadding: EdgeInsets.only(right: 20),
            actions: [
              profileIcon(40),
            ],
            title: Text(
              state.tripHistory[0].title,
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: state.chatStrings.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
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
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Profile icon
                                    Row(
                                      children: [
                                        index % 2 == 1 ? profileIcon(30) : aiIcon(),
                                        SizedBox(width: 10),
                                        Text(
                                          index % 2 == 1 ? "You" : "Itinera AI",
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 10),

                                    Text(
                                      state.chatStrings[index],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          state is RefineLoading || state is RefineError
                              ? Container(
                                  padding: const EdgeInsets.all(15),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
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
                                    children: [
                                      // Profile icon
                                      Row(
                                        children: [
                                          aiIcon(),
                                          SizedBox(width: 10),
                                          Text(
                                            "Itinera AI",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),

                                      SizedBox(height: 10),

                                      Center(
                                        child: Text(
                                          state is RefineLoading
                                              ? "Thinking..."
                                              : "An Error Occured!",
                                          style: TextStyle(
                                            color: state is RefineError
                                                ? Colors.red
                                                : Colors.black,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  ),

                  // Chat
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            textAlignVertical: TextAlignVertical.center,
                            onTapOutside: (t) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: CustomTheme.primary,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              hintText: "Follow up to refine",
                            ),
                          ),
                        ),

                        SizedBox(width: 20),

                        // Send button
                        GestureDetector(
                          onTap: state is RefineError
                              ? null
                              : () async {
                                  if (controller.text.isEmpty) {
                                    Utils.showSnackBar(
                                      context,
                                      "Prompt cannot be empty!",
                                    );
                                    return;
                                  }

                                  String inputText = controller.text;
                                  controller.clear();

                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    scrollController.animateTo(
                                      scrollController.position.maxScrollExtent,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  });

                                  await context.read<RefineCubit>().startRefine(
                                    inputText,
                                  );

                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    scrollController.animateTo(
                                      scrollController.position.maxScrollExtent,
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                                  });
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              color: CustomTheme.primary,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
