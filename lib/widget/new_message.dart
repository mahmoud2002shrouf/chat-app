import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class NewMessage extends StatefulWidget {
  NewMessage({Key? key, required this.user}) : super(key: key);
  var user;

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  var Curuser = FirebaseAuth.instance.currentUser!.uid;

  var _messageController = TextEditingController();
  @override
  void dispose() {
    // TODO: implement dispose
    _messageController.dispose();
    super.dispose();
  }

  String generateToken(List<String> userIds) {
    userIds.sort();

    final String combined = userIds.join(':');

    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageList = [];

  void _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();

    if (images != null && images.isNotEmpty) {
      setState(() {
        _imageList = images;
      });
    }
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(
        requestFullMetadata: true, source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageList?.add(image);
      });
    }
  }

  void _sendMessage({required var userid}) async {
    print("============uid2===========");

    print(userid);
    String token = generateToken([Curuser, userid]);
    final enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();

    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    final userData =
        await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
    FirebaseFirestore.instance
        .collection('chats')
        .doc(token)
        .collection("message")
        .add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['user'],
      'imageUrl': userData.data()!['image_url'],
      "isRead": false,
      "timeRead": ""
    });
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(139, 0, 0, 0),
                offset: Offset(2, 2),
                blurRadius: 20)
          ],
          color: Colors.white),
      child: Column(
        children: [
          if (_imageList != null && _imageList!.isNotEmpty)
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _imageList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      margin: const EdgeInsets.all(5),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_imageList![index].path),
                          )));
                },
              ),
            ),
          // زر الإرسال يظهر فقط إذا كان هناك صور مختارة
          if (_imageList != null && _imageList!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Send ${_imageList!.length} Images'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _imageList = [];
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    _pickImages();
                  },
                  icon: const Icon(Icons.photo)),
              IconButton(
                  onPressed: () {
                    _pickImage();
                  },
                  icon: const Icon(Icons.camera_alt)),
              Expanded(
                  child: TextField(
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration:
                    const InputDecoration(labelText: 'Send a message ...'),
                controller: _messageController,
              )),
              IconButton(
                onPressed: () {
                  _sendMessage(userid: widget.user);
                },
                icon: const Icon(Icons.send),
                color: Theme.of(context).colorScheme.primary,
              )
            ],
          ),
        ],
      ),
    );
  }
}
