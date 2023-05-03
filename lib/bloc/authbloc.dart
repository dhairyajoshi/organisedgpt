// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/models/userModel.dart';
import 'package:organisedgpt/screens/chat.dart';
import 'package:organisedgpt/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckAuthState extends AppState {}

class InputApiState extends AppState {}

class AuthCheckEvent extends AppEvent {
  BuildContext context;
  AuthCheckEvent(this.context);
}

class AddApiEvent extends AppEvent {
  BuildContext context;
  String api;
  AddApiEvent(this.context, this.api);
}

class SignUpEvent extends AppEvent {
  UserModel user;
  BuildContext context;
  SignUpEvent(this.context, this.user);
}

class LoginEvent extends AppEvent {
  String uname, pass;
  BuildContext context;
  LoginEvent(this.context, this.uname, this.pass);
}

class AuthBloc extends Bloc<AppEvent, AppState> {
  AuthBloc() : super(CheckAuthState()) {
    on<AuthCheckEvent>(
      (event, emit) async {
        final pref = await SharedPreferences.getInstance();
        final key = pref.getString('api');
        if (key == null) {
          emit(InputApiState());
        } else {
          Navigator.of(event.context).pushReplacement(
              MaterialPageRoute(builder: ((context) => const ChatScreen())));
        }
      },
    );

    on<AddApiEvent>(
      (event, emit) async {
        final pref = await SharedPreferences.getInstance();
        pref.setString('api', event.api);
        Navigator.of(event.context).pushReplacement(
            MaterialPageRoute(builder: ((context) => const ChatScreen())));
      },
    );

    on<SignUpEvent>(
      (event, emit) async {
        emit(CheckAuthState());
        final res = await DatabaseService().signUp(event.user);
        if (res) {
          Navigator.of(event.context).pushReplacement(
              MaterialPageRoute(builder: ((context) => const ChatScreen())));
        }
        emit(InputApiState());
      },
    );

    on<LoginEvent>(
      (event, emit) async {
        emit(CheckAuthState());
        final res = await DatabaseService().login(event.uname, event.pass);
        if (res) {
          Navigator.of(event.context).pushReplacement(
              MaterialPageRoute(builder: ((context) => const ChatScreen())));
        }
        emit(InputApiState());
      },
    );
  }
}
