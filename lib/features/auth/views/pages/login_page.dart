import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_trip_planner_flutter/config/custom_theme.dart';
import 'package:smart_trip_planner_flutter/features/auth/views/cubits/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final pass2controller = TextEditingController();

  bool isLogin = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) => {},
      builder: (context, state) => Scaffold(
        body: state is AuthLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const LoginTitle(),

                    Subtitles(),

                    SizedBox(height: 30),

                    textField("Email Address", emailController),

                    SizedBox(height: 10),

                    textField("Password", passwordController),

                    SizedBox(height: 10),

                    !isLogin
                        ? textField("Confirm Password", pass2controller)
                        : Container(),

                    SizedBox(height: 10),

                    GestureDetector(
                      onTap: () {
                        if (emailController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          return;
                        }

                        if (isLogin) {
                          context.read<AuthCubit>().login(
                            emailController.text,
                            passwordController.text,
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: CustomTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Center(
                          child: Text(
                            isLogin ? "Login" : "Register",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget textField(String title, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: TextStyle(fontSize: 15)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextField(
            obscureText: title == "Email Address" ? false : true,
            controller: controller,
            onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: Icon(
                title == "Email Address" ? Icons.email_outlined : Icons.lock_outline,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 18,
                horizontal: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Subtitles extends StatelessWidget {
  const Subtitles({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            "Create your Account",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Center(
          child: Text(
            "Let's get Started!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class LoginTitle extends StatelessWidget {
  const LoginTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/flight.svg",
            width: 35,
            height: 35,
          ),
          SizedBox(width: 10),
          Text(
            "Itinera AI",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: CustomTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
