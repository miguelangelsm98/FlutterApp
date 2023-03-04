import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/gui/gui_sections/home_page.dart';
import 'package:flutter_application/gui/gui_sections/login_page.dart';
import 'package:flutter_application/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../auth.dart';
import '../../main.dart';

class ImagePage extends StatefulWidget {
  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  File? pickedImage;
  Uint8List webImage = Uint8List(8);
  String imagePath = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.black,
            )),
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 80,
                            height: 80,
                            child: pickedImage == null
                                ? Text("No image selected",
                                    textAlign: TextAlign.center)
                                : kIsWeb
                                    ? Image.memory(webImage, fit: BoxFit.fill)
                                    : Image.file(pickedImage!,
                                        fit: BoxFit.scaleDown)),
                        ElevatedButton(
                            onPressed: selectImage,
                            child: const Text("Select Image")),
                        ElevatedButton(
                            onPressed: uploadImage,
                            child: const Text("Upload Image")),
                        ElevatedButton(
                            onPressed: downloadImage,
                            child: const Text("Download Image")),
                        Container(
                          width: 80,
                          height: 80,
                          child: imagePath == ""
                              ? Text(
                                  "No profile picture",
                                  textAlign: TextAlign.center,
                                )
                              : Image.network(imagePath, fit: BoxFit.scaleDown),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future selectImage() async {
    if (!kIsWeb) {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          pickedImage = selected;
        });
      } else {
        print('No image has been picked');
      }
    } else if (kIsWeb) {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          pickedImage = File('a');
        });
      } else {
        print('No image has been picked');
      }
    } else {
      print('Something went wrong');
    }
  }

  Future uploadImage() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    // upload file
    await FirebaseStorage.instance
        .ref('pictures/$userUid.jpg')
        .putData(webImage);

    await downloadImage();
  }

  Future<String> downloadUrl() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    String downloadUrl = await FirebaseStorage.instance
        .ref("pictures/$userUid.jpg")
        .getDownloadURL();
    return downloadUrl;
  }

  Future downloadImage() async {
    String downloadPath = await downloadUrl();
    setState(() {
      imagePath = downloadPath;
    });
    return;
  }

  // Future<ListResult> listFiles() async {
  //   final userUid = FirebaseAuth.instance.currentUser?.uid;
  //   String downloadURL = await FirebaseStorage.instance
  //       .ref("pictures/$userUid.jpg")
  //       .getDownloadURL();

  //   ListResult results =
  //       await FirebaseStorage.instance.ref('pictures').listAll();

  //   for (var ref in results.items) {
  //     print("Found file: $ref");
  //   }

  //   return results;
  // }
}

Widget makeInput({label, controller, obsureText = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      SizedBox(
        height: 5,
      ),
      TextField(
        controller: controller,
        obscureText: obsureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          border:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        ),
      ),
      SizedBox(
        height: 30,
      )
    ],
  );
}
