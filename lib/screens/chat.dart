import 'package:flutter/material.dart';
import 'package:organisedgpt/screens/desktopchat.dart';
import 'package:organisedgpt/screens/chatmobile.dart';
import 'package:size_helper/size_helper.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizeHelper.of(context).helpBuilder(
        desktopNormal: (_) => DesktopChatScreen(),
        desktopSmall: ((screenInfo) {
          if (screenInfo.width >= 1024) return DesktopChatScreen();

          return MobileChatScreen();
        }));
  }
}
