// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/bloc/authbloc.dart';
import 'package:organisedgpt/screens/login.dart';
import 'package:url_launcher/url_launcher.dart';

class AnonymousLoginScreen extends StatelessWidget {
  AnonymousLoginScreen({super.key});
  TextEditingController _controller = TextEditingController();
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
                padding: EdgeInsets.symmetric(vertical: 100, horizontal: 20),
                color: Color.fromRGBO(52, 53, 65, 1),
                child: Column(
                  children: [
                    Text(
                      'OrganisedGPT',
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      // color: Colors.white,
                      width: 500,
                      height: 60,
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Enter your OpenAI api key',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    InkWell(
                      child: Text(
                        'you can get your api key at: https://platform.openai.com/account/api-keys',
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () => launch(
                          'https://platform.openai.com/account/api-keys'),
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    TextButton(
                        onPressed: () {
                          BlocProvider.of<AuthBloc>(context)
                              .add(AddApiEvent(context, _controller.text));
                        },
                        child: Text('Continue')),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Existing User?'),
                        TextButton(
                          // onPressed: () {},
                          onPressed: () => {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => (LoginScreen())))
                          },
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                    // Container(
                    //   // color: Colors.white,
                    //   width: 250,
                    //   height: 40,
                    //   child: TextField(
                    //     obscureText: true,
                    //     decoration: InputDecoration(
                    //       hintText: 'Password',
                    //       border:
                    //           OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            } else
              return Center(
                child: CircularProgressIndicator(),
              );
          },
        ),
      ),
    );
  }
}
