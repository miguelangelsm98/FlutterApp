import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/post.dart';
import 'add_posts_page.dart';
import 'chat_post_page.dart';

import 'package:intl/intl.dart';

class PostsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Center(child: Text("Actividades")),
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Text("Públicas")),
                Tab(icon: Text("De amigos")),
                Tab(icon: Text("Mías"))
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            elevation: 10.0,
            backgroundColor: Colors.green,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PostsAddPage(),
                  ));
            },
            child: Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          body: TabBarView(
            children: [
              // Public Posts Widget
              listPostsWidget(
                  posts: appState.publicPosts,
                  appState: appState,
                  context: context),
              // Friends Posts Widget
              listPostsWidget(
                  posts: appState.friendsPosts,
                  appState: appState,
                  context: context),
              // My posts Widget
              listPostsWidget(
                  posts: appState.myPosts,
                  appState: appState,
                  context: context),
            ],
          ),
        ));
  }

  Widget listPostsWidget(
      {required List<Post> posts,
      required MyAppState appState,
      required BuildContext context}) {
    final ScrollController controller = ScrollController();

    if (posts.isEmpty) {
      return Center(child: Text("No hay actividades"));
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        // width: double.infinity,
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: controller,
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return createPost(posts[index], appState, context);
                  }),
            ],
          ),
        ),
      );
    }
  }

  Widget createPost(Post p, MyAppState appState, BuildContext context) {
    Widget widget = Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        // height: 400,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: Image.network(p.picturePath!, fit: BoxFit.scaleDown),
                  ),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            p.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(DateFormat('dd-MM-yyyy – kk:mm')
                              .format(p.postDate!)),
                          Text(p.user!.userName!),
                          Text("Usuarios registrados: ${p.users!.length}"),
                        ]),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(p.description!),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  joinActivityWidget(p, appState, context),
                ],
              ),
            ],
          ),
        ));

    return widget;
  }

  Widget joinActivityWidget(Post p, MyAppState appState, BuildContext context) {
    Widget widget;

    if (p.userUid == appState.currentUser!.userUid) {
      widget = Row(
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
                  await p.remove();
                  appState.doGetPosts();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              );
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: Text("Mensaje"),
                content: Text("¿Seguro que quiere eliminar la actividad?"),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              // textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
            ),
            child: Text("Eliminar actividad"),
          ),
          ElevatedButton(
            onPressed: () async {
              await p.getMessages();
              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatPostPage(),
                  // Pass the arguments as part of the RouteSettings. The
                  // DetailScreen reads the arguments from these settings.
                  settings: RouteSettings(
                    arguments: p,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              // textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
            ),
            child: Text("Abrir chat"),
          ),
        ],
      );
    } else if (!p.users!.contains(appState.currentUser!.userUid)) {
      widget = ElevatedButton(
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
              p.users?.add(appState.currentUser!.userUid!);
              p.saveDatabase();
              appState.doGetPosts();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
          );
          // set up the AlertDialog
          AlertDialog alert = AlertDialog(
            title: Text("Mensaje"),
            content: Text("¿Seguro que quiere unirse a la actividad?"),
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
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          // textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
        ),
        child: Text("Unirse a actividad"),
      );
    } else {
      widget = Row(
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
                  p.users?.remove(appState.currentUser!.userUid!);
                  p.saveDatabase();
                  appState.doGetPosts();

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              );
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: Text("Mensaje"),
                content: Text("¿Seguro que quiere abandonar la actividad?"),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              // textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
            ),
            child: Text("Abandonar actividad"),
          ),
          ElevatedButton(
            onPressed: () async {
              await p.getMessages();
              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatPostPage(),
                  // Pass the arguments as part of the RouteSettings. The
                  // DetailScreen reads the arguments from these settings.
                  settings: RouteSettings(
                    arguments: p,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              // padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              // textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
            ),
            child: Text("Abrir chat"),
          ),
        ],
      );
    }
    return widget;
  }
}
