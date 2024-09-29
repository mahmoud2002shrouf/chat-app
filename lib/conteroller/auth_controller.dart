import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _fireBase = FirebaseAuth.instance;

class AuthController extends GetxController {
  Future<bool> addNewUser(var emails, var passwords,var userName,File userImage, var context) async {
    try {
      final userCredantiols = await _fireBase.createUserWithEmailAndPassword(
          email: emails, password: passwords);
         final storageRef= FirebaseStorage.instance.ref().child('user_image').child('${userCredantiols.user!.uid}.jpg');
        await storageRef.putFile(userImage);
        final imageuser=await storageRef.getDownloadURL();
        await FirebaseFirestore.instance.collection('user').doc(userCredantiols.user!.uid).set({
          'user':userName,
          'email':emails,
          'image_url':imageuser,
          'uid':userCredantiols.user!.uid

        });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("success")));
    } on FirebaseAuthException catch (err) {
      if (err.code == 'email-already-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err.message ?? "auth filed")));
          return true;
    }
    return false;
  }

  Future<bool> loginUser(var emails, var passwords, var context) async {
    try {
      final userLogin = await _fireBase.signInWithEmailAndPassword(
          email: emails, password: passwords);
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text( "login success")));
            print(userLogin);
    } on FirebaseAuthException catch (err) {
      // if (err.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err.message ?? "invalid email")));
            return true;
      // }
    }
    return false;
  }
  void logOut(context)async{
      ScaffoldMessenger.of(context).clearSnackBars();

    try{
    final logoutUser=await _fireBase.signOut();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:  Text('Logout success')));
    }on FirebaseException catch(err){
      
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:  Text(err.message?? "invalid Logout")));

    }
  }
}
