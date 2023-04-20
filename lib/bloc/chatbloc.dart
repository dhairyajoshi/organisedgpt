//ignore_for_file: prefer_const_literals_to_create_immutables
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:organisedgpt/bloc/appbloc.dart';
import 'package:organisedgpt/services/database.dart';

class ChatLoadingState extends AppState {}

class UnderProgressState extends AppState {
  int _op;
  UnderProgressState(this._op);

  get op => _op;
}

class ChatLoadedState extends AppState {
  final List<Map<String, dynamic>> _chats;
  int op;
  double temp, maxlength;
  ChatLoadedState(this.temp, this.maxlength, this._chats, this.op);

  @override
  List<Object?> get props => [_chats, temp, op];

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

class SetLenEvent extends AppEvent {
  double len;
  SetLenEvent(this.len);
}

class ChatBloc extends Bloc<AppEvent, AppState> {
  List<List<Map<String, dynamic>>> allChats = [
    [
      {'u': 1, "c": 'Ask any question...', 'a': 0, 't': 0}
    ],
    [
      {'u': 1, "c": 'Start with any phrase...', 'a': 0, 't': 0}
    ],
    [
      {'u': 1, "c": 'Give any description...', 'a': 0, 't': 0}
    ],
    [
      {'u': 1, "c": 'Upload an audio...', 'a': 0, 't': 0}
    ]
  ];

  int op = 0;
  double temp = 0.7, maxlength = 300;
  ChatBloc()
      : super(ChatLoadedState(
            0.7,
            300,
            [
              const {'u': 1, "c": 'Ask any question...', 'a': 0, 't': 0}
            ],
            0)) {
    on<FetchResultEvent>( 
      (event, emit) async {
        if (event.query.trim() == "") return;
        emit(ChatLoadingState());
        allChats[op].add({'u': 0, 'c': event.query.trim(), 'a': 0, 't': 0});
        allChats[op]
            .add({'u': 1, 'c': 'Getting your answer...', 'a': 0, 't': 0});
        emit(ChatLoadedState(temp, maxlength, allChats[op], op));

        String res;
        switch (op) {
          case 0:
            String fquery = "";
            for (int i = 0; i < allChats[op].length - 1; i++) {
              fquery += allChats[op][i]['c'] + '\n';
            }
            res = await DatabaseService().chat(fquery, temp, maxlength.toInt());
            break;

          case 1:
            res = await DatabaseService()
                .complete(event.query, temp, maxlength.toInt());
            break;

          case 2:
            res = await DatabaseService().image(event.query);
            break;

          default:
            res = await DatabaseService()
                .chat(event.query, temp, maxlength.toInt());
            break;
        }
        allChats[op].removeLast();
        op == 2
            ? allChats[op].add({'u': 1, 'c': res, 'a': 1, 't': 1})
            : allChats[op].add({'u': 1, 'c': res, 'a': 1, 't': 0});
        emit(ChatLoadingState());
        emit(ChatLoadedState(temp, maxlength, allChats[op], op));
      },
    );

    on<SelectOptionEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        op = event.op;
        if (op == 3) {
          emit(UnderProgressState(op));
        } else {
          emit(ChatLoadedState(temp, maxlength, allChats[op], op));
        }
      },
    );

    on<DeleteChatEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        allChats[op].removeRange(event.idx, allChats[op].length);

        emit(ChatLoadedState(temp, maxlength, allChats[op], op));
      },
    );

    on<RegenChatEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        allChats[op].removeRange(event.idx, allChats[op].length);
        String query = allChats[op].last['c'];
        allChats[op].removeLast();
        add(FetchResultEvent(query));
      },
    );

    on<SetTempEvent>(
      (event, emit) {
        temp = event.temp;
        emit(ChatLoadedState(temp, maxlength, allChats[op], op));
      },
    );

    on<SetLenEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        maxlength = event.len;
        emit(ChatLoadedState(temp, maxlength, allChats[op], op));
      },
    );
  }
}
