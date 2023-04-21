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
  bool nc;
  ChatLoadedState(this.temp, this.maxlength, this.nc, this._chats, this.op);

  @override
  List<Object?> get props => [_chats, temp, op];

  get chats => _chats;
}

class ImageGenerationState extends AppState {
  int _n, op, sz;
  final List<Map<String, dynamic>> _chats;
  ImageGenerationState(this._n, this._chats, this.op, this.sz);

  @override
  List<Object?> get props => [_chats, _n];

  get n => _n;
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

  int op = 0, sz = 0;
  double temp = 0.7, maxlength = 300, n = 1;
  bool nc = true;
  ChatBloc()
      : super(ChatLoadedState(
            0.7,
            300,
            true,
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
        op == 2
            ? emit(ImageGenerationState(n.toInt(), allChats[op], op, sz))
            : emit(ChatLoadedState(temp, maxlength, nc, allChats[op], op));

        String res = "";
        List<Map<String, dynamic>> imres = [];
        switch (op) {
          case 0:
            String fquery = "";
            for (int i = 0; i < allChats[op].length - 1; i++) {
              fquery += allChats[op][i]['c'] + '\n';
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
            for (int i = 0; i < allChats[op].length - 1; i++) {
              fquery += allChats[op][i]['c'] + '\n';
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
        allChats[op].removeLast();
        op == 2
            ? allChats[op] = allChats[op] + imres
            : allChats[op].add({'u': 1, 'c': res, 'a': 1, 't': 0});
        emit(ChatLoadingState());

        op == 2
            ? emit(ImageGenerationState(n.toInt(), allChats[op], op, sz))
            : emit(ChatLoadedState(temp, maxlength, nc, allChats[op], op));
      },
    );

    on<SelectOptionEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        op = event.op;
        if (op == 2) {
          emit(ImageGenerationState(n.toInt(), allChats[op], op, sz));
        } else if (op == 3) {
          emit(UnderProgressState(op));
        } else {
          emit(ChatLoadedState(temp, maxlength, nc, allChats[op], op));
        }
      },
    );

    on<DeleteChatEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        allChats[op].removeRange(event.idx, allChats[op].length);

        emit(ChatLoadedState(temp, maxlength, nc, allChats[op], op));
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
        emit(ChatLoadedState(temp, maxlength, nc, allChats[op], op));
      },
    );

    on<SetLenEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        maxlength = event.len;
        emit(ChatLoadedState(temp, maxlength, nc, allChats[op], op));
      },
    );

    on<SetNEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        n = event.n;
        emit(ImageGenerationState(n.toInt(), allChats[op], op, sz));
      },
    );

    on<SetSzEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        sz = event.sz;
        emit(ImageGenerationState(n.toInt(), allChats[op], op, sz));
      },
    );

    on<SetNCEvent>(
      (event, emit) {
        emit(ChatLoadingState());
        nc = event.nc;
        emit(ChatLoadedState(temp, maxlength, nc, allChats[op], op));
      },
    );
  }
}
