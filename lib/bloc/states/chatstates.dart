import 'package:flutter/material.dart';

import '../../models/conversation.dart';
import '../appbloc.dart';

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
  bool sc, nc, sfx,es;
  List<ChatModel> chats;
  List<DropdownMenuItem<int>> dropitems;
  int? selectedDropdown;
  TextEditingController sController;
  ChatLoadedState(this.dropitems, this.selectedDropdown, this.chats, this.temp,
      this.maxlength, this.sc, this.nc, this.sfx,this.es,this.sController, this.tc, this._Messages, this.op);

  @override
  List<Object?> get props => [
        _Messages,
        temp,
        op,
        maxlength,
        sc,
        nc,
        sfx,
        es,
        sController,
        chats,
        dropitems,
        selectedDropdown
      ];

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
