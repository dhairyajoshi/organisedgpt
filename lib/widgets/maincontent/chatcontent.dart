import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organisedgpt/bloc/chatbloc.dart';

import '../../bloc/events/chatevents.dart';
import '../../bloc/states/chatstates.dart';
import '../reused/dialogue.dart';

class ChatContent extends StatelessWidget {
  ChatContent(this.context, this.state, {super.key});
  BuildContext context;
  ChatLoadedState state;

  @override
  Widget build(BuildContext tctx) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (state.sc)
            Flexible(
              flex: 1,
              child: Container(
                // color: Colors.blue,
                child: DropdownButton<int>(
                  hint: Text('select chat'),
                  value: state.selectedDropdown,
                  items: state.dropitems,
                  onChanged: (value) {
                    BlocProvider.of<ChatBloc>(context)
                        .add(SetDropdownEvent(context, value));
                  },
                ),
              ),
            ),
          if ((state.sc && state.selectedDropdown != null) || !state.sc)
            Flexible(
              flex: 10,
              child: ListView.builder(
                  itemCount: state.Messages.length,
                  reverse: true,
                  itemBuilder: (context, idx) {
                    final ridx = state.Messages.length - 1 - idx;
                    return Dialogue(
                        ridx,
                        state.Messages[ridx].u,
                        state.Messages[ridx].c,
                        state.Messages[ridx].t,
                        state.Messages[ridx].a,
                        context);
                  }),
            ),
        ],
      ),
    );
    ;
  }
}
