import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_trip_planner_flutter/config/custom_theme.dart';
import 'package:smart_trip_planner_flutter/config/utils.dart';
import 'package:smart_trip_planner_flutter/features/auth/views/cubits/auth_cubit.dart';
import 'package:smart_trip_planner_flutter/features/auth/views/cubits/connectivity_cubit.dart';
import 'package:smart_trip_planner_flutter/features/auth/views/pages/offline_page.dart';
import 'package:smart_trip_planner_flutter/features/home/views/pages/home_page.dart';
import 'package:smart_trip_planner_flutter/features/profile/views/cubits/profile_cubit.dart';
import 'package:smart_trip_planner_flutter/firebase_options.dart';
import 'package:smart_trip_planner_flutter/services/data/hive_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Prefs.instance = await SharedPreferences.getInstance();

  await dotenv.load(fileName: ".env");
  Config.serpKey = dotenv.env['SERP_KEY']!;

  await HiveController.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ConnectivityCubit(), lazy: false),
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => ProfileCubit()..init(), lazy: false),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: CustomTheme.primary),
          fontFamily: "Helvetica",
          scaffoldBackgroundColor: CustomTheme.scaffoldBg,
          appBarTheme: AppBarTheme(
            backgroundColor: CustomTheme.scaffoldBg,
            elevation: 0,
          ),
        ),
        home: BlocBuilder<ConnectivityCubit, ConnectivityState>(
          builder: (context, state) {
            if (state is ConnectivityOnline) {
              return const MainApp(title: 'Itinera AI');
            } else if (state is ConnectivityOffline) {
              return const OfflinePage();
            }
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.title});

  final String title;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) => {},
      builder: (context, state) => state is Unauthenticated
          ? HomePage()
          : state is Authenticated
          ? HomePage()
          : Container(),
    );
  }
}
