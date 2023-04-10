// import 'package:english_words/english_words.dart';
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
        title: 'Namer App',
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
  var users = <CustomUser>[];

  void changeSelectedIndex(int index) {
    selectedIndex = index;

    notifyListeners();
  }

  // Future<void> refreshCurrentUser() async {
  //   currentUser = await getUserObject();

  //   notifyListeners();
  // }

  Future<void> doUserLogin() async {
    isLoggedIn = true;
    currentUser = await getUserObject();
    currentUser?.friends = <String>[];
    currentUser?.posts = <Post>[];

    await doGetUsers();
    await doGetFriends();
    await doGetPosts();

    // notifyListeners();

    print("--- New user logged in: ${currentUser!.name} ---");
  }

  void doUserLogout() {
    selectedIndex = 0;
    isLoggedIn = false;
    currentUser = null;
    users.clear();

    notifyListeners();
  }

  Future<void> doGetPosts() async {
    currentUser?.posts.clear();
    await FirebaseFirestore.instance
        .collection("posts")
        .where("userUid", whereIn: currentUser?.closeFriends())
        .orderBy("createdDate", descending: true)
        .get()
        .then(
      (querySnapshot) async {
        for (var docSnapshot in querySnapshot.docs) {
          Post p = Post.fromFirestore(docSnapshot, null);
          p.user = await getUserObjectFromUid(p.userUid!);
          // await p.getMessages();
          currentUser?.posts.add(p);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    notifyListeners();
  }

  Future<void> doGetUsers() async {
    users.clear();
    users = await getUserObjects(currentUser!.userUid!);
    notifyListeners();
  }

  Future<void> doGetFriends() async {
    currentUser?.friends.clear();

    await FirebaseFirestore.instance
        .collection("friends")
        .where("firstUserUid", isEqualTo: currentUser?.userUid)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          currentUser!.friends.add(docSnapshot.data()["secondUserUid"]);
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
          currentUser!.friends.add(docSnapshot.data()["firstUserUid"]);
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );

    notifyListeners();
  }
}
