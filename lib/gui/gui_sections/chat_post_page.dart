import 'package:flutter/material.dart';
import 'package:flutter_application/models/post.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class ChatPostPage extends StatefulWidget {
  const ChatPostPage({super.key});

  @override
  State<ChatPostPage> createState() => _ChatPostPageState();
}

class _ChatPostPageState extends State<ChatPostPage> {
  TextEditingController messageController = TextEditingController();
  String currentDay = "";

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final ScrollController firstController = ScrollController();
    currentDay = "";

    final post = ModalRoute.of(context)!.settings.arguments as Post;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      // todo appbar
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
        title: Text("Chat - ${post.name}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                reverse: true,
                shrinkWrap: true,
                controller: firstController,
                itemCount: post.messages!.length,
                itemBuilder: (BuildContext context, int index) {
                  return messageWidget(
                      post.messages![post.messages!.length - index - 1],
                      appState,
                      post.messages!.length - index - 1);
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
                MaterialButton(
                  height: 40,
                  onPressed: () async {
                    post.addMesage(
                      messageController.text,
                      appState.currentUser!,
                    );
                    await post.getMessages();
                    setState(() {
                      messageController.text = "";
                    });
                    // ignore: use_build_context_synchronously
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                  color: Colors.indigoAccent[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Text(
                    "Enviar",
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

  Widget messageWidget(
      Map<String, dynamic> message, MyAppState appState, int index) {
    Widget widget;

    if (message['userUid'] == appState.currentUser!.userUid) {
      widget = Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Column(children: [
                      Text("${message['userName']}"),
                      Text("${message['message']}"),
                      dateWidget(DateTime.parse(message['createdDate'])),
                    ]),
                    Container(
                        width: 90.0,
                        height: 90.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image:
                                    NetworkImage(message['userAvatarPath'])))),
                  ],
                ),
              ],
            ),
          ));
    } else {
      widget = Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                        width: 90.0,
                        height: 90.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image:
                                    NetworkImage(message['userAvatarPath'])))),
                    Column(children: [
                      Text("${message['userName']}"),
                      Text("${message['message']}"),
                      dateWidget(DateTime.parse(message['createdDate'])),
                    ]),
                  ],
                ),
              ],
            ),
          ));
    }
    return appendDateWidget(
        widget,
        DateFormat('dd-MM-yyyy').format(DateTime.parse(message['createdDate'])),
        index);    
  }

  Widget appendDateWidget(Widget widget, String date, int index) {
    if (index != 0) {
      if (currentDay == "") {
        currentDay = date;
        return widget;
      } else if (date != currentDay) {
        String dateToPrint = currentDay;
        currentDay = date;
        return Column(children: [
          widget,
          SizedBox(height: 15),
          Text(dateToPrint),
          SizedBox(height: 15),
        ]);
      } else {
        return widget;
      }
    } else {
      if (currentDay == "") {
        return Column(
          children: [
            SizedBox(height: 15),
            Text(date),
            SizedBox(height: 15),
            widget,
          ],
        );
      } else if (date != currentDay) {
        String dateToPrint = currentDay;
        // currentDay = date;
        currentDay = "";
        return Column(children: [
          SizedBox(height: 15),
          Text(date),
          SizedBox(height: 15),
          widget,
          SizedBox(height: 15),
          Text(dateToPrint),
          SizedBox(height: 15),
        ]);
      } else {
        currentDay = "";
        return Column(
          children: [
            SizedBox(height: 15),
            Text(date),
            SizedBox(height: 15),
            widget,
          ],
        );
      }
    }
  }

  Widget dateWidget(DateTime messageDate) {
    Widget widget;
    if ((messageDate.hour < 10) && (messageDate.minute < 10)) {
      widget = Text("0${messageDate.hour}:0${messageDate.minute}");
    } else if (messageDate.hour < 10) {
      widget = Text("0${messageDate.hour}:${messageDate.minute}");
    } else if (messageDate.minute < 10) {
      widget = Text("${messageDate.hour}:0${messageDate.minute}");
    } else {
      widget = Text("${messageDate.hour}:${messageDate.minute}");
    }
    return widget;
  }
}
