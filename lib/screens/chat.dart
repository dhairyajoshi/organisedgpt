// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/bloc/chatbloc.dart';
import 'package:organisedgpt/widgets/maincontent/chatcontent.dart';
import 'package:organisedgpt/widgets/maincontent/imagecontent.dart';

import '../widgets/sidebar/chatsidebar.dart';
import '../widgets/sidebar/imagesidebar.dart';
import '../widgets/sidebar/underprogresssidebar.dart';

ChatBloc _chatBloc = ChatBloc();

class ChatScreen extends StatelessWidget {
  String response = "", search = "";
  bool sh = false;
  TextEditingController _controller = TextEditingController();
  double temp = 0;
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
                  flex: 3,
                  fit: FlexFit.tight,
                  child: BlocBuilder<ChatBloc, AppState>(
                    builder: (context, state) {
                      if (state is ChatLoadingState) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is ChatLoadedState) {
                        return ChatSidebar(context, state);
                      } else if (state is ImageGenerationState) {
                        return ImageSideBar(context, state);
                      } else if (state is UnderProgressState) {
                        return UPChatSidebar(context, state);
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  )),
              Flexible(
                  flex: 11,
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
                                if (state is ImageGenerationState) {
                                  return ImageContent(context, state);
                                }
                                if (state is ChatLoadedState) {
                                  return ChatContent(context, state);
                                }
                                return SizedBox.shrink();
                              },
                            )),
                        Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: BlocBuilder<ChatBloc, AppState>(
                              builder: (context, state) {
                                if (state is ChatLoadedState &&
                                    ((state.sc &&
                                        state.selectedDropdown != null) || !state.sc)) {
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
                                          onChanged: ((value) {
                                            search = value;
                                            BlocProvider.of<ChatBloc>(context)
                                                .add(SetTokenEvent(
                                                    value.length));
                                          }),
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
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.send),
                                              onPressed: () {
                                                _controller.text = "";
                                                BlocProvider.of<ChatBloc>(
                                                        context)
                                                    .add(FetchResultEvent(
                                                        search));
                                                search = "";
                                              },
                                            ),
                                            Text(
                                              state.tc.toString(),
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: state.tc +
                                                              state.maxlength >
                                                          4000
                                                      ? Colors.red
                                                      : Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]),
                                  );
                                }
                                if (state is ImageGenerationState) {
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
                                } else {
                                  return SizedBox.shrink();
                                }
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
