// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/bloc/chatbloc.dart';
import 'package:organisedgpt/services/database.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatelessWidget {
  String response = "", search = "";
  bool sh = false;
  TextEditingController _controller = TextEditingController();
  

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: ((context) => ChatBloc()),
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
                    if(state is ChatLoadingState){
                      return Center(child: CircularProgressIndicator(),); 
                    }
                    else if(state is ChatLoadedState) {
                      return Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 25, horizontal: 10),
                      decoration: BoxDecoration(
                          border: Border(
                              right:
                                  BorderSide(width: 1, color: Colors.white))),
                      child: Column(
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
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    BlocProvider.of<ChatBloc>(context).add(SelectOptionEvent(0));
                                  },
                                  child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 15),
                                      decoration: BoxDecoration(
                                        color: state.op==0?Color.fromARGB(255, 95, 95, 95):Colors.transparent,
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey))),
                                      child: Center(
                                        child: Text( 
                                          'Chat',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                ),
                                InkWell(
                                  onTap: () {
                                    BlocProvider.of<ChatBloc>(context).add(SelectOptionEvent(1));
                                  },
                                  child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: state.op==1?Color.fromARGB(255, 95, 95, 95):Colors.transparent,
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey))),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 15),
                                      child: Center(
                                        child: Text(
                                          'Completion',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                ),
                                InkWell(
                                  onTap: () {
                                    BlocProvider.of<ChatBloc>(context).add(SelectOptionEvent(2));
                                  },
                                  child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: state.op==2?Color.fromARGB(255, 95, 95, 95):Colors.transparent,
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
                                    BlocProvider.of<ChatBloc>(context).add(SelectOptionEvent(3));
                                  },
                                  child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: state.op==3?Color.fromARGB(255, 95, 95, 95):Colors.transparent, 
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
                          )
                        ],
                      ),
                      // color: Colors.green,
                    );
                    
                    }
                    else {
                      return Center(child: CircularProgressIndicator(),);
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
                              if (state is ChatLoadedState) {
                                return ListView.builder(
                                    itemCount: state.chats.length,
                                    reverse: true,
                                    itemBuilder: (context, idx) {
                                      final ridx = state.chats.length - 1 - idx;
                                      return Dialogue(
                                          state.chats[ridx]['u'],
                                          state.chats[ridx]['c'],
                                          state.chats[ridx]['t']);
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
                              return Container(
                                // color: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Row(children: [
                                  Flexible(
                                    flex: 6,
                                    child: TextField(
                                      controller: _controller,
                                      keyboardType: TextInputType.multiline,
                                      onChanged: ((value) => search = value),
                                      onSubmitted: (val) {
                                        _controller.text = "";
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(FetchResultEvent(search));
                                      },
                                    ),
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: IconButton(
                                      icon: Icon(Icons.send),
                                      onPressed: () {
                                        BlocProvider.of<ChatBloc>(context)
                                            .add(FetchResultEvent(search));
                                      },
                                    ),
                                  ),
                                ]),
                              );
                            },
                          ))
                    ],
                  ),
                  // color: Colors.blue,
                )),
          ],
        ),
      ),
    );
  }
}

class Dialogue extends StatelessWidget {
  Dialogue(this.u, this.text, this.t, {super.key});
  String text;
  int u, t;
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
          u == 0
              ? Text(
                  'User:',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                )
              : Text('GPT:',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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
                  onTap: () async{
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
