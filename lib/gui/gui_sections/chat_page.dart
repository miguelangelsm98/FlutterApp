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

    return Stack(
      children: [
        Positioned(
          top: 0, //display after the height of top widtet
          bottom: 100, //display untill the height of bottom widget
          left: 0, right: 0,
          child: Scaffold(
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
            body: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: <Widget>[
                    Text(
                      "${post.name} - Chat",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text("Number of messages: ${post.messages!.length}"),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 180,
          bottom: 100,
          left: 0,
          right: 0, //se
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.white,
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: SingleChildScrollView(
                reverse: true,
                physics: ScrollPhysics(),
                child: Column(
                  children: <Widget>[
                    SingleChildScrollView(
                      reverse: false,
                      child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          controller: firstController,
                          itemCount: post.messages!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return messageWidget(
                                post.messages![index], appState);
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
            //position at bottom
            bottom: 0,
            left: 0,
            right: 0, //set left right to 0 for 100% width
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: Card(
                    child: TextField(
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
                  ),
                ),
                MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () async {
                    post.addMesage(
                      messageController.text,
                      appState.currentUser!,
                    );
                    await post.getMessages();
                    firstController.animateTo(
                      firstController.position.maxScrollExtent,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 300),
                    );
                    setState(() {
                      messageController.text = "";
                    });
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
                        fontSize: 16,
                        color: Colors.white70),
                  ),
                ),
              ],
            ))
      ],
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
