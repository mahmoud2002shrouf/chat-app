import 'package:chat_app/conteroller/auth_controller.dart';
import 'package:chat_app/view/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var user;

  Future getUser() async {
    await FirebaseFirestore.instance
        .collection('user')
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((value) {
      value.docs.forEach((value) {
        setState(() {
          user = value.data();
        });
        // user.add(value.data());
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    print("====================user========================");

    getUser();
    super.initState();
  }

  var Users = [];
  Future<void> getAllUser() async {
    FirebaseFirestore.instance.collection('user').get().then((value) {
      print(value.docs[0].data());
      print("------------------------");
      value.docs.forEach((ele) {
        setState(() {
          print("======================");
          print(ele.data()["user"]);
          Users.add(ele.data());
        });
      });
      print(Users);
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthController auth = Get.find();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: Column(children: [
          if (user != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(alignment: Alignment.bottomRight, children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      user['image_url'],
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.green),
                  ),
                ]),
                const SizedBox(
                  width: 20,
                ),
                Text("Hello ${user['user']}"),
                const SizedBox(
                  width: 20,
                ),
                IconButton(
                    onPressed: () {
                      auth.logOut(context);
                    },
                    icon: const Icon(Icons.login_outlined))
              ],
            ),
          if (user == null)
            const SizedBox(
                height: 3,
                width: 250,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white,
                )),
          const SizedBox(
            height: 15,
            width: double.infinity,
            child: Divider(),
          ),
        ]),
      ),
      body: FutureBuilder(
          future: FirebaseFirestore.instance.collection('user').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: const Text("No user flund"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                print(snapshot.data!.docs[index]['email']);
                print(user['email']);
          if (user != null){
return snapshot.data!.docs[index]['email'] == user['email']
                    ? const SizedBox.shrink()
                    : Column(
                      children: [
                        ListTile(
                          onTap: (){
                            print("============uid===========");
                            print(snapshot.data!.docs[index]["uid"]);
                            Get.to(()=> Chat(user: snapshot.data!.docs[index],));
                          },
                            textColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.only(left: 5, top: 7, bottom: 7),
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                snapshot.data!.docs[index]["image_url"],
                              ),
                            ),
                            title: Text(snapshot.data!.docs[index]["user"]),
                          ),
                           SizedBox(width: MediaQuery.of(context).size.width/1.1,child: const Divider(color: Color.fromARGB(49, 255, 255, 255),),)
                      ],
                    );
          }
                
              },
            );
          }),
    );
  }
}
