//ignore_for_file: prefer_const_literals_to_create_immutables
import 'dart:html';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/models/conversation.dart';
import 'package:organisedgpt/services/database.dart';

class ChatLoadingState extends AppState {}

class UnderProgressState extends AppState {
  int _op;
  UnderProgressState(this._op);

  get op => _op;
}

class ChatLoadedState extends AppState {
  final List<Message> _Messages;
  int op, tc;
  double temp, maxlength;
  bool sc, nc;
  List<ChatModel> chats;
  List<DropdownMenuItem<String>> dropitems;
  ChatLoadedState(this.dropitems, this.chats, this.temp, this.maxlength,
      this.sc, this.nc, this.tc, this._Messages, this.op);

  @override
  List<Object?> get props => [_Messages, temp, op, maxlength, sc, nc, chats];

  get Messages => _Messages;
}

class ImageGenerationState extends AppState {
  int _n, op, sz;
  final List<Message> _Messages;
  ImageGenerationState(this._n, this._Messages, this.op, this.sz);

  @override
  List<Object?> get props => [_Messages, _n, op, sz];

  get n => _n;
  get Messages => _Messages;
}

class FetchResultEvent extends AppEvent {
  final String _query;
  FetchResultEvent(this._query);
  get query => _query;
}

class SelectOptionEvent extends AppEvent {
  final int _op;
  SelectOptionEvent(this._op);
  get op => _op;
}

class DeleteChatEvent extends AppEvent {
  final int _idx;
  DeleteChatEvent(this._idx);
  get idx => _idx;
}

class RegenChatEvent extends AppEvent {
  final int _idx;
  RegenChatEvent(this._idx);
  get idx => _idx;
}

class SetTempEvent extends AppEvent {
  double temp;
  SetTempEvent(this.temp);
}

class SetNEvent extends AppEvent {
  double n;
  SetNEvent(this.n);
}

class SetSzEvent extends AppEvent {
  int sz;
  SetSzEvent(this.sz);
}

class SetLenEvent extends AppEvent {
  double len;
  SetLenEvent(this.len);
}

class SetNCEvent extends AppEvent {
  bool nc;
  SetNCEvent(this.nc);
}

class SetSCEvent extends AppEvent {
  bool sc;
  SetSCEvent(this.sc);
}

class SetTokenEvent extends AppEvent {
  int tc;
  SetTokenEvent(this.tc);
}

class ChatBloc extends Bloc<AppEvent, AppState> {
  List<List<Message>> allMessages = [
    [
      // {'u': 1, "c": 'Ask any question...', 'a': 0, 't': 0}
      Message(1, 'Ask any question...', 0, 0)
    ],
    [
      // {'u': 1, "c": 'Start with any phrase...', 'a': 0, 't': 0}
      Message(1, 'Start with any phrase...', 0, 0)
    ],
    [
      // {'u': 1, "c": 'Give any description...', 'a': 0, 't': 0}
      Message(1, 'Give any description...', 0, 0)
    ],
    [
      // {'u': 1, "c": 'Upload an audio...', 'a': 0, 't': 0}
      Message(1, 'Upload an audio...', 0, 0)
    ]
  ];

