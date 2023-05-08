//ignore_for_file: prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/models/conversation.dart';
import 'package:organisedgpt/services/database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'events/chatevents.dart';
import 'states/chatstates.dart';

class ChatBloc extends Bloc<AppEvent, AppState> {
  final List<List<Message>> defallMessages = [
    [Message(1, 'Ask any question...', 0, 0)],
    [Message(1, 'Start with any phrase...', 0, 0)],
    [Message(1, 'Give any description...', 0, 0)],
    [Message(1, 'Upload an audio...', 0, 0)]
  ];
  List<List<Message>> allMessages = [
    [Message(1, 'Ask any question...', 0, 0)],
    [Message(1, 'Start with any phrase...', 0, 0)],
    [Message(1, 'Give any description...', 0, 0)],
    [Message(1, 'Upload an audio...', 0, 0)]
  ];

  int op = 0, sz = 0, tc = 0;
  double temp = 0.7, maxlength = 300, n = 1;
  bool nc = true, sc = false, sfx = false;
  List<ChatModel> chats = [];
  List<DropdownMenuItem<int>> dropitems = [];
  int? selectedDropdown;
  bool prefset = false;
  String suffix = "";
  TextEditingController sController = TextEditingController();

  ChatBloc()
      : super(ChatLoadedState(
            [],
            null,
            [],
            0.7,
            300,
            false,
            true,
            false,
            TextEditingController(),
            0,
            [Message(1, 'Ask any question...', 0, 0)],
            0)) {
    on<FetchResultEvent>(
      (event, emit) async {
        if (event.query.trim() == "") return;
        emit(ChatLoadingState());
        allMessages[op].add(Message(0, event.query.trim(), 0, 0));
        allMessages[op].add(Message(1, 'Getting your answer...', 0, 0));
        op == 2
            ? emit(ImageGenerationState(n.toInt(), allMessages[op], op, sz))
            : emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
                maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));

        String res = "";
        List<Message> imres = [];
        switch (op) {
          case 0:
            if (nc) {
              String fquery = "";
              for (int i = 0; i < allMessages[op].length - 1; i++) {
                fquery += '${allMessages[op][i].c}\n';
              }
              if (sfx) {
                fquery = fquery.substring(0, fquery.length - 1);
              }
              res = await DatabaseService().chat(
                  sfx ? '$fquery ${suffix.trim()}' : fquery,
                  temp,
                  maxlength.toInt());
            } else {
              res = await DatabaseService().chat(
                  sfx
                      ? event.query.trim() + ' ' + suffix.trim()
                      : event.query.trim(),
                  temp,
                  maxlength.toInt());
            }
            if (sc) {
              allMessages[op].removeLast();
              allMessages[op].add(Message(1, res, 1, 0));
              DatabaseService().addMessage(<Message>[
                allMessages[op][allMessages[op].length - 2],
                allMessages[op].last
              ], chats[selectedDropdown!].id);
            } else {
              allMessages[op].removeLast();
              allMessages[op].add(Message(1, res, 1, 0));
            }
            break;

          case 1:
            String fquery = "";
            for (int i = 0; i < allMessages[op].length - 1; i++) {
              fquery += '${allMessages[op][i].c}\n';
            }
            if (nc) {
              res = await DatabaseService().complete(
                  sfx ? fquery + suffix.trim() : fquery,
                  temp,
                  maxlength.toInt());
            } else {
              res = await DatabaseService().complete(
                  sfx ? event.query.trim() + suffix.trim() : event.query.trim(),
                  temp,
                  maxlength.toInt());
            }
            allMessages[op].removeLast();
            allMessages[op].add(Message(1, res, 1, 0));
            break;

          case 2:
            imres = await DatabaseService().image(event.query, n.toInt(), sz);
            allMessages[op].removeLast();

            allMessages[op] = allMessages[op] + imres;
            break;

          default:
            res = await DatabaseService()
                .chat(event.query, temp, maxlength.toInt());
            break;
        }
        emit(ChatLoadingState());
        add(SetTokenEvent(0));
        op == 2
            ? emit(ImageGenerationState(n.toInt(), allMessages[op], op, sz))
            : emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
                maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
      },
    );

    on<SelectOptionEvent>(
      (event, emit) {
        op = event.op;
        if (op == 0) {
          if (!prefset) {
            temp = 0.7;
            maxlength = 300;
            nc = true;
          }
          emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
              maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
        } else if (op == 1) {
          selectedDropdown = null;
          sc = false;
          nc = false;
          if (!prefset) {
            temp = 1;
            maxlength = 3100;
          }
          emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
              maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
        } else if (op == 2) {
          emit(ImageGenerationState(n.toInt(), allMessages[op], op, sz));
        } else if (op == 3) {
          emit(UnderProgressState(op));
        }
      },
    );

    on<DeleteChatEvent>(
      (event, emit) async {
        emit(ChatLoadingState());
        allMessages[op].removeRange(event.idx, allMessages[op].length);
        emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
            maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
        if (sc) {
          bool res = await DatabaseService()
              .updateMessages(allMessages[op], chats[selectedDropdown!].id);
          while (!res) {
            res = await DatabaseService()
                .updateMessages(allMessages[op], chats[selectedDropdown!].id);
          }
        }
      },
    );

    on<RegenChatEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        allMessages[op].removeRange(event.idx, allMessages[op].length);
        String query = allMessages[op].last.c;
        allMessages[op].removeLast();
        if (sc) {
          DatabaseService()
              .updateMessages(allMessages[op], chats[selectedDropdown!].id);
        }
        add(FetchResultEvent(query));
      },
    );

    on<SetTempEvent>(
      (event, emit) {
        prefset = true;
        temp = event.temp;
        emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
            maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
      },
    );

    on<SetLenEvent>(
      (event, emit) {
        prefset = true;
        maxlength = event.len;
        emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
            maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
      },
    );

    on<SetNEvent>(
      (event, emit) {
        n = event.n;
        emit(ImageGenerationState(n.toInt(), allMessages[op], op, sz));
      },
    );

    on<SetSzEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        sz = event.sz;
        emit(ImageGenerationState(n.toInt(), allMessages[op], op, sz));
      },
    );

    on<SetNCEvent>(
      (event, emit) {
        prefset = true;
        nc = event.nc;
        emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
            maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
      },
    );

    on<SetSCEvent>(
      (event, emit) async {
        sc = event.sc;
        emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
            maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
        if (sc) {
          final pref = await SharedPreferences.getInstance();
          if (pref.getString('token') == null) {
            sc = false;
            await showDialog(
              context: event.context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Must Login to sync conversations"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('ok'))
                  ],
                );
              },
            );
            emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
                maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
            return;
          }
          if (op != 0) {
            sc = false;

            await showDialog(
              context: event.context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                      "Converation Sync not available for this mode"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('ok'))
                  ],
                );
              },
            );
            emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
                maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
            return;
          }
          dropitems = [];
          chats = await DatabaseService().getChats();
          for (int i = 0; i < chats.length; i++) {
            dropitems.add(DropdownMenuItem(
              child: Text(chats[i].name),
              value: i,
            ));
          }
          dropitems.add(DropdownMenuItem(
            child: const Text('New Chat'),
            value: chats.length,
          ));
          selectedDropdown = null;
        }
        emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
            maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
      },
    );

    on<SetTokenEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        int c = 0;
        if (nc) {
          String fquery = "";
          for (int i = 0; i < allMessages[op].length - 1; i++) {
            fquery += '${allMessages[op][i].c}\n';
          }
          c = fquery.length + event.tc;
        } else {
          c = event.tc;
        }
        tc = c;
        op == 2
            ? emit(ImageGenerationState(n.toInt(), allMessages[op], op, sz))
            : emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
                maxlength, sc, nc, sfx, sController, c, allMessages[op], op));
      },
    );

    on<SetDropdownEvent>(
      (event, emit) async {
        final _keyy = GlobalKey<FormState>();
        AutovalidateMode _autovalidatee = AutovalidateMode.disabled;
        TextEditingController _controllerr = TextEditingController();
        if (event.selected == chats.length) {
          await showDialog(
            context: event.context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Name for the chat:"),
                content: Form(
                  key: _keyy,
                  autovalidateMode: _autovalidatee,
                  child: TextFormField(
                      controller: _controllerr,
                      validator: (value) {
                        if (value == "") {
                          return 'enter a name';
                        }
                      }),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(event.context);
                      },
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () async {
                        if (_keyy.currentState!.validate()) {
                          final chat = await DatabaseService()
                              .createChat(_controllerr.text);
                          int val = chats.length;
                          if (chat != null) {
                            dropitems.removeLast();
                            chats.add(chat);
                            dropitems.add(DropdownMenuItem(
                              child: Text(chat.name),
                              value: val,
                            ));
                            dropitems.add(DropdownMenuItem(
                              child: const Text('New Chat'),
                              value: chats.length,
                            ));
                            allMessages[op] = [
                              Message(1, 'Ask any question...', 0, 0)
                            ];
                          }
                          selectedDropdown = val;
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Confirm')),
                ],
              );
            },
          );
        } else if (event.selected != null) {
          selectedDropdown = event.selected;
          allMessages[op] =
              await DatabaseService().getMessages(chats[selectedDropdown!].id);
          if (allMessages[op].isEmpty) {
            allMessages[op] = [Message(1, 'Ask any question...', 0, 0)];
          }
        } else {
          allMessages[op] = [Message(1, 'Ask any question...', 0, 0)];
        }

        emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
            maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
      },
    );

    on<RenameConvEvent>(
      (event, emit) async {
        final _key = GlobalKey<FormState>();
        AutovalidateMode _autovalidate = AutovalidateMode.disabled;
        TextEditingController _controller = TextEditingController();
        await showDialog(
          context: event.context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Name for the chat:"),
              content: Form(
                key: _key,
                autovalidateMode: _autovalidate,
                child: TextFormField(
                    controller: _controller,
                    validator: (value) {
                      if (value == "") {
                        return 'enter a name';
                      }
                    }),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(event.context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      if (_key.currentState!.validate()) {
                        DatabaseService().renameChat(
                            chats[selectedDropdown!].id, _controller.text);

                        chats[selectedDropdown!].name = _controller.text;
                        dropitems[selectedDropdown!] = DropdownMenuItem(
                          child: Text(_controller.text),
                          value: selectedDropdown!,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Confirm')),
              ],
            );
          },
        );
      },
    );

    on<DeleteConvEvent>(
      (event, emit) async {
        await showDialog(
          context: event.context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Are you sure?"),
              content: Text('This will delete the chat'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(event.context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () async {
                      Navigator.pop(event.context);
                      DatabaseService().deleteChat(chats[selectedDropdown!].id);
                      dropitems.removeAt(selectedDropdown!);
                      chats.removeAt(selectedDropdown!);
                      for (int i = 0; i < dropitems.length - 1; i++) {
                        dropitems[i] = DropdownMenuItem(
                          child: Text(chats[i].name),
                          value: i,
                        );
                      }
                      dropitems[chats.length] = DropdownMenuItem(
                        child: Text('New Chat'),
                        value: chats.length,
                      );
                      selectedDropdown = null;
                      allMessages[op] = defallMessages[op];
                      emit(ChatLoadedState(
                          dropitems,
                          selectedDropdown,
                          chats,
                          temp,
                          maxlength,
                          sc,
                          nc,
                          sfx,
                          sController,
                          tc,
                          allMessages[op],
                          op));
                    },
                    child: const Text('Confirm')),
              ],
            );
          },
        );
      },
    );

    on<ToggleSuffixEvent>(
      (event, emit) {
        sfx = event.sfx;
        emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
            maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
      },
    );

    on<SetSuffixEvent>(
      (event, emit) {
        sController.text = event.suf;
        sController.selection = TextSelection.fromPosition(
            TextPosition(offset: sController.text.length));
        emit(ChatLoadedState(dropitems, selectedDropdown, chats, temp,
            maxlength, sc, nc, sfx, sController, tc, allMessages[op], op));
      },
    );
  }
}
