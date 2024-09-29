import 'package:chat_app/conteroller/auth_controller.dart';
import 'package:chat_app/widget/chat_message.dart';
import 'package:chat_app/widget/new_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class Chat extends StatefulWidget {
  Chat({Key? key, required this.user}) : super(key: key);
  var user;
  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  void setupPushNotifaction() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    // final token=await fcm.getToken();
    // print("token : $token");
    await fcm.subscribeToTopic('chat');
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    setupPushNotifaction();
  }

  @override
  Widget build(BuildContext context) {
    AuthController auth = Get.find();
    return Scaffold(
      appBar: AppBar(
        title:Row(children: [CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(
                                widget.user["image_url"],
                              ),
                            ),const SizedBox(width: 20,),Text(widget.user['user'])],) ,
      ),
      body: Column(
        children: [
           Expanded(child: ChatMessage(user: widget.user['uid'],)),
          NewMessage(
            user: widget.user['uid'],
          )
        ],
      ),
    );
  }
}