  int op = 0, sz = 0, tc = 0;
  double temp = 0.7, maxlength = 300, n = 1;
  bool nc = true, sc = true;
  List<ChatModel> chats = [];
  List<DropdownMenuItem<String>> dropitems = [];
  ChatBloc()
      : super(ChatLoadedState([], [], 0.7, 300, true, true, 0,
            [Message(1, 'Ask any question...', 0, 0)], 0)) {
    on<FetchResultEvent>(
      (event, emit) async {
        if (event.query.trim() == "") return;
        emit(ChatLoadingState());
        allMessages[op].add(Message(0, event.query.trim(), 0, 0));
        allMessages[op].add(Message(1, 'Getting your answer...', 0, 0));
        op == 2
            ? emit(ImageGenerationState(n.toInt(), allMessages[op], op, sz))
            : emit(ChatLoadedState(dropitems, chats, temp, maxlength, sc, nc,
                tc, allMessages[op], op));

        String res = "";
        List<Message> imres = [];
        switch (op) {
          case 0:
            String fquery = "";
            for (int i = 0; i < allMessages[op].length - 1; i++) {
              fquery += '${allMessages[op][i].c}\n';
            }
            if (nc) {
              res =
                  await DatabaseService().chat(fquery, temp, maxlength.toInt());
            } else {
              res = await DatabaseService()
                  .chat(event.query.trim(), temp, maxlength.toInt());
            }
            break;

          case 1:
            String fquery = "";
            for (int i = 0; i < allMessages[op].length - 1; i++) {
              fquery += '${allMessages[op][i].c}\n';
            }
            if (nc) {
              res = await DatabaseService()
                  .complete(fquery, temp, maxlength.toInt());
            } else {
              res = await DatabaseService()
                  .complete(event.query, temp, maxlength.toInt());
            }

            break;

          case 2:
            imres = await DatabaseService().image(event.query, n.toInt(), sz);
            break;

          default:
            res = await DatabaseService()
                .chat(event.query, temp, maxlength.toInt());
            break;
        }
        allMessages[op].removeLast();
        op == 2
            ? allMessages[op] = allMessages[op] + imres
            : allMessages[op].add(Message(1, res, 1, 0));
        emit(ChatLoadingState());
        add(SetTokenEvent(0));
        op == 2
            ? emit(ImageGenerationState(n.toInt(), allMessages[op], op, sz))
            : emit(ChatLoadedState(dropitems, chats, temp, maxlength, sc, nc,
                tc, allMessages[op], op));
      },
    );

    on<SelectOptionEvent>(
      (event, emit) {
        // emit(ChatLoadingState());
        op = event.op;
        if (op == 2) {
          emit(ImageGenerationState(n.toInt(), allMessages[op], op, sz));
        } else if (op == 3) {
          emit(UnderProgressState(op));
        } else {
          emit(ChatLoadedState(dropitems, chats, temp, maxlength, sc, nc, tc,
              allMessages[op], op));
        }
      },
    );

    on<DeleteChatEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        allMessages[op].removeRange(event.idx, allMessages[op].length);

        emit(ChatLoadedState(dropitems, chats, temp, maxlength, sc, nc, tc,
            allMessages[op], op));
      },
    );

    on<RegenChatEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        allMessages[op].removeRange(event.idx, allMessages[op].length);
        String query = allMessages[op].last.c;
        allMessages[op].removeLast();
        add(FetchResultEvent(query));
      },
    );

    on<SetTempEvent>(
      (event, emit) {
        temp = event.temp;
        emit(ChatLoadedState(dropitems, chats, temp, maxlength, sc, nc, tc,
            allMessages[op], op));
      },
    );

    on<SetLenEvent>(
      (event, emit) {
        // emit(ChatLoadingState());
        maxlength = event.len;
        emit(ChatLoadedState(dropitems, chats, temp, maxlength, sc, nc, tc,
            allMessages[op], op));
      },
    );

    on<SetNEvent>(
      (event, emit) {
        // emit(ChatLoadingState());
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
        // emit(ChatLoadingState());
        nc = event.nc;
        emit(ChatLoadedState(dropitems, chats, temp, maxlength, sc, nc, tc,
            allMessages[op], op));
      },
    );

    on<SetSCEvent>(
      (event, emit) async {
        // emit(ChatLoadingState());
        sc = event.sc;
        if (sc) {
          final chats = await DatabaseService().getChats();
          for (int i = 0; i < chats.length; i++) {
            dropitems.add(DropdownMenuItem(child: Text(chats[i].name)));
          }
        }
        emit(ChatLoadedState(dropitems, chats, temp, maxlength, sc, nc, tc,
            allMessages[op], op));
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
            : emit(ChatLoadedState(dropitems, chats, temp, maxlength, sc, nc, c,
                allMessages[op], op));
      },
    );
  }
}
