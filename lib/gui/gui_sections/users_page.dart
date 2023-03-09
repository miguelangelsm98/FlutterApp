import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/user.dart';

class UsersPage extends StatefulWidget {
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final ScrollController _firstController = ScrollController();

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
                "Users",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Check all the users",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: _firstController,
                  itemCount: appState.users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return userWidget(user: appState.users[index]);
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

Widget userWidget({required CustomUser user}) {
  return Column(children: [
    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 10,
      ),
      SizedBox(
          height: 100,
          child: Image.network(user.avatarPath!, fit: BoxFit.scaleDown)),
      SizedBox(
        width: 10,
      ),
      SizedBox(
          height: 100,
          child: Center(
            child: Text("${user.name} ${user.lastName!}",
                textAlign: TextAlign.center),
          )),
      SizedBox(
        width: 10,
      ),
    ]),
    SizedBox(
      height: 25,
    ),
  ]);
}
