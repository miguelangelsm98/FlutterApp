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

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Center(child: Text("Usuarios")),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [Tab(icon: Text("Amigos")), Tab(icon: Text("Todos los usuarios"))],
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
      return Center(child: Text("Añada un amigo"));
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
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            width: 10,
          ),
          Container(
              width: 70.0,
              height: 70.0,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(user.avatarPath!)))),
          SizedBox(
            width: 10,
          ),
          Center(
            child: Text(user.name!, textAlign: TextAlign.center),
          ),
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
      ),
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
              Widget cancelButton = ElevatedButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = ElevatedButton(
                child: Text("Continuar"),
                onPressed: () async {
                  await currentUser.removeFriend(user);
                  await appState.doGetFriends();
                  await appState.doGetPosts();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              );
              AlertDialog alert = AlertDialog(
                title: Text("Mensaje"),
                content: Text("¿Está seguro de que desea borrar este amigo?"),
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
            child: Text("Borrar amigo"),
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

                      settings: RouteSettings(
                        arguments: user,
                      ),
                    ),
                  );
                },
                child: Text("Abrir chat"),
              ),
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
        child: Text("Cancelar petición"),
      );
    } else if (currentUser.friendRequests!.contains(user.userUid)) {
      widget = Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              Widget cancelButton = ElevatedButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = ElevatedButton(
                child: Text("Continuar"),
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
                title: Text("Mensaje"),
                content: Text("¿Está seguro de que desea aceptar esta petición?"),
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
            child: Text("Aceptar petición"),
          ),
          ElevatedButton(
            onPressed: () async {
              Widget cancelButton = ElevatedButton(
                child: Text("Cancelar"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = ElevatedButton(
                child: Text("Continuar"),
                onPressed: () async {
                  await currentUser.declineFriendRequest(user);
                  await appState.doGetFriends();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              );
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: Text("Mensaje"),
                content: Text("¿Está seguro de que desea rechazar esta petición?"),
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
            child: Text("Rechazar petición"),
          ),
        ],
      );
    } else {
      widget = ElevatedButton(
        onPressed: () async {
          await currentUser.addFriendRequest(user);
          await appState.doGetFriends();
        },
        child: Text("Añadir amigo"),
      );
    }
    return widget;
  }
}