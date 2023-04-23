// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/chatbloc.dart';
import '../../bloc/events/chatevents.dart';

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
                  },
                )
              ],
            )
          else
            Container(
                alignment: Alignment.topLeft,
                width: double.infinity,
                child: SelectionArea(
                    child: MarkdownBody(
                  data: text.trim(),
                  styleSheet: MarkdownStyleSheet(
                      textScaleFactor: 1.3, textAlign: WrapAlignment.start),
                ))),
        ],
      ),
    );
  }
}
