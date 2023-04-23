import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application/models/user.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import 'home_page.dart';
import 'package:date_time_picker/date_time_picker.dart';

import 'package:intl/intl.dart';

class UpdateUserPage extends StatefulWidget {
  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  File? pickedImage;
  Uint8List webImage = Uint8List(8);
  String imagePath = "";

  String dateTime = DateTime.now().toString();

  CustomUser user = CustomUser(email: "", password: "");

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    user = appState.currentUser!;

    var nameController = TextEditingController(text: user.name);
    var userNameController = TextEditingController(text: user.userName);

    if (user.birthDate != null) {
      dateTime = user.birthDate.toString();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            SizedBox(
                height: 150,
                width: 150,
                child: pickedImage == null
                    ? Image.network(user.avatarPath!, fit: BoxFit.contain)
                    : kIsWeb
                        ? Image.memory(webImage, fit: BoxFit.contain)
                        : Image.file(pickedImage!, fit: BoxFit.contain)),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: selectImage, child: const Text("Select Image")),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  makeInput(
                      label: "User Name (Cannot Change)",
                      controller: userNameController,
                      enabled: false,
                      filled: true),
                  makeInput(label: "Full Name", controller: nameController),
                  DateTimePicker(
                    type: DateTimePickerType.date,
                    dateMask: 'dd-MM-yyyy',
                    initialValue: dateTime,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                    dateLabelText: 'Birth Date',
                    onChanged: (val) => dateTime = val,
                    validator: (val) {
                      print(val);
                      return null;
                    },
                    onSaved: (val) => print(val),
                  ),
                  SizedBox(
                    height: 30,
                  ),
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
                    Widget cancelButton = ElevatedButton(
                      child: Text("Cancel"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    );
                    Widget continueButton = ElevatedButton(
                      child: Text("Continue"),
                      onPressed: () async {
                        if (pickedImage != null) {
                          user.updateAvatarPath(webImage);                          
                        }
                        user.name = nameController.text;
                        user.userName = userNameController.text;
                        user.birthDate = DateTime.parse(dateTime);
                        user.saveDatabase();
                        // setState(() {});
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyHomePage()));
                        // ignore: use_build_context_synchronously
                        // Navigator.pop(context);
                      },
                    );
                    // set up the AlertDialog
                    AlertDialog alert = AlertDialog(
                      title: Text("AlertDialog"),
                      content: Text(
                          "Are you sure you want to update the information?"),
                      actions: [
                        cancelButton,
                        continueButton,
                      ],
                    );
                    // show the dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
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
        File? croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          maxWidth: 1080,
          maxHeight: 1080,
          aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        );
        var f = await croppedImage?.readAsBytes();
        var selected = File((croppedImage?.path)!);
        setState(() {
          pickedImage = selected;
          webImage = f!;
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
}

Widget makeInput({
  label,
  controller,
  obsureText = false,
  enabled = true,
  filled = false,
}) {
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
            enabled: enabled,
            filled: filled,
            fillColor: Color.fromARGB(255, 230, 227, 227)),
      ),
      SizedBox(
        height: 30,
      )
    ],
  );
}
