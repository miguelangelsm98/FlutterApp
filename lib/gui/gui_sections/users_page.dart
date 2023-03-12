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
  var listener;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final ScrollController firstController = ScrollController();

    // getUsers(appState);

    final Stream<QuerySnapshot> usersStream =
        FirebaseFirestore.instance.collection('users').snapshots();

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
              // StreamBuilder<QuerySnapshot>(
              //     stream: usersStream,
              //     builder: (context, snapshot) {
              //       if (snapshot.hasError) {
              //         return Text('Something went wrong');
              //       }
              //       if (snapshot.connectionState == ConnectionState.waiting) {
              //         return Text("Loading");
              //       }
              //       return

              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: firstController,
                  itemCount: appState.users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return userWidget(
                      currentUser: appState.currentUser!,
                      user: appState.users[index],
                      appState: appState,
                    );
                  }),

              // }),
            ],
          ),
        ),
      ),
    );
  }

  Widget userWidget(
      {required CustomUser currentUser,
      required CustomUser user,
      required MyAppState appState}) {
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
        SizedBox(
          height: 100,
          child: Center(
            child: friendWidget(
                currentUser: currentUser, user: user, appState: appState),
          ),
        ),
      ]),
      SizedBox(
        height: 25,
      ),
    ]);
  }

  Widget friendWidget(
      {required CustomUser currentUser,
      required CustomUser user,
      required MyAppState appState}) {
    Widget widget;

    print("My own requests: ${currentUser.ownRequests}");
    print("My friend requests: ${currentUser.friendRequests}");
    print("My friends: ${currentUser.friends}");

    if (currentUser.friends.contains(user.userUid)) {
      widget = Text("Already a friend!!");
    } else if (currentUser.ownRequests.contains(user.userUid)) {
      widget = Text("Already sent friend request");
    } else if (currentUser.friendRequests.contains(user.userUid)) {
      widget = Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              await currentUser.acceptFriendRequest(user);
              await appState.doGetFriends();
              // setState(() {});
            },
            child: Text("Accept Request"),
          ),
          ElevatedButton(
            onPressed: () async {
              await currentUser.declineFriendRequest(user);
              await appState.doGetFriends();
              // setState(() {});
            },
            child: Text("Decline Request"),
          ),
        ],
      );
    } else {
      widget = ElevatedButton(
        onPressed: () async {
          await currentUser.addFriendRequest(user);
          await appState.doGetFriends();
          // setState(() {});
        },
        child: Text("Send friend request"),
      );
    }
    return widget;
  }

  // void getUsers(MyAppState appState) {
  //   final users = FirebaseFirestore.instance.collection("users").withConverter(
  //       fromFirestore: CustomUser.fromFirestore,
  //       toFirestore: (CustomUser user, options) => user.toFirestore());

  //   listener = users.snapshots().listen((event) async {
  //     print("There was a change");
  //     await appState.doGetUsers();
  //     await appState.doGetFriends();
  //   });

  //   List<CustomUser> usersList(QuerySnapshot snapshot) {
  //     return snapshot.docs.map((doc) {
  //       return CustomUser.fromFirestore(doc, null);
  //     }).toList();
  //   }
  // }
}
