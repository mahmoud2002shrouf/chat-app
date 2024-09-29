import 'package:chat_app/conteroller/bindeng.dart';
import 'package:chat_app/view/auth.dart';
import 'package:chat_app/view/chat.dart';
import 'package:chat_app/view/home.dart';
import 'package:chat_app/view/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: Bindeng(),
      title: 'FlutterChat',
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 63, 17, 177)),
      ),
      home: StreamBuilder(stream:FirebaseAuth.instance.authStateChanges() ,builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting){
          return const Splash();
        }
        if(snapshot.hasData){
          return const Home();
        }
        return const Auth();
        
      },)
    );
  }

}
// }
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ImagePickerGrid(),
//     );
//   }
// }



// class ImagePickerGrid extends StatefulWidget {
//   @override
//   _ImagePickerGridState createState() => _ImagePickerGridState();
// }

// class _ImagePickerGridState extends State<ImagePickerGrid> {
//   final ImagePicker _picker = ImagePicker();
//   List<XFile>? _imageFileList = [];

//   void _pickImage() async {
//     final List<XFile>? selectedImages = await _picker.pickMultiImage();
//     if (selectedImages != null) {
//       setState(() {
//         _imageFileList = selectedImages;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Image Picker'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add_photo_alternate),
//             onPressed: _pickImage,
//           ),
//         ],
//       ),
//       body: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           crossAxisSpacing: 4.0,
//           mainAxisSpacing: 4.0,
//         ),
//         itemCount: _imageFileList?.length ?? 0,
//         itemBuilder: (context, index) {
//           return Image.file(File(_imageFileList![index].path), fit: BoxFit.cover);
//         },
//       ),
//     );
//   }
// }