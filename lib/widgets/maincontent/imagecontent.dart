// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:organisedgpt/bloc/chatbloc.dart';

import '../../bloc/states/chatstates.dart';
import '../reused/dialogue.dart';

class ImageContent extends StatelessWidget {
  ImageContent(this.context, this.state, {super.key});
  BuildContext context;
  ImageGenerationState state;
  @override
  Widget build(BuildContext tctx) {
    return ListView.builder(
        itemCount: state.Messages.length,
        reverse: true,
        itemBuilder: (context, idx) {
          final ridx = state.Messages.length - 1 - idx;
          return Dialogue(ridx, state.Messages[ridx].u, state.Messages[ridx].c,
              state.Messages[ridx].t, state.Messages[ridx].a, context);
        });
    ;
  }
}
