import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organisedgpt/bloc/chatbloc.dart';
import 'package:organisedgpt/screens/desktopchat.dart';
import 'package:organisedgpt/screens/chatmobile.dart';
import 'package:size_helper/size_helper.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc(),
      child: SizeHelper.of(context).helpBuilder(
          desktopNormal: (_) => DesktopChatScreen(context),
          desktopSmall: ((screenInfo) {
            if (screenInfo.width >= 1024) return DesktopChatScreen(context);
    
            return MobileChatScreen(context);
          })),
    );
  }
}
