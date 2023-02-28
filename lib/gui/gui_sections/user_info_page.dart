import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/gui/gui_sections/home_page.dart';
import 'package:flutter_application/gui/gui_sections/login_page.dart';
import 'package:flutter_application/models/user.dart';
import 'package:provider/provider.dart';

import '../../auth.dart';
import '../../main.dart';

class UserInfoPage extends StatefulWidget {
  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final nameController = TextEditingController();
    final surnameController = TextEditingController();
    final photoController = TextEditingController();

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
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(
                  //       "Add additional information",
                  //       style: TextStyle(
                  //         fontSize: 30,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       height: 20,
                  //     ),
                  //     Text(
                  //       "User info",
                  //       style: TextStyle(
                  //         fontSize: 15,
                  //         color: Colors.grey[700],
                  //       ),
                  //     ),
                  //     SizedBox(
                  //       height: 30,
                  //     )
                  //   ],
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 40),
                  //   child: Column(
                  //     children: [
                  //       makeInput(label: "Name", controller: nameController),
                  //       makeInput(
                  //           label: "Surname", controller: surnameController),
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (pickedFile != null)
                          Expanded(
                            child: Container(
                              color: Colors.blue[200],
                              child: Center(
                                  child: Image.file(
                                File(pickedFile!.path!),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )),
                            ),
                          ),
                        ElevatedButton(
                            onPressed: selectFile,
                            child: const Text("Select File")),
                        ElevatedButton(
                            onPressed: uploadFile,
                            child: const Text("Upload FIle")),
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 40),
                  //   child: Container(
                  //     padding: EdgeInsets.only(top: 3, left: 3),
                  //     decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(40),
                  //         border: Border(
                  //             bottom: BorderSide(color: Colors.black),
                  //             top: BorderSide(color: Colors.black),
                  //             right: BorderSide(color: Colors.black),
                  //             left: BorderSide(color: Colors.black))),
                  //     child: MaterialButton(
                  //       minWidth: double.infinity,
                  //       height: 60,
                  //       onPressed: () {},
                  //       color: Colors.redAccent,
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(40)),
                  //       child: Text(
                  //         "Add user info",
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.w600,
                  //           fontSize: 16,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future uploadFile() async {
    final path = 'files/image.jpg';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() => {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
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
