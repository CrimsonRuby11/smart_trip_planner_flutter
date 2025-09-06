import 'package:firebase_auth/firebase_auth.dart';

class AuthResponse {
  final bool status;
  final dynamic data;
  final String? message;

  AuthResponse({
    required this.status,
    required this.data,
    this.message,
  });
}

class AuthRepo {
  final fireInstance = FirebaseAuth.instance;

  Future<AuthResponse> getCurrUser() async {
    if (fireInstance.currentUser == null) {
      return AuthResponse(status: false, data: null);
    } else {
      return AuthResponse(status: true, data: fireInstance.currentUser);
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResponse(status: true, data: response);
    } catch (e) {
      return AuthResponse(status: false, data: null, message: e.toString());
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> register(String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}
