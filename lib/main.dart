import 'package:english_words/english_words.dart';
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

  Future<void> doUserLogin() async {
    isLoggedIn = true;
    currentUser = await getUserObject();
    currentUser?.ownRequests = <String>[];
    currentUser?.friendRequests = <String>[];
    currentUser?.friends = <String>[];
    currentUser?.posts = <Post>[];

    await doGetPosts();
    await doGetUsers();
    await doGetFriends();

    notifyListeners();

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
        .where("userUid", isEqualTo: currentUser?.userUid)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          Post p = Post.fromFirestore(docSnapshot, null);
          currentUser?.posts.add(p);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  Future<void> doGetUsers() async {
    users.clear();
    users = await getUserObjects(currentUser!.userUid!);
    notifyListeners();
  }

  Future<void> doGetFriends() async {
    currentUser?.ownRequests.clear();
    currentUser?.friendRequests.clear();
    currentUser?.friends.clear();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser?.userUid)
        .get()
        .then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data["ownRequests"] != null) {
          for (var request in data["ownRequests"]!) {
            currentUser!.ownRequests.add(request);
          }
        }
        if (data["friendRequests"] != null) {
          for (var request in data["friendRequests"]!) {
            currentUser!.friendRequests.add(request);
          }
        }
      },
      onError: (e) => print("Error getting document: $e"),
    );

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

  // Example App

  // var current = WordPair.random();
  // var history = <WordPair>[];
  // GlobalKey? historyListKey;

  // void getNext() {
  //   history.insert(0, current);
  //   var animatedList = historyListKey?.currentState as AnimatedListState?;
  //   animatedList?.insertItem(0);
  //   current = WordPair.random();
  //   notifyListeners();
  // }

  // var favorites = <WordPair>[];

  // void toggleFavorite([WordPair? pair]) {
  //   pair = pair ?? current;
  //   if (favorites.contains(pair)) {
  //     favorites.remove(pair);
  //   } else {
  //     favorites.add(pair);
  //     createFavorite(name: pair.toString());
  //   }
  //   notifyListeners();
  // }

  // void removeFavorite(WordPair pair) {
  //   favorites.remove(pair);
  //   notifyListeners();
  // }

  // void createFavorite({required String name}) async {
  //   final docFavorite = FirebaseFirestore.instance.collection('favorites');
  //   final json = {
  //     'name': name,
  //   };
  //   await docFavorite.add(json);
  // }
}
