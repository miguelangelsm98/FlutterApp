import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import 'home_page.dart';

import 'package:intl/intl.dart';

class UpdateUserPage extends StatefulWidget {
  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  File? pickedImage;
  Uint8List webImage = Uint8List(8);
  String imagePath = "";

  CustomUser user = CustomUser(email: "", password: "");

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    user = appState.currentUser!;

    var nameController = TextEditingController(text: user.name);
    var lastNameController = TextEditingController(text: user.lastName);
    var dateController = TextEditingController(
        text: DateFormat('dd-MM-yyyy').format(user.birthDate!));
    var dateIso = user.birthDate!.toIso8601String();
    DateTime? pickedDate = DateTime.now();

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
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          children: [
            Column(
              children: [
                Text(
                  "Add User Information",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Introduce your information",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(
                  height: 30,
                )
              ],
            ),
            SizedBox(
              // height: MediaQuery.of(context).size.height,
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
                            SizedBox(
                                height: 150,
                                child: pickedImage == null
                                    ? Image.network(user.avatarPath!,
                                        fit: BoxFit.scaleDown)
                                    : kIsWeb
                                        ? Image.memory(webImage,
                                            fit: BoxFit.fill)
                                        : Image.file(pickedImage!,
                                            fit: BoxFit.scaleDown)),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                    onPressed: selectImage,
                                    child: const Text("Select Image")),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  makeInput(label: "Name", controller: nameController),
                  makeInput(
                    label: "Last Name",
                    controller: lastNameController,
                  ),
                  TextField(
                      controller:
                          dateController, //editing controller of this TextField
                      decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today), //icon of text field
                          labelText: "Enter Birth Date" //label text of field
                          ),
                      readOnly: true, // when true user cannot edit text
                      onTap: () async {
                        pickedDate = await showDatePicker(
                            context: context,
                            initialDate: pickedDate!, //get today's date
                            firstDate: DateTime(
                                1910), //DateTime.now() - not to allow to choose before today.
                            lastDate: DateTime(2100));
                        if (pickedDate != null) {
                          String formattedDate = DateFormat('dd-MM-yyyy').format(
                              pickedDate!); // format date in required form here we use yyyy-MM-dd that means time is removed
                          dateController.text = formattedDate;
                          dateIso = pickedDate!.toIso8601String();
                        }

                        // setState(() {
                        //   dateFormatted = pickedDate.toIso8601String();
                        // }); //set foratted date to TextField value.

                        //when click we have to show the datepicker
                      })
                  // makeInput(
                  //   label: "Birth Date",
                  //   controller: birthDateController,
                  // ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: EdgeInsets.only(top: 3, left: 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border(
                        bottom: BorderSide(color: Colors.black),
                        top: BorderSide(color: Colors.black),
                        right: BorderSide(color: Colors.black),
                        left: BorderSide(color: Colors.black))),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () async {
                    if (pickedImage != null) {
                      await FirebaseStorage.instance
                          .ref('pictures/${user.userUid}')
                          .putData(webImage);
                      user.avatarPath = await FirebaseStorage.instance
                          .ref("pictures/${user.userUid}")
                          .getDownloadURL();
                    }
                    user.name = nameController.text;
                    user.lastName = lastNameController.text;
                    user.birthDate = DateTime.parse(dateIso);
                    user.saveDatabase();
                    setState(() {});
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => MyHomePage()));
                  },
                  color: Colors.indigoAccent[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Text(
                    "Update user",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white70),
                  ),
                ),
              ),
            ),
          ],
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

  // Future uploadImage() async {
  //   // upload file
  //   await FirebaseStorage.instance
  //       .ref('pictures/${user.userUid}')
  //       .putData(webImage);
  //   user.avatarPath = await FirebaseStorage.instance
  //       .ref("pictures/${user.userUid}")
  //       .getDownloadURL();
  //   await user.saveDatabase();
  //   setState(() {});
  //   Navigator.of(context)
  //       .push(MaterialPageRoute(builder: (context) => MyHomePage()));
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
