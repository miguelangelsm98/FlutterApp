import 'package:flutter/material.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/models/user.dart';
import 'package:provider/provider.dart';

import 'gui/gui_sections/home_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Vive Más',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromRGBO(0, 255, 0, 1.0)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // My App

  bool isLoggedIn = false;
  CustomUser? currentUser = CustomUser(email: "", password: "");
  int selectedIndex = 0;

  var friends = <CustomUser>[];
  var users = <CustomUser>[];

  var publicPosts = <Post>[];
  var friendsPosts = <Post>[];
  var myPosts = <Post>[];

  void changeSelectedIndex(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> doUserLogin() async {
    isLoggedIn = true;
    currentUser = await getUserObject();
    currentUser?.friends = <String>[];
    currentUser?.posts = <Post>[];
    selectedIndex = 0;

    await doGetUsers();
    await doGetFriends();
    await doGetPosts();
  }

  void doUserLogout() {
    selectedIndex = 0;
    isLoggedIn = false;
    users.clear();
    publicPosts.clear;
    friendsPosts.clear();
    myPosts.clear;

    notifyListeners();
  }

  Future<void> doGetPosts() async {
    await doGetPublicPosts();
    await doGetFriendsPosts();
    await doGetMyPosts();
    notifyListeners();
  }

  Future<void> doGetPublicPosts() async {
    publicPosts.clear();
    await FirebaseFirestore.instance
        .collection("posts")
        .where("isPrivate", isEqualTo: false)
        .orderBy("postDate", descending: false)
        .get()
        .then(
      (querySnapshot) async {
        for (var docSnapshot in querySnapshot.docs) {
          Post p = Post.fromFirestore(docSnapshot, null);
          p.user = await getUserObjectFromUid(p.userUid!);
          publicPosts.add(p);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  Future<void> doGetFriendsPosts() async {
    friendsPosts.clear();
    for (var friendId in currentUser!.friends) {
      await FirebaseFirestore.instance
          .collection("posts")
          .where("userUid", isEqualTo: friendId)
          .orderBy("postDate", descending: false)
          .get()
          .then(
        (querySnapshot) async {
          for (var docSnapshot in querySnapshot.docs) {
            Post p = Post.fromFirestore(docSnapshot, null);
            p.user = await getUserObjectFromUid(friendId);
            friendsPosts.add(p);
          }
        },
        onError: (e) => print("Error completing: $e"),
      );
    }
  }

  Future<void> doGetMyPosts() async {
    myPosts.clear();
    await FirebaseFirestore.instance
        .collection("posts")
        .where("userUid", isEqualTo: currentUser?.userUid)
        .orderBy("postDate", descending: false)
        .get()
        .then(
      (querySnapshot) async {
        for (var docSnapshot in querySnapshot.docs) {
          Post p = Post.fromFirestore(docSnapshot, null);
          p.user = currentUser;
          myPosts.add(p);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  Future<void> doGetUsers() async {
    users.clear();
    users = await getUserObjects(currentUser!.userUid!);
  }

  Future<void> doGetFriends() async {
    currentUser?.friends.clear();
    currentUser?.friendRelations.clear();
    friends.clear();

    await FirebaseFirestore.instance
        .collection("friends")
        .where("firstUserUid", isEqualTo: currentUser?.userUid)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          String friendId = docSnapshot.data()["secondUserUid"];
          String relationId =
              (currentUser?.userUid)! + docSnapshot.data()["secondUserUid"];
          currentUser!.friends.add(friendId);
          currentUser!.friendRelations[friendId] = relationId;
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );

    await FirebaseFirestore.instance
        .collection("friends")
        .where("secondUserUid", isEqualTo: currentUser?.userUid)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          String friendId = docSnapshot.data()["firstUserUid"];
          String relationId =
              docSnapshot.data()["firstUserUid"] + (currentUser?.userUid)!;
          currentUser!.friends.add(friendId);
          currentUser!.friendRelations[friendId] = relationId;
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );

    for (var friendId in currentUser!.friends) {
      CustomUser? friend = await getUserObjectFromUid(friendId);
      friends.add(friend!);
    }

    notifyListeners();
  }
}
