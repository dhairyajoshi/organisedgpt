// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_selectionarea/flutter_markdown.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/bloc/chatbloc.dart';
import 'package:organisedgpt/widgets/maincontent/chatcontent.dart';
import 'package:organisedgpt/widgets/sidebar/mobilechatsidebar.dart';
import 'package:organisedgpt/widgets/sidebar/mobileimagesidebar.dart';
import 'package:organisedgpt/widgets/sidebar/mobileupsidebar.dart';

import '../widgets/maincontent/imagecontent.dart';

class MobileChatScreen extends StatelessWidget {
  String response = "", search = "";
  bool sh = false;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(),
      child: Scaffold(
          appBar: AppBar(
            title: Text('OrganisedGPT'),
          ),
          drawer: BlocBuilder<ChatBloc, AppState>(
            builder: (context, state) {
              if (state is ChatLoadingState) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ImageGenerationState) {
                return Drawer(child: MobileImageSideBar(context, state));
              } else if (state is ChatLoadedState) {
                return Drawer(child: MobileChatSidebar(context, state));
              } else if (state is UnderProgressState) {
                return Drawer(child: MobileUPChatSidebar(context, state));
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          body: Container(
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
                        if (state is ImageGenerationState) {
                          return ImageContent(context, state);
                        }
                        if (state is ChatLoadedState) {
                          return ChatContent(context, state);
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
                        }
                        if (state is ImageGenerationState) {
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
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ))
              ],
            ),
            // color: Colors.blue,
          )),
    );
  }
}
