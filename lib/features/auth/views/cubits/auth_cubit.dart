import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_trip_planner_flutter/features/auth/repos/auth_repo.dart';

class AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  String message;

  AuthError({this.message = "Error Occured!"});
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(Unauthenticated());

  AuthRepo authRepo = AuthRepo();

  initAuth() async {
    // emit(AuthLoading());

    emit(Unauthenticated());

    // final fireUser = await authRepo.getCurrUser();

    // if (fireUser.status) {
    //   emit(Authenticated());
    // } else {
    //   emit(Unauthenticated());
    // }
  }

  login(String email, String pass) async {
    emit(AuthLoading());

    final response = await authRepo.login(email, pass);
    if (response.status) {
      emit(Authenticated());
    } else {
      emit(AuthError(message: response.message ?? "Error Occured!"));
    }
  }
}
