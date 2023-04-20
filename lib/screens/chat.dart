// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/bloc/chatbloc.dart';
import 'package:organisedgpt/screens/login.dart';
import 'package:organisedgpt/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

ChatBloc _chatBloc = ChatBloc();

class ChatScreen extends StatelessWidget {
  String response = "", search = "";
  bool sh = false;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: ((context) => _chatBloc),
        child: Container(
          color: Color.fromRGBO(52, 53, 65, 1),
          width: double.infinity,
          height: double.infinity,
          child: Row(
            children: [
              Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: BlocBuilder<ChatBloc, AppState>(
                    builder: (context, state) {
                      if (state is ChatLoadingState) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is ChatLoadedState) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 25, horizontal: 10),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(32, 33, 35, 1),
                              border: Border(
                                  right: BorderSide(
                                      width: 1, color: Colors.white))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preferences',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(SelectOptionEvent(0));
                                      },
                                      child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 15),
                                          decoration: BoxDecoration(
                                              color: state.op == 0
                                                  ? Color.fromARGB(
                                                      255, 95, 95, 95)
                                                  : Colors.transparent,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          child: Center(
                                            child: Text(
                                              'Normal Chat',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(SelectOptionEvent(1));
                                      },
                                      child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: state.op == 1
                                                  ? Color.fromARGB(
                                                      255, 95, 95, 95)
                                                  : Colors.transparent,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 15),
                                          child: Center(
                                            child: Text(
                                              'Unhinged',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(SelectOptionEvent(2));
                                      },
                                      child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: state.op == 2
                                                  ? Color.fromARGB(
                                                      255, 95, 95, 95)
                                                  : Colors.transparent,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 15),
                                          child: Center(
                                            child: Text(
                                              'Image',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(SelectOptionEvent(3));
                                      },
                                      child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: state.op == 3
                                                  ? Color.fromARGB(
                                                      255, 95, 95, 95)
                                                  : Colors.transparent,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 15),
                                          child: Center(
                                            child: Text(
                                              'Audio',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
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
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Icon(Icons.key)
                                  ],
                                ),
                                onTap: () {
                                  TextEditingController _kc =
                                      TextEditingController();
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
                                                final pref =
                                                    await SharedPreferences
                                                        .getInstance();
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
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
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
                                                final pref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                pref.remove('api');
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: ((context) =>
                                                            LoginScreen())));
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
                      } else if (state is UnderProgressState) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 25, horizontal: 10),
                          decoration: BoxDecoration(
                              color: Color.fromRGBO(32, 33, 35, 1),
                              border: Border(
                                  right: BorderSide(
                                      width: 1, color: Colors.white))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Preferences',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.6,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(SelectOptionEvent(0));
                                      },
                                      child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 15),
                                          decoration: BoxDecoration(
                                              color: state.op == 0
                                                  ? Color.fromARGB(
                                                      255, 95, 95, 95)
                                                  : Colors.transparent,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          child: Center(
                                            child: Text(
                                              'Normal Chat',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(SelectOptionEvent(1));
                                      },
                                      child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: state.op == 1
                                                  ? Color.fromARGB(
                                                      255, 95, 95, 95)
                                                  : Colors.transparent,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 15),
                                          child: Center(
                                            child: Text(
                                              'Unhinged',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(SelectOptionEvent(2));
                                      },
                                      child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: state.op == 2
                                                  ? Color.fromARGB(
                                                      255, 95, 95, 95)
                                                  : Colors.transparent,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 15),
                                          child: Center(
                                            child: Text(
                                              'Image',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(SelectOptionEvent(3));
                                      },
                                      child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              color: state.op == 3
                                                  ? Color.fromARGB(
                                                      255, 95, 95, 95)
                                                  : Colors.transparent,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.grey))),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 15),
                                          child: Center(
                                            child: Text(
                                              'Audio',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
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
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Icon(Icons.key)
                                  ],
                                ),
                                onTap: () {
                                  TextEditingController _kc =
                                      TextEditingController();
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
                                                final pref =
                                                    await SharedPreferences
                                                        .getInstance();
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
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
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
                                                final pref =
                                                    await SharedPreferences
                                                        .getInstance();
                                                pref.remove('api');
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: ((context) =>
                                                            LoginScreen())));
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
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  )),
              Flexible(
                  flex: 9,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    child: Column(
                      children: [
                        Flexible(
                            flex: 5,
                            fit: FlexFit.tight,
                            child: BlocBuilder<ChatBloc, AppState>(
                              builder: (context, state) {
                                if (state is ChatLoadingState) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (state is UnderProgressState) {
                                  return Center(
                                    child: Text('This is under progress'),
                                  );
                                }
                                if (state is ChatLoadedState) {
                                  return ListView.builder(
                                      itemCount: state.chats.length,
                                      reverse: true,
                                      itemBuilder: (context, idx) {
                                        final ridx =
                                            state.chats.length - 1 - idx;
                                        return Dialogue(
                                            ridx,
                                            state.chats[ridx]['u'],
                                            state.chats[ridx]['c'],
                                            state.chats[ridx]['t'],
                                            state.chats[ridx]['a'],
                                            context);
                                      });
                                }
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            )),
                        Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: BlocBuilder<ChatBloc, AppState>(
                              builder: (context, state) {
                                if (state is ChatLoadedState) {
                                  return Container(
                                    // color: Colors.white,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(children: [
                                      Flexible(
                                        flex: 6,
                                        child: TextField(
                                          controller: _controller,
                                          keyboardType: TextInputType.multiline,
                                          onChanged: ((value) =>
                                              search = value),
                                          onSubmitted: (val) {
                                            _controller.text = "";
                                            BlocProvider.of<ChatBloc>(context)
                                                .add(FetchResultEvent(search));
                                            search = "";
                                          },
                                        ),
                                      ),
                                      Flexible(
                                        flex: 1,
                                        child: IconButton(
                                          icon: Icon(Icons.send),
                                          onPressed: () {
                                            _controller.text = "";
                                            BlocProvider.of<ChatBloc>(context)
                                                .add(FetchResultEvent(search));
                                            search = "";
                                          },
                                        ),
                                      ),
                                    ]),
                                  );
                                } else
                                  return SizedBox.shrink();
                              },
                            ))
                      ],
                    ),
                    // color: Colors.blue,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class Dialogue extends StatelessWidget {
  Dialogue(this.i, this.u, this.text, this.t, this.a, this.ctx, {super.key});
  String text;
  int i, u, t, a;
  BuildContext ctx;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: u == 0
              ? Color.fromRGBO(52, 53, 65, 1)
              : Color.fromRGBO(68, 70, 84, 1),
          border: Border(
            bottom:
                BorderSide(width: 1, color: Color.fromARGB(255, 147, 147, 147)),
          )),
      // margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              u == 0
                  ? Text(
                      'User:',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    )
                  : Text('GPT:',
                      style:
                          TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  if (u == 0)
                    IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Are you sure?"),
                                content: Text(
                                    'This will delete all the following chats too'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel')),
                                  TextButton(
                                      onPressed: () {
                                        BlocProvider.of<ChatBloc>(ctx)
                                            .add(DeleteChatEvent(i));
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Confirm')),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.delete_outlined,
                          size: 17,
                        )),
                  if (u == 1 && a == 1)
                    IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Are you sure?"),
                                content: Text(
                                    'This will delete all the following chats too'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel')),
                                  TextButton(
                                      onPressed: () {
                                        BlocProvider.of<ChatBloc>(ctx)
                                            .add(RegenChatEvent(i));
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Confirm')),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.refresh,
                          size: 17,
                        )),
                ],
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          if (t == 1)
            Column(
              children: [
                Text("Here's your URL: ", style: TextStyle(fontSize: 18)),
                SizedBox(
                  height: 5,
                ),
                InkWell(
                  child: Text(text),
                  onTap: () async {
                    launch(text);
                    await WebImageDownloader.downloadImageFromWeb(text);
                    print('downloaded');
                  },
                )
              ],
            )
          else
            SelectableText(
              text.trim(),
              style: TextStyle(fontSize: 18),
            ),
        ],
      ),
    );
  }
}
