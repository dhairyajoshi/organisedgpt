import 'package:flutter/material.dart';

import '../appbloc.dart';

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
  BuildContext context;
  SetSCEvent(this.context, this.sc);
}

class SetTokenEvent extends AppEvent {
  int tc;
  SetTokenEvent(this.tc);
}

class SetDropdownEvent extends AppEvent {
  int? selected;
  BuildContext context;
  SetDropdownEvent(this.context, this.selected);
}

class RenameConvEvent extends AppEvent{
  BuildContext context;
  RenameConvEvent(this.context);
}

class DeleteConvEvent extends AppEvent{
  BuildContext context;
  DeleteConvEvent(this.context);
}