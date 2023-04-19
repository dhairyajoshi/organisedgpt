import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/screens/chat.dart';
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
              MaterialPageRoute(builder: ((context) => ChatScreen())));
        }
      },
    );

    on<AddApiEvent>(
      (event, emit) async {
        final pref = await SharedPreferences.getInstance();
        pref.setString('api', event.api);
        Navigator.of(event.context).pushReplacement(
            MaterialPageRoute(builder: ((context) => ChatScreen())));
      },
    );
  }
}
