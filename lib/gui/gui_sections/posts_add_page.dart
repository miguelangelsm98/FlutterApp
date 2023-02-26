import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/post.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class PostsAddPage extends StatefulWidget {
  @override
  State<PostsAddPage> createState() => _PostsAddPageState();
}

class _PostsAddPageState extends State<PostsAddPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

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
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Column(
                  children: [
                    Text(
                      "Posts",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Create a Post with Name and Description",
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      makeInput(label: "Name", controller: nameController),
                      makeInput(
                        label: "Description",
                        controller: descriptionController,
                      )
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
                            nameController.text, descriptionController.text, FirebaseAuth.instance.currentUser?.uid,);
                        post.save();
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
          ],
        ),
      ),
    );
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
