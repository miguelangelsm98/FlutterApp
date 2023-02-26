import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/post.dart';

class PostsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .where('user uid', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
        return ListView.builder(
          itemCount: streamSnapshot.data?.docs.length,
          itemBuilder: (ctx, index) => Text(streamSnapshot.data?.docs[index]
                  ['name'] +
              " -- " +
              streamSnapshot.data?.docs[index]['description']),
        );
      },
    ));
  }
}
