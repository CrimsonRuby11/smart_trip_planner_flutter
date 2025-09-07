import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:smart_trip_planner_flutter/config/custom_theme.dart';
import 'package:smart_trip_planner_flutter/config/utils.dart';
import 'package:smart_trip_planner_flutter/features/home/models/trip.dart';
import 'package:smart_trip_planner_flutter/features/home/repo/result_repo.dart';
import 'package:smart_trip_planner_flutter/features/home/views/cubits/refine_cubit.dart';
import 'package:smart_trip_planner_flutter/features/profile/views/cubits/profile_cubit.dart';
import 'package:smart_trip_planner_flutter/features/profile/views/profile_page.dart';

class RefinePage extends StatefulWidget {
  final Trip trip;
  final String prompt;
  final int requestTokens;
  final int responseTokens;

  const RefinePage({
    super.key,
    required this.trip,
    required this.prompt,
    required this.requestTokens,
    required this.responseTokens,
  });

  @override
  State<RefinePage> createState() => _RefinePageState();
}

class _RefinePageState extends State<RefinePage> {
  Widget profileIcon(double size) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfilePage(),
          ),
        );
      },
      child: Container(
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
      create: (context) => RefineCubit()
        ..initRefine(
          widget.prompt,
          widget.trip,
          widget.requestTokens,
          widget.responseTokens,
        ),
      child: BlocConsumer<RefineCubit, RefineState>(
        listener: (context, state) {
          if (state is RefineLoaded && state.chatStrings.length > 1) {
            context.read<ProfileCubit>().updateValues(
              state.requestTokens[state.chatStrings.length - 1] ?? 0,
              state.responseTokens[state.chatStrings.length - 1] ?? 0,
            );
          }
        },
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            actionsPadding: EdgeInsets.only(right: 20),
            actions: [
              profileIcon(40),
            ],
            title: Text(
              state.tripHistory[0]!.title,
            ),
          ),
          body: state is RefineInit
              ? Center(child: CircularProgressIndicator())
              : SafeArea(
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
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 10),

                                          Text(
                                            state.chatStrings[index],
                                          ),

                                          const SizedBox(height: 10),

                                          index % 2 == 0
                                              ? GestureDetector(
                                                  child: SizedBox(
                                                    height: 30,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.end,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.end,
                                                          children: [
                                                            Text(
                                                              "Request tokens: ${state.requestTokens[index]}",
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors.grey,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Response tokens: ${state.responseTokens[index]}",
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                color: Colors.grey,
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        const SizedBox(width: 10),

                                                        const SizedBox(width: 10),

                                                        GestureDetector(
                                                          onTap: () async {
                                                            final response = await context
                                                                .read<RefineCubit>()
                                                                .saveTrip(
                                                                  state
                                                                      .tripHistory[index]!,
                                                                );

                                                            if (!context.mounted) return;
                                                            if (response.status ==
                                                                ResultStatus.success) {
                                                              Utils.showSnackBar(
                                                                context,
                                                                "Trip Saved!",
                                                              );
                                                            } else {
                                                              Utils.showSnackBar(
                                                                context,
                                                                "Error Occured! : ${response.data}",
                                                              );
                                                            }
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.download,
                                                                color: Colors.grey,
                                                              ),
                                                              const SizedBox(width: 5),
                                                              Text(
                                                                "Save offline",
                                                                style: TextStyle(
                                                                  color: Colors.grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(),
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
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 10),

                                            Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    state is RefineLoading
                                                        ? "Thinking"
                                                        : (state as RefineError).message,
                                                    style: TextStyle(
                                                      color: state is RefineError
                                                          ? Colors.red
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                  SizedBox(width: 10),
                                                  state is RefineLoading
                                                      ? JumpingDots(
                                                          color: Colors.black,
                                                          numberOfDots: 3,
                                                          radius: 5,
                                                          animationDuration: Duration(
                                                            milliseconds: 200,
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
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
                                  enabled: state is RefineError ? false : true,
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
