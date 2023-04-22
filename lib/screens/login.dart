import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organisedgpt/bloc/authbloc.dart';
import 'package:organisedgpt/models/userModel.dart';
import 'package:organisedgpt/screens/anonlogin.dart';
import 'package:organisedgpt/screens/signup.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/appbloc.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  TextEditingController name = TextEditingController(),
      email = TextEditingController(),
      uname = TextEditingController(),
      pass = TextEditingController(),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                  color: const Color.fromRGBO(52, 53, 65, 1),
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
                            const Text(
                              'OrganisedGPT',
                              style: TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
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
                            const SizedBox(
                              height: 25,
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  BlocProvider.of<AuthBloc>(context).add(
                                      LoginEvent(
                                          context, uname.text, pass.text));
                                },
                                child: const Text('Login')),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('New User?'),
                                TextButton(
                                  // onPressed: () {},
                                  onPressed: () => {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                (SignUpScreen())))
                                  },
                                  child: const Text('Sign Up'),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  // onPressed: () {},
                                  onPressed: () => {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                (AnonymousLoginScreen())))
                                  },
                                  child: const Text('Continue privately'),
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
                          child: const Text(
                            'Copyright ©Dhairya Joshi',
                            style: TextStyle(color: Colors.blue),
                          ))
                    ],
                  ));
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
