import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/post.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/user.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final ScrollController firstController = ScrollController();

    final post = ModalRoute.of(context)!.settings.arguments as Post;
    final messageController = TextEditingController();

    // getUsers(appState);

    // final Stream<QuerySnapshot> usersStream =
    //     FirebaseFirestore.instance.collection('users').snapshots();

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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              Text(
                "Chat",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text("Number of messages: ${post.messages!.length}"),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: firstController,
                  itemCount: post.messages!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return messageWidget(post.messages![index], appState);
                  }),
              SizedBox(
                height: 30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: messageController,
                    obscureText: false,
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
              MaterialButton(
                minWidth: double.infinity,
                height: 60,
                onPressed: () async {
                  post.addMesage(
                      messageController.text,
                      appState.currentUser!.userUid!,
                      appState.currentUser!.avatarPath!);
                  await post.getMessages();
                  setState(() {});
                },
                color: Colors.indigoAccent[400],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
                child: Text(
                  "Add Message",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messageWidget(Map<String, dynamic> message, MyAppState appState) {
    Widget widget;
    MainAxisAlignment allignment;

    if (message['userUid'] == appState.currentUser!.userUid) {
      allignment = MainAxisAlignment.end;
    } else {
      allignment = MainAxisAlignment.start;
    }

    widget = Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        child: Row(
          mainAxisAlignment: allignment,
          children: [
            Column(children: [
              SizedBox(
                  height: 100,
                  child: Image.network(message['userAvatarPath'],
                      fit: BoxFit.scaleDown)),
              Text("Owner: ${message['userUid']}"),
              Text("Created Date: ${message['createdDate']}"),
              Text("Message: ${message['message']}"),
            ]),
          ],
        ));

    return widget;
  }
}
