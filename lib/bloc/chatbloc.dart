//ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/services/database.dart';

class ChatLoadingState extends AppState {}

class ChatLoadedState extends AppState {
  final List<Map<String, dynamic>> _chats;
  int op;
  ChatLoadedState(this._chats, this.op);

  @override
  List<Object?> get props => [_chats];

  get chats => _chats;
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

class ChatBloc extends Bloc<AppEvent, AppState> {
  List<List<Map<String, dynamic>>> allChats = [
    [
      {'u': 1, "c": 'Ask any question...', 't': 0}
    ],
    [
      {'u': 1, "c": 'Start with any phrase...', 't': 0}
    ],
    [
      {'u': 1, "c": 'Give any description...', 't': 0}
    ],
    [
      {'u': 1, "c": 'Upload an audio...', 't': 0}
    ]
  ];

  int op = 0;
  ChatBloc()
      : super(ChatLoadedState([
          const {'u': 1, "c": 'Ask any question...', 't': 0}
        ], 0)) {
    on<FetchResultEvent>(
      (event, emit) async {
        emit(ChatLoadingState());
        allChats[op].add({'u': 0, 'c': event.query, 't': 0});
        allChats[op].add({'u': 1, 'c': 'Getting your answer...', 't': 0});
        emit(ChatLoadedState(allChats[op], op));

        String res;
        switch (op) {
          case 0:
            String fquery = "";
            for (int i = 0; i < allChats[op].length - 1; i++) {
              fquery += allChats[op][i]['c'] + '\n';
            }
            res = await DatabaseService().chat(fquery);
            break;

          case 1:
            res = await DatabaseService().complete(event.query);
            break;

          case 2:
            res = await DatabaseService().image(event.query);
            break;

          default:
            res = await DatabaseService().chat(event.query);
            break;
        }
        allChats[op].removeLast();
        op == 2
            ? allChats[op].add({'u': 1, 'c': res, 't': 1})
            : allChats[op].add({'u': 1, 'c': res, 't': 0});
        emit(ChatLoadingState());
        emit(ChatLoadedState(allChats[op], op));
      },
    );

    on<SelectOptionEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        op = event.op;
        emit(ChatLoadedState(allChats[op], op));
      },
    );
  }
}
