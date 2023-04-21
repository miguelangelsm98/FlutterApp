import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/post.dart';
import 'add_posts_page.dart';
import 'chat_post_page.dart';

class PostsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final ScrollController firstController = ScrollController();

    return DefaultTabController(
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 40),
                Text("Posts"),
              ],
            ),
            automaticallyImplyLeading: false,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Text("Public Posts")),
                Tab(icon: Text("Friends' Posts")),
                Tab(icon: Text("My Posts"))
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
                    // Pass the arguments as part of the RouteSettings. The
                    // DetailScreen reads the arguments from these settings.
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
      return Center(child: Text("No posts to be shown"));
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: [
              Text(
                "Title: ${p.name}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("Description: ${p.description!}"),
              Text("Created Date: ${p.createdDate.toString()}"),
              Text("Post Date: ${p.postDate.toString()}"),
              Text("Owner: ${p.user!.email}"),
              SizedBox(
                  height: 60,
                  child: Image.network(p.user!.avatarPath!,
                      fit: BoxFit.scaleDown)),
              SizedBox(
                  height: 60,
                  child: Image.network(p.picturePath!, fit: BoxFit.scaleDown)),
              joinActivityWidget(p, appState, context),
              Text("Signed up users: ${p.users!.length}"),
            ]),
          ],
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
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              );
              Widget continueButton = ElevatedButton(
                child: Text("Continue"),
                onPressed: () async {
                  p.remove();
                  appState.doGetPosts();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              );
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: Text("AlertDialog"),
                content: Text("Are you sure you want to remove this post?"),
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
            child: Text("Remove Activity"),
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
            child: Text("Open Chat"),
          ),
        ],
      );
    } else if (!p.users!.contains(appState.currentUser!.userUid)) {
      widget = ElevatedButton(
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
              p.users?.add(appState.currentUser!.userUid!);
              p.saveDatabase();
              appState.doGetPosts();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
          );
          // set up the AlertDialog
          AlertDialog alert = AlertDialog(
            title: Text("AlertDialog"),
            content: Text("Are you sure you want to join this activity?"),
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
        child: Text("Join Activity"),
      );
    } else {
      widget = Row(
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
                  p.users?.remove(appState.currentUser!.userUid!);
                  p.saveDatabase();
                  appState.doGetPosts();

                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
              );
              // set up the AlertDialog
              AlertDialog alert = AlertDialog(
                title: Text("AlertDialog"),
                content: Text("Are you sure you want to leave this activity?"),
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
            child: Text("Leave Activity"),
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
            child: Text("Open Chat"),
          ),
        ],
      );
    }
    return widget;
  }
}
