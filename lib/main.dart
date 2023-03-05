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

  Future<void> doUserLogin() async {
    isLoggedIn = true;
    currentUser = await getUserObject();
    await doGetPosts();
    notifyListeners();
  }

  void doUserLogout() {
    isLoggedIn = false;
    currentUser = null;
    currentUser?.posts = <Post>[];
    notifyListeners();
  }

  Future<void> doGetPosts() async {
    currentUser?.posts = <Post>[];
    await FirebaseFirestore.instance
        .collection("posts")
        .where("userUid", isEqualTo: currentUser?.userUid)
        .get()
        .then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          Post p = Post.fromFirestore(docSnapshot, null);
          currentUser?.posts.add(p);
          // result = '$result ${docSnapshot.id} => ${docSnapshot.data()} \n';
          // result = p.toString();
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

  // Example App

  var current = WordPair.random();
  var history = <WordPair>[];
  GlobalKey? historyListKey;

  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
      createFavorite(name: pair.toString());
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  void createFavorite({required String name}) async {
    final docFavorite = FirebaseFirestore.instance.collection('favorites');
    final json = {
      'name': name,
    };
    await docFavorite.add(json);
  }
}
