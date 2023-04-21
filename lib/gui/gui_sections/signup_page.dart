import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/gui/gui_sections/home_page.dart';
import 'package:flutter_application/gui/gui_sections/update_user_page.dart';
import 'package:flutter_application/models/user.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

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
import 'package:date_time_picker/date_time_picker.dart';

const defaultAvatarPath =
    "https://firebasestorage.googleapis.com/v0/b/tfg-project-a9320.appspot.com/o/pictures%2Fprofile1.png?alt=media&token=6edb382b-14d5-47f2-a17e-d274624c3e89";

class SignupPage extends StatefulWidget {
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController password1Controller = TextEditingController();
  TextEditingController password2Controller = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  String dateTime = DateTime(1900).toString();

  // String dateIso = "";

  File? pickedImage;
  Uint8List webImage = Uint8List(8);
  String imagePath = "";

  // CustomUser user = CustomUser(email: "", password: "");

  @override
  void initState() {
    emailController.text = "@gmail.com"; // For testing purposes
    password1Controller.text = "123123"; // For testing purposes
    password2Controller.text = "123123"; // For testing purposes

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // user = appState.currentUser!;

    // var nameController = TextEditingController(text: user.name);
    // var lastNameController = TextEditingController(text: user.lastName);
    // var dateController = TextEditingController(
    //     text: DateFormat('dd-MM-yyyy').format(user.birthDate!));
    // var dateIso = user.birthDate!.toIso8601String();
    // DateTime? pickedDate = DateTime(1900, 1, 1);
    // dateIso = pickedDate.toIso8601String();
    // DateTime? pickedDate = DateTime.now();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              appState.changeSelectedIndex(0);
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
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Sign up",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Create an Account",
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  makeInput(label: "Email", controller: emailController),
                  makeInput(
                      label: "Password",
                      controller: password1Controller,
                      obsureText: true),
                  makeInput(
                      label: "Confirm Pasword",
                      controller: password2Controller,
                      obsureText: true),
                  makeInput(label: "Full Name", controller: nameController),
                  makeInput(
                    label: "User Name",
                    controller: userNameController,
                  ),
                  DateTimePicker(
                    type: DateTimePickerType.date,
                    dateMask: 'dd-MM-yyyy',
                    initialValue: '',
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
                    if (password1Controller.text == password2Controller.text) {
                      try {
                        CustomUser u = CustomUser(
                            email: emailController.text,
                            password: password1Controller.text);
                        u.name = nameController.text;
                        u.userName = userNameController.text;
                        u.birthDate = DateTime.parse(dateTime);
                        await u.signUp();
                        await appState.doUserLogin();
                      } on FirebaseAuthException catch (e) {
                        Widget okButton = ElevatedButton(
                          child: Text("Ok"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        );

                        // set up the AlertDialog
                        AlertDialog alert = AlertDialog(
                          title: Text("AlertDialog"),
                          content: Text(e.message.toString()),
                          actions: [
                            okButton,
                          ],
                        );
                        // show the dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return alert;
                          },
                        );
                      }
                    } else {
                      print("Passwords are not equal");
                    }
                  },
                  color: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account? "),
                MaterialButton(
                  onPressed: () async {
                    appState.changeSelectedIndex(0);
                  },
                  child: Text(
                    "Log In",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
              ],
            )
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
