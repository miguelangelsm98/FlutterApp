import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class PostsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text("My posts"),
      ),
      body: Column(
        children: [
          for (var p in appState.currentUser!.posts) Text(p.toString())
        ],
      ),
    );
  }
}
