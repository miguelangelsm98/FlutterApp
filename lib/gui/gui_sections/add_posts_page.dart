// import 'dart:html';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/post.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

import 'package:intl/intl.dart';

import 'home_page.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';

const defaultPicturePath =
    "https://firebasestorage.googleapis.com/v0/b/tfg-project-a9320.appspot.com/o/pictures%2Fpicture1.jpg?alt=media&token=43ccd598-d79f-4c2b-93a5-2ccc773553cc";

class PostsAddPage extends StatefulWidget {
  @override
  State<PostsAddPage> createState() => _PostsAddPageState();
}

class _PostsAddPageState extends State<PostsAddPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String dateTime = DateTime.now().toString();

  File? pickedImage;
  Uint8List webImage = Uint8List(8);
  String imagePath = "";

  // var dateController = TextEditingController(
  //     text: DateFormat('dd-MM-yyyy').format(DateTime.now()));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    // DateTime? pickedDate = DateTime.now();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Add new Post"),
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
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                height: 150,
                child: pickedImage == null
                    ? Image.network(defaultPicturePath, fit: BoxFit.scaleDown)
                    : kIsWeb
                        ? Image.memory(webImage, fit: BoxFit.fill)
                        : Image.file(pickedImage!, fit: BoxFit.scaleDown)),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: selectImage, child: const Text("Select Image")),
              ],
            ),
            // Text(
            //   "Add Posts",
            //   style: TextStyle(
            //     fontSize: 30,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            // Text(
            //   "Create a Post with Name and Description",
            //   style: TextStyle(
            //     fontSize: 15,
            //     color: Colors.grey[700],
            //   ),
            // ),
            // SizedBox(
            //   height: 30,
            // ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  makeInput(label: "Name", controller: nameController),
                  makeInput(
                    label: "Description",
                    controller: descriptionController,
                  ),
                  DateTimePicker(
                    type: DateTimePickerType.dateTime,
                    dateMask: 'dd-MM-yyyy hh:mm',
                    initialValue: '',
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    dateLabelText: 'Activity Date',
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
                    Post post = Post(
                        name: nameController.text,
                        description: descriptionController.text,
                        userUid: appState.currentUser?.userUid,
                        createdDate: DateTime.now(),
                        postDate: DateTime.parse(dateTime));
                    await post.addPost();
                    if (pickedImage != null) {
                      await FirebaseStorage.instance
                          .ref('pictures/${post.postUid}')
                          .putData(webImage);
                      post.picturePath = await FirebaseStorage.instance
                          .ref("pictures/${post.postUid}")
                          .getDownloadURL();
                    }
                    await post.saveDatabase();
                    await appState.doGetPosts();

                    Widget okButton = ElevatedButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyHomePage()));
                      },
                    );
                    // set up the AlertDialog
                    AlertDialog alert = AlertDialog(
                      title: Text("AlertDialog"),
                      content: Text("Post successfully created"),
                      actions: [
                        okButton,
                      ],
                    );
                    // show the dialog
                    // ignore: use_build_context_synchronously
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
                    "Create Post",
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
