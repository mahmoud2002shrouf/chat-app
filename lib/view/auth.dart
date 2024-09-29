import "dart:io";

import "package:chat_app/conteroller/auth_controller.dart";
import "package:chat_app/widget/user_image.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

class Auth extends StatefulWidget {
  const Auth({Key? key}) : super(key: key);

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  AuthController authCon = Get.find();
  final ValueKey = GlobalKey<FormState>();
  var _islogin = true;
  var _enteredEmail = "";
  var _enteredPassword = "";
  var _enteredName = "";
  File? selectimage;
  var _isAuth = false;

  Future<void> _submet() async {
    final isValid = ValueKey.currentState!.validate();
    if (!isValid || !_islogin && selectimage == null) {
      return;
    }
    ValueKey.currentState!.save();
    setState(() {
      _isAuth = true;
    });
    if (_islogin) {
      final userLogin =
          await authCon.loginUser(_enteredEmail, _enteredPassword, context);
      if (userLogin) {
        setState(() {
          _isAuth = false;
        });
      }
    } else {
      final usersignup = await authCon.addNewUser(
          _enteredEmail, _enteredPassword, _enteredName, selectimage!, context);
      if (usersignup) {
        setState(() {
          _isAuth = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: ValueKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_islogin)
                            UserImage(
                              userImage: (image) {
                                selectimage = image;
                              },
                            ),
                          if (!_islogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'User name',
                              ),
                              keyboardType: TextInputType.name,
                              autocorrect: false,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 5) {
                                  return 'Please enter a valid name';
                                }
                                return null;
                              },
                              onSaved: (newValue) {
                                _enteredName = newValue!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email Adress',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredEmail = newValue!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Please enter a valid password';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredPassword = newValue!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isAuth) const CircularProgressIndicator(),
                          if (!_isAuth)
                            ElevatedButton(
                                onPressed: _submet,
                                child: Text(_islogin ? "Login" : 'Signup')),
                          if (!_isAuth)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _islogin = !_islogin;
                                });
                              },
                              child: Text(_islogin
                                  ? 'Create an account'
                                  : 'I already have  an account'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
