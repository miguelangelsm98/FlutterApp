import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/user.dart';

const defaultPicturePath =
    "https://firebasestorage.googleapis.com/v0/b/tfg-project-a9320.appspot.com/o/pictures%2Fpicture1.jpg?alt=media&token=43ccd598-d79f-4c2b-93a5-2ccc773553cc";

class Post {
  String? postUid;
  String name;
  String? description;
  String? userUid;
  DateTime? createdDate;
  List<String>? users;
  DateTime? postDate;
  CustomUser? user;
  String? picturePath;
  bool? isPrivate;

  List<Map<String, dynamic>>? messages;

  Post({
    this.postUid,
    required this.name,
    this.description,
    this.userUid,
    this.createdDate,
    this.users,
    this.postDate,
    this.picturePath = defaultPicturePath,
    this.isPrivate,
  });

  factory Post.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    List<String> users = <String>[];
    if (data?["users"] != null) {
      for (var user in data?["users"]) {
        users.add(user);
      }
    }

    return Post(
        postUid: data?['postUid'],
        name: data?['name'],
        description: data?['description'],
        userUid: data?['userUid'],
        createdDate: data?['createdDate'] != null
            ? DateTime.parse(data?['createdDate'])
            : null,
        users: users,
        postDate: data?['postDate'] != null
            ? DateTime.parse(data?['postDate'])
            : null,
        picturePath: data?['picturePath'],
        isPrivate: data?['isPrivate']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (postUid != null) "postUid": postUid,
      "name": name,
      if (description != null) "description": description,
      if (userUid != null) "userUid": userUid,
      if (createdDate != null) "createdDate": createdDate?.toString(),
      if (users != null) "users": users,
      if (postDate != null) "postDate": postDate?.toString(),
      if (picturePath != null) "picturePath": picturePath,
      if (isPrivate != null) "isPrivate": isPrivate,
    };
  }

  Future addPost() async {
    users = <String>[];
    users?.add(userUid!);
    DocumentReference addedDocRef =
        await FirebaseFirestore.instance.collection('posts').add(toFirestore());
    postUid = addedDocRef.id;
    saveDatabase();
  }

  Future saveDatabase() async {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postUid)
        .set(toFirestore());
  }

  Future remove() async {
    return FirebaseFirestore.instance.collection('posts').doc(postUid).delete();
  }

  void addMesage(String message, CustomUser user) async {
    Map<String, dynamic> messageDoc = <String, dynamic>{};
    messageDoc.putIfAbsent('message', () => message);
    messageDoc.putIfAbsent('userUid', () => user.userUid);
    messageDoc.putIfAbsent(
        'createdDate', () => DateTime.now().toIso8601String());
    messageDoc.putIfAbsent('userAvatarPath', () => user.avatarPath);
    messageDoc.putIfAbsent('userName', () => user.name);
    messageDoc.putIfAbsent('userLastName', () => user.lastName);
    print("Adding message: $messageDoc to post $postUid");
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postUid)
        .collection('chat')
        .add(messageDoc);
  }

  Future getMessages() async {
    messages = <Map<String, dynamic>>[];
    final ref = FirebaseFirestore.instance
        .collection("posts")
        .doc(postUid)
        .collection("chat")
        .orderBy("createdDate", descending: false);
    final querySnap = await ref.get();
    for (var message in querySnap.docs) {
      messages!.add(message.data());
    } // Convert to User object
  }

  @override
  String toString() {
    return toFirestore().toString();
  }

}
