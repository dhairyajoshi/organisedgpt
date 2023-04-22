import 'package:flutter/material.dart';
import 'package:organisedgpt/screens/chat.dart';
import 'package:organisedgpt/screens/anonlogin.dart';
import 'package:organisedgpt/screens/login.dart';
import 'package:organisedgpt/screens/signup.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrganisedGPT',
      theme: ThemeData.dark(),
      home: LoginScreen(),
    );
  }
}
