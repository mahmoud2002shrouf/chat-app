import "dart:async";
import "dart:convert";

import "package:chat_app/widget/message_bubble.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:crypto/crypto.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class ChatMessage extends StatelessWidget {
  ChatMessage({Key? key, required this.user}) : super(key: key);
  var user;
  @override
  String generateToken(List<String> userIds) {
    userIds.sort();

    final String combined = userIds.join(':');

    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> gatMessage() {
    String token =
        generateToken([FirebaseAuth.instance.currentUser!.uid, user]);

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(token)
        .collection("message")
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  String getFormat(var ele) {
    Timestamp timestamp = ele;
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat("yyyy-MM-dd").format(dateTime);
    return formattedDate;
  }

  void markAsRead(String messageId) {
    String token =
        generateToken([FirebaseAuth.instance.currentUser!.uid, user]);

    FirebaseFirestore.instance
        .collection('chats')
        .doc(token)
        .collection("message")
        .doc(messageId)
        .update({'isRead': true});
  }

  Widget build(BuildContext context) {
    final userAuth = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: gatMessage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No message found.'),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong ...'),
            );
          }
          final loadedMessages = snapshot.data!.docs;
          Map<String, List<DocumentSnapshot>> groupedMessages = {};
          loadedMessages.forEach((value) {
            Timestamp timestamp = value.data()["createdAt"];
            DateTime dateTime = timestamp.toDate();
            String formattedDate = DateFormat("yyyy-MM-dd").format(dateTime);

            if (groupedMessages[formattedDate] == null) {
              groupedMessages[formattedDate] = [];
            }
            groupedMessages[formattedDate]!.add(value);
          });
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
            reverse: true,
            itemCount: groupedMessages.length,
            itemBuilder: (context, index) {
              var keys = [];
              var data = [];
              groupedMessages.forEach((key, value) {
                keys.add(key);
                
                data.add(value);
              });
              print(keys);
              // print(data[1][1]["text"]);
              return Column(
                children: [
                  Text(keys[index]),
                  ListView.builder(
                    reverse: true,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: data[index].length,
                    itemBuilder: (context, indexs) {
                      final chatMessage = data[index][indexs].data();
                      if(!chatMessage['isRead'] && chatMessage["userId"]!=FirebaseAuth.instance.currentUser!.uid ){
                        markAsRead(data[index][indexs].id);
                      }
                      print("================================");
                      // print(chatMessage);
                      print("================================");

                      final nextChatMessage = index + 1 < loadedMessages.length
                          ? loadedMessages[index + 1].data()
                          : null;

                      final currentMessageUserId = chatMessage['userId'];
                      final nextMessageUserId = nextChatMessage != null
                          ? nextChatMessage['userId']
                          : null;
                      final nextUserIsSame =
                          nextMessageUserId == currentMessageUserId;

                      if (nextUserIsSame) {
                        return MessageBubble.next(
                          message: chatMessage['text'],
                          isMe: userAuth.uid == currentMessageUserId,
                        );
                      } else {
                        return MessageBubble.first(
                          userImage: chatMessage['imageUrl'],
                          username: chatMessage['username'],
                          message: chatMessage['text'],
                          isMe: userAuth.uid == currentMessageUserId,
                        );
                      }
                    },
                  ),
                ],
              );
            },
          );
        });
  }
}


// Column(
//                 children: [
//                   Text(keys[index]),
//                    for(int i =0;i<data[index].length;i++)
                     

//                 ],
//               );

//                 List<Widget> messageWidgets = [];

//              groupedMessages.forEach(
//                 (key, value) {
//                  messageWidgets.add( Column(
//                     children: [
//                       Text(getFormat(key)),
//                       if (nextUserIsSame)
//                         MessageBubble.next(
//                           message: chatMessage['text'],
//                           isMe: userAuth.uid == currentMessageUserId,
//                         ),
//                       if (!nextUserIsSame)
//                         MessageBubble.first(
//                           userImage: chatMessage['imageUrl'],
//                           username: chatMessage['username'],
//                           message: chatMessage['text'],
//                           isMe: userAuth.uid == currentMessageUserId,
//                         )
//                     ],
//                   ));
//                 },
//               );

// return ListView(
//                   padding:
//                       const EdgeInsets.only(bottom: 40, left: 13, right: 13),
//                   reverse: true,
//                   children: messageWidgets,
//                 );