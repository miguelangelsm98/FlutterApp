import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/user.dart';
import 'chat_direct_page.dart';

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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(""),
        // elevation: 0,
        // backgroundColor: Colors.white,
        // leading: IconButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     icon: Icon(
        //       Icons.arrow_back_ios,
        //       size: 20,
        //       color: Colors.black,
        //     )),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              // Move to AppBar
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
                  controller: firstController,
                  itemCount: appState.users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return userWidget(
                      currentUser: appState.currentUser!,
                      user: appState.users[index],
                      appState: appState,
                    );
                  }),
              // profileWidget2(context),
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

    if (currentUser.friends.contains(user.userUid)) {
      widget = Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await currentUser.removeFriend(user);
              await appState.doGetFriends();
              await appState.doGetPosts();
            },
            child: Text("Remove Friend"),
          ),
          ElevatedButton(
            onPressed: () async {
              String relationId = currentUser.friendRelations[user.userUid]!;
              await currentUser.getMessages(relationId);
              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatDirectPage(),
                  // Pass the arguments as part of the RouteSettings. The
                  // DetailScreen reads the arguments from these settings.
                  settings: RouteSettings(
                    arguments: user,
                  ),
                ),
              );
            },
            child: Text("Chat"),
          ),
        ],
      );
    } else if (currentUser.ownRequests!.contains(user.userUid)) {
      widget = ElevatedButton(
        onPressed: () async {
          await currentUser.removeFriendRequest(user);
          await appState.doGetFriends();
        },
        child: Text("Cancel Request"),
      );
    } else if (currentUser.friendRequests!.contains(user.userUid)) {
      widget = Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await currentUser.acceptFriendRequest(user);
              await appState.doGetFriends();
              await appState.doGetPosts();
            },
            child: Text("Accept Request"),
          ),
          ElevatedButton(
            onPressed: () async {
              await currentUser.declineFriendRequest(user);
              await appState.doGetFriends();
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
        },
        child: Text("Add Friend"),
      );
    }
    return widget;
  }
}

// Widget profileWidget2(BuildContext context) {
//   var appState = context.watch<MyAppState>();
//   var imagePath = appState.currentUser!.avatarPath;

//   return Row(
//     children: [
//       SizedBox(
//           height: 60, child: Image.network(imagePath!, fit: BoxFit.scaleDown)),
//       Column(
//         children: [
//           Text(
//             "Hello " "${appState.currentUser!.name}!",
//             style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: FontWeight.w400,
//                 color: Colors.black87),
//           ),
//           MaterialButton(
//             // height: 5,
//             onPressed: () async {
//               try {
//                 await FirebaseAuth.instance.signOut();
//                 appState.doUserLogout();
//               } on FirebaseAuthException catch (e) {
//                 print(e.toString());
//               }
//             },
//             color: Color.fromARGB(255, 30, 226, 72),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
//             child: Text(
//               "Logout",
//               style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w400,
//                   color: Colors.black87),
//             ),
//           ),
//         ],
//       ),
//     ],
//   );
// }
