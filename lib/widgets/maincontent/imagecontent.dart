// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:organisedgpt/bloc/chatbloc.dart';

import '../reused/dialogue.dart';

class ImageContent extends StatelessWidget {
  ImageContent(this.context, this.state, {super.key});
  BuildContext context;
  ImageGenerationState state;
  @override
  Widget build(BuildContext tctx) {
    return ListView.builder(
        itemCount: state.chats.length,
        reverse: true,
        itemBuilder: (context, idx) {
          final ridx = state.chats.length - 1 - idx;
          return Dialogue(ridx, state.chats[ridx]['u'], state.chats[ridx]['c'],
              state.chats[ridx]['t'], state.chats[ridx]['a'], context);
        });
    ;
  }
}
