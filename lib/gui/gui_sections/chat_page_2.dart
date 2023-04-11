import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/post.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/user.dart';

class ChatPage2 extends StatefulWidget {
  const ChatPage2({super.key});

  @override
  State<ChatPage2> createState() => _ChatPageState2();
}

class _ChatPageState2 extends State<ChatPage2> {
  TextEditingController messageController = TextEditingController();

  // @override
  // void initState() {
  //   messageController.text = "Write a message"; // For testing purposes
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final ScrollController firstController = ScrollController();

    final post = ModalRoute.of(context)!.settings.arguments as Post;

    // getUsers(appState);

    // final Stream<QuerySnapshot> usersStream =
    //     FirebaseFirestore.instance.collection('users').snapshots();

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
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
                // physics: NeverScrollableScrollPhysics(),
                reverse: true,
                shrinkWrap: true,
                controller: firstController,
                itemCount: post.messages!.length,
                itemBuilder: (BuildContext context, int index) {
                  return messageWidget(
                      post.messages![post.messages!.length - index - 1],
                      appState);
                }),
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    obscureText: false,
                    // decoration: InputDecoration(
                    //   contentPadding:
                    //       EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    //   enabledBorder: OutlineInputBorder(
                    //     borderSide: BorderSide(
                    //       color: Colors.grey,
                    //     ),
                    //   ),
                    //   border: OutlineInputBorder(
                    //       borderSide: BorderSide(color: Colors.grey)),
                    // ),
                  ),
                ),
                MaterialButton(
                  // minWidth: double.infinity,
                  // height: 40,
                  onPressed: () async {
                    post.addMesage(
                      messageController.text,
                      appState.currentUser!,
                    );
                    await post.getMessages();

                    // firstController.animateTo(
                    //   firstController.position.maxScrollExtent,
                    //   curve: Curves.easeOut,
                    //   duration: const Duration(milliseconds: 300),
                    // );
                    setState(() {
                      messageController.text = "";
                    });
                    // if (firstController.hasClients) {
                    //   final position =
                    //       firstController.position.maxScrollExtent + 1;
                    //   firstController.jumpTo(position);
                    // }

                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }

                    // firstController
                    //     .jumpTo(firstController.position.maxScrollExtent);
                  },
                  color: Colors.indigoAccent[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Text(
                    "Add Message",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        // fontSize: 16,
                        color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget messageWidget(Map<String, dynamic> message, MyAppState appState) {
    Widget widget;
    MainAxisAlignment allignment;

    DateTime messageDate = DateTime.parse(message['createdDate']);

    if (message['userUid'] == appState.currentUser!.userUid) {
      widget = Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Column(children: [
                    Text("${message['userName']} ${message['userLastName']}"),
                    Text("${message['message']}"),
                    Text("${messageDate.hour}:${messageDate.minute}"),
                  ]),
                  SizedBox(
                      height: 100,
                      child: Image.network(message['userAvatarPath'],
                          fit: BoxFit.scaleDown)),
                ],
              ),
            ],
          ));
    } else {
      widget = Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                      height: 100,
                      child: Image.network(message['userAvatarPath'],
                          fit: BoxFit.scaleDown)),
                  Column(children: [
                    Text("${message['userName']} ${message['userLastName']}"),
                    Text("${message['message']}"),
                    Text("${messageDate.hour}:${messageDate.minute}"),
                  ]),
                ],
              ),
            ],
          ));
    }
    return widget;
  }
}
