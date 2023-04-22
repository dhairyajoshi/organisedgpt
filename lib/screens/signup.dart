// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organisedgpt/models/userModel.dart';
import 'package:organisedgpt/screens/anonlogin.dart';
import 'package:organisedgpt/screens/login.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/appbloc.dart';
import '../bloc/authbloc.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  TextEditingController name = TextEditingController(),
      email = TextEditingController(),
      uname = TextEditingController(),
      pass = TextEditingController(),
      token = TextEditingController(),
      cpass = TextEditingController();
  final _key = GlobalKey<FormState>();
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => AuthBloc()..add(AuthCheckEvent(context)),
        child: BlocBuilder<AuthBloc, AppState>(
          builder: (context, state) {
            if (state is InputApiState) {
              return Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                  color: Color.fromRGBO(52, 53, 65, 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Form(
                        key: _key,
                        autovalidateMode: _autovalidate,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'OrganisedGPT',
                              style: TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: TextFormField(
                                  controller: name,
                                  validator: (value) {
                                    if (value == "") {
                                      return 'name cannot be empty';
                                    }
                                    if (value.toString().length < 3) {
                                      return 'name too short!';
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Name',
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   height: 5,
                            // ),
                            SizedBox(
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: TextFormField(
                                  controller: email,
                                  validator: (value) {
                                    if (value == "") {
                                      return 'email cannot be empty';
                                    }
                                    if (!value.toString().isValidEmail()) {
                                      return 'email address not valid';
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Email',
                                  ),
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   height: 5,
                            // ),
                            SizedBox(
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: TextFormField(
                                  controller: uname,
                                  validator: (value) {
                                    if (value == "") {
                                      return 'username cannot be empty';
                                    }
                                    if (value.toString().length < 3) {
                                      return 'username too short!';
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'username',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: TextFormField(
                                  obscureText: true,
                                  controller: pass,
                                  validator: (value) {
                                    if (value == "") {
                                      return 'password cannot be empty';
                                    }
                                    if (value.toString().length < 6) {
                                      return 'Password too short!';
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'password',
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: TextFormField(
                                  obscureText: true,
                                  controller: cpass,
                                  validator: (value) {
                                    if (value != pass.text) {
                                      return 'passwords do not match';
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'confirm password',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 5),
                                child: TextFormField(
                                  controller: token,
                                  validator: (value) {
                                    if (value == "") {
                                      return 'token can not be empty';
                                    }
                                  },
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'OpenAI api key',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  BlocProvider.of<AuthBloc>(context).add(
                                      SignUpEvent(
                                          context,
                                          UserModel(name.text, email.text,
                                              uname.text, pass.text,token: token.text)));
                                },
                                child: Text('Sign up')),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Existing User?'),
                                TextButton(
                                  // onPressed: () {},
                                  onPressed: () => {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                (LoginScreen())))
                                  },
                                  child: Text('Login'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            launch('https://github.com/dhairyajoshi');
                          },
                          child: Text(
                            'Copyright ©Dhairya Joshi',
                            style: TextStyle(color: Colors.blue),
                          ))
                    ],
                  ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
