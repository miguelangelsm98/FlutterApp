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
                            child: pickedImage == null
                                ? Text("No image selected")
                                : kIsWeb
                                    ? Image.memory(webImage, fit: BoxFit.fill)
                                    : Image.file(pickedImage!,
                                        fit: BoxFit.fill)),
                        ElevatedButton(
                            onPressed: selectImage,
                            child: const Text("Select File")),
                        ElevatedButton(
                            onPressed: uploadImage,
                            child: const Text("Upload FIle")),
                        ElevatedButton(
                            onPressed: downloadImage,
                            child: const Text("Download Image")),
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

  Future uploadImage() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    // upload file
    await FirebaseStorage.instance.ref('pictures/$userUid').putData(webImage);
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

  Future downloadImage() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    final storageRef = FirebaseStorage.instance.ref();
    final pathReference = storageRef.child("pictures/$userUid");

    // Create a reference to a file from a Google Cloud Storage URI
    final gsReference = FirebaseStorage.instance
        .refFromURL("gs://YOUR_BUCKET/images/stars.jpg");

    // Create a reference from an HTTPS URL
    // Note that in the URL, characters are URL escaped!
    final httpsReference = FirebaseStorage.instance.refFromURL(
        "https://firebasestorage.googleapis.com/b/YOUR_BUCKET/o/images%20stars.jpg");

    final islandRef = storageRef.child("pictures/$userUid");

    try {
      const oneMegabyte = 1024 * 1024;
      final Uint8List? data =
          await FirebaseStorage.instance.ref('pictures/$userUid').getData();
      // Data for "images/island.jpg" is returned, use this as needed.
      if (data != null) {
        setState(() {
          webImage = data;
          pickedImage = File('a');
        });
      }
    } on FirebaseException catch (e) {
      // Handle any errors.
    }

    // final userUid = FirebaseAuth.instance.currentUser?.uid;

    // var image =
    //     await FirebaseStorage.instance.ref('pictures/$userUid').getData();
    // if (image != null) {
    //   setState(() {
    //     webImage = image;
    //     pickedImage = File('a');
    //   });
    // }
  }
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
