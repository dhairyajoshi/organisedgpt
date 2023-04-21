// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/bloc/chatbloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../screens/login.dart';

class ChatSidebar extends StatelessWidget {
  BuildContext ctx;
  ChatLoadedState state;
  ChatSidebar(this.ctx, this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: MediaQuery.of(context).size.height*0.5,
      padding: EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      decoration: BoxDecoration(
          color: Color.fromRGBO(32, 33, 35, 1),
          border: Border(right: BorderSide(width: 1, color: Colors.white))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferences',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          Tooltip(
            message:
                'Improve the model\'s ability to comprehend conversation context and respond naturally',
            child: Row(
              children: [
                Text('Natural conversation: '),
                Checkbox(
                    activeColor: Colors.grey,
                    value: state.nc,
                    onChanged: (val) {
                      BlocProvider.of<ChatBloc>(context).add(SetNCEvent(val!));
                    })
              ],
            ),
          ),
          Text(
            'Temperature: ${state.temp}',
            style: TextStyle(fontSize: 15),
          ),
          Tooltip(
            message:
                'What sampling temperature to use, between 0 and 1. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.',
            child: Slider(
                min: 0,
                max: 1,
                divisions: 100,
                value: state.temp,
                onChanged: (val) {
                  BlocProvider.of<ChatBloc>(ctx).add(SetTempEvent(val));
                }),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            'Max length: ${state.maxlength.toInt()}',
            style: TextStyle(fontSize: 15),
          ),
          Tooltip(
            message:
                'The maximum number of tokens to generate in the completion.The token count of your prompt plus max_tokens cannot exceed the model\'s context length',
            child: Slider(
                min: 1,
                max: 4000,
                divisions: 800,
                value: state.maxlength,
                onChanged: (val) {
                  BlocProvider.of<ChatBloc>(ctx).add(SetLenEvent(val));
                }),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            width: double.infinity,
            child: ListView(
              // mainAxisAlignment:
              //     MainAxisAlignment.spaceEvenly,
              // crossAxisAlignment: CrossAxisAlignment.center,
              shrinkWrap: true,

              children: [
                InkWell(
                  onTap: () {
                    BlocProvider.of<ChatBloc>(ctx).add(SelectOptionEvent(0));
                  },
                  child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 15),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                          color: state.op == 0
                              ? Color.fromARGB(255, 95, 95, 95)
                              : Colors.transparent,
                          border:
                              Border(bottom: BorderSide(color: Colors.grey))),
                      child: Center(
                        child: Text(
                          'ChatGPT',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
                InkWell(
                  onTap: () {
                    BlocProvider.of<ChatBloc>(ctx).add(SelectOptionEvent(1));
                  },
                  child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          color: state.op == 1
                              ? Color.fromARGB(255, 95, 95, 95)
                              : Colors.transparent,
                          border:
                              Border(bottom: BorderSide(color: Colors.grey))),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Center(
                        child: Text(
                          'GPT-3',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
                InkWell(
                  onTap: () {
                    BlocProvider.of<ChatBloc>(ctx).add(SelectOptionEvent(2));
                  },
                  child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          color: state.op == 2
                              ? Color.fromARGB(255, 95, 95, 95)
                              : Colors.transparent,
                          border:
                              Border(bottom: BorderSide(color: Colors.grey))),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Center(
                        child: Text(
                          'Image',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
                InkWell(
                  onTap: () {
                    BlocProvider.of<ChatBloc>(ctx).add(SelectOptionEvent(3));
                  },
                  child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          color: state.op == 3
                              ? Color.fromARGB(255, 95, 95, 95)
                              : Colors.transparent,
                          border:
                              Border(bottom: BorderSide(color: Colors.grey))),
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Center(
                        child: Text(
                          'Audio',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
              ],
            ),
          ),
          InkWell(
            child: Row(
              children: [
                Text('Change your API key',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.key)
              ],
            ),
            onTap: () {
              TextEditingController _kc = TextEditingController();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Update your API key"),
                    content: TextField(
                      controller: _kc,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () async {
                            final pref = await SharedPreferences.getInstance();
                            pref.setString('api', _kc.text);
                            Navigator.of(context).pop();
                          },
                          child: Text('Confirm')),
                    ],
                  );
                  ;
                },
              );
            },
          ),
          SizedBox(
            height: 15,
          ),
          InkWell(
            child: Row(
              children: [
                Text('Remove your API key',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.delete_outline)
              ],
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Are you sure?"),
                    content: Text(
                        'This will delete all the conversations and log you out'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () async {
                            final pref = await SharedPreferences.getInstance();
                            pref.remove('api');
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => LoginScreen())));
                          },
                          child: Text('Confirm')),
                    ],
                  );
                  ;
                },
              );
            },
          ),
        ],
      ),
      // color: Colors.green,
    );
  }
}
