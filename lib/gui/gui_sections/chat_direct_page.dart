import 'package:flutter/material.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/models/user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class ChatDirectPage extends StatefulWidget {
  const ChatDirectPage({super.key});

  @override
  State<ChatDirectPage> createState() => _ChatDirectPageState();
}

class _ChatDirectPageState extends State<ChatDirectPage> {
  TextEditingController messageController = TextEditingController();
  String currentDay = "";

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final ScrollController firstController = ScrollController();
    currentDay = "";

    CustomUser friend =
        ModalRoute.of(context)!.settings.arguments as CustomUser;
    String relationId = appState.currentUser!.friendRelations[friend.userUid]!;

    // List<Map<String, dynamic>>? messages;
    // messages = appState.currentUser!.getMessages(relationId)
    //     as List<Map<String, dynamic>>?;

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
        title: Text("Chat - ${friend.name}"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                reverse: true,
                shrinkWrap: true,
                controller: firstController,
                itemCount:
                    appState.currentUser!.friendMessages[relationId]!.length,
                itemBuilder: (BuildContext context, int index) {
                  return messageWidget(
                      appState.currentUser!.friendMessages[relationId]![
                          (appState.currentUser!.friendMessages[relationId]
                                  ?.length)! -
                              index -
                              1],
                      appState,
                      (appState.currentUser!.friendMessages[relationId]
                              ?.length)! -
                          index -
                          1);
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
                    appState.currentUser?.addMesage(
                      messageController.text,
                      relationId,
                    );
                    await appState.currentUser!.getMessages(relationId);
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
                    "Send",
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
                    Text("${message['userName']}"),
                    Text("${message['message']}"),
                    dateWidget(DateTime.parse(message['createdDate'])),
                  ]),
                ],
              ),
            ],
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
        currentDay = date;
        return Column(
          children: [
            SizedBox(height: 15),
            Text(currentDay),
            SizedBox(height: 15),
            widget,
          ],
        );
      } else if (date != currentDay) {
        String dateToPrint = currentDay;
        currentDay = date;
        return Column(children: [
          SizedBox(height: 15),
          Text(currentDay),
          SizedBox(height: 15),
          widget,
          SizedBox(height: 15),
          Text(dateToPrint),
          SizedBox(height: 15),
        ]);
      } else {
        return Column(
          children: [
            SizedBox(height: 15),
            Text(currentDay),
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
