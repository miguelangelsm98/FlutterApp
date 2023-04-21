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
    // final ScrollController firstController = ScrollController();

    // getUsers(appState);

    final Stream<QuerySnapshot> usersStream =
        FirebaseFirestore.instance.collection('users').snapshots();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Center(child: Text("Users")),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [Tab(icon: Text("Friends")), Tab(icon: Text("All Users"))],
          ),
        ),
        body: TabBarView(
          children: [
            // Friends Widget
            listUsersWidget(
              users: appState.friends,
              appState: appState,
            ),
            // All users Widget
            listUsersWidget(
              users: appState.users,
              appState: appState,
            )
          ],
        ),
      ),
    );
  }

  Widget listUsersWidget(
      {required List<CustomUser> users, required MyAppState appState}) {
    final ScrollController controller = ScrollController();

    if (users.isEmpty) {
      return Center(child: Text("Add a friend in users view"));
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: controller,
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return userWidget(
                      currentUser: appState.currentUser!,
                      user: users[index],
                      appState: appState,
                    );
                  }),
            ],
          ),
        ),
      );
    }
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(user.name!, textAlign: TextAlign.center),
                ),
                // Center(
                //   child: Text(user.userName!, textAlign: TextAlign.center),
                // ),
              ],
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
              // set up the buttons
              Widget cancelButton = ElevatedButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = ElevatedButton(
                child: Text("Continue"),
                onPressed: () async {
                  await currentUser.removeFriend(user);
                  await appState.doGetFriends();
                  await appState.doGetPosts();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              );
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: Text("AlertDialog"),
                content: Text("Are you sure you want to remove this friend?"),
                actions: [
                  cancelButton,
                  continueButton,
                ],
              );
              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            },
            child: Text("Remove Friend"),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  String relationId =
                      currentUser.friendRelations[user.userUid]!;
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
                child: Text("Open Chat"),
              ),
              // SizedBox(width: 10),
              // Text("+5"),
            ],
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
              Widget cancelButton = ElevatedButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = ElevatedButton(
                child: Text("Continue"),
                onPressed: () async {
                  await currentUser.acceptFriendRequest(user);
                  await appState.doGetFriends();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  await appState.doGetPosts();
                },
              );
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: Text("AlertDialog"),
                content: Text("Are you sure you want to accept this request?"),
                actions: [
                  cancelButton,
                  continueButton,
                ],
              );
              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
            },
            child: Text("Accept Request"),
          ),
          ElevatedButton(
            onPressed: () async {
              Widget cancelButton = ElevatedButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = ElevatedButton(
                child: Text("Continue"),
                onPressed: () async {
                  await currentUser.declineFriendRequest(user);
                  await appState.doGetFriends();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              );
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: Text("AlertDialog"),
                content: Text("Are you sure you want to decline this request?"),
                actions: [
                  cancelButton,
                  continueButton,
                ],
              );
              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );
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
