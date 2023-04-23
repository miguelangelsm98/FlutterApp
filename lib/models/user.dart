import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application/models/post.dart';

const defaultAvatarPath =
    "https://firebasestorage.googleapis.com/v0/b/tfg-project-a9320.appspot.com/o/pictures%2Fprofile1.png?alt=media&token=6edb382b-14d5-47f2-a17e-d274624c3e89";

class CustomUser {
  String? userUid;
  String email;
  String password;
  String? name;
  String? userName;
  String? avatarPath;
  DateTime? birthDate;
  DateTime? joinedDate;
  List<String>? ownRequests;
  List<String>? friendRequests;

  List<Post> posts = <Post>[];
  List<String> friends = <String>[];
  Map<String, String> friendRelations = {};
  Map<String, List<Map<String, dynamic>>?> friendMessages = {};

  CustomUser({
    this.userUid,
    required this.email,
    required this.password,
    this.name,
    this.userName,
    this.avatarPath = defaultAvatarPath,
    this.birthDate,
    this.joinedDate,
    this.ownRequests,
    this.friendRequests,
  });

  factory CustomUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    List<String> ownRequests = <String>[];
    List<String> friendRequests = <String>[];
    if (data?["ownRequests"] != null) {
      for (var request in data?["ownRequests"]) {
        ownRequests.add(request);
      }
    }
    if (data?["friendRequests"] != null) {
      for (var request in data?["friendRequests"]) {
        friendRequests.add(request);
      }
    }

    return CustomUser(
      userUid: data?['userUid'],
      email: data?['email'],
      password: "DefaultPassword",
      name: data?['name'],
      userName: data?['userName'],
      avatarPath: data?['avatarPath'],
      birthDate: data?['birthDate'] != null
          ? DateTime.parse(data?['birthDate'])
          : null,
      joinedDate: data?['joinedDate'] != null
          ? DateTime.parse(data?['joinedDate'])
          : null,
      ownRequests: ownRequests,
      friendRequests: friendRequests,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (userUid != null) "userUid": userUid,
      "email": email,
      if (name != null) "name": name,
      if (userName != null) "userName": userName,
      if (avatarPath != null) "avatarPath": avatarPath,
      if (birthDate != null) "birthDate": birthDate?.toIso8601String(),
      if (joinedDate != null) "joinedDate": joinedDate?.toIso8601String(),
      if (ownRequests != null) "ownRequests": ownRequests,
      if (friendRequests != null) "friendRequests": friendRequests,
    };
  }

  @override
  String toString() {
    return toFirestore().toString();
  }

  Future saveAuth() {
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  Future saveDatabase() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .set(toFirestore());
  }

  Future login() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    if (FirebaseAuth.instance.currentUser != null) {
      userUid = FirebaseAuth.instance.currentUser!.uid;
    }
  }

  Future signUp() async {
    await saveAuth();
    await login();
    joinedDate = DateTime.now();
    await saveDatabase();
  }

  Future addFriendRequest(CustomUser friend) async {
    // Add friend to own requests of user
    await FirebaseFirestore.instance.collection('users').doc(userUid).update({
      "ownRequests": FieldValue.arrayUnion([friend.userUid]),
    });

    // Add user to friend requests of friend
    await FirebaseFirestore.instance
        .collection('users')
        .doc(friend.userUid)
        .update({
      "friendRequests": FieldValue.arrayUnion([userUid]),
    });

    ownRequests?.add(friend.userUid!);
  }

  Future removeFriendRequest(CustomUser friend) async {
    // Remove friend from own requests of user
    await FirebaseFirestore.instance.collection('users').doc(userUid).update({
      "ownRequests": FieldValue.arrayRemove([friend.userUid]),
    });

    // Remove user from friend requests of friend
    await FirebaseFirestore.instance
        .collection('users')
        .doc(friend.userUid)
        .update({
      "friendRequests": FieldValue.arrayRemove([userUid]),
    });

    ownRequests?.remove(friend.userUid!);
  }

  Future acceptFriendRequest(CustomUser friend) async {
    // Remove friend from friend requests of user
    await FirebaseFirestore.instance.collection('users').doc(userUid).update({
      "friendRequests": FieldValue.arrayRemove([friend.userUid]),
    });

    // Remove user from own requests of friend
    await FirebaseFirestore.instance
        .collection('users')
        .doc(friend.userUid)
        .update({
      "ownRequests": FieldValue.arrayRemove([userUid]),
    });

    // Add friend relationship
    String relationId = friend.userUid! + userUid!;
    await FirebaseFirestore.instance.collection('friends').doc(relationId).set({
      "firstUserUid": friend.userUid,
      "secondUserUid": userUid,
    });

    friendRequests?.remove(friend.userUid!);
    friends.add(friend.userUid!);
    friendRelations.putIfAbsent(friend.userUid!, () => relationId);
    print(friendRelations);
  }

  Future declineFriendRequest(CustomUser friend) async {
    // Remove friend from friend requests of user
    await FirebaseFirestore.instance.collection('users').doc(userUid).update({
      "friendRequests": FieldValue.arrayRemove([friend.userUid]),
    });

    // Remove user from own requests of friend
    await FirebaseFirestore.instance
        .collection('users')
        .doc(friend.userUid)
        .update({
      "ownRequests": FieldValue.arrayRemove([userUid]),
    });

    friendRequests?.remove(friend.userUid!);
  }

  Future removeFriend(CustomUser friend) async {
    // Remove friend relationship
    String? relationId = friendRelations[friend.userUid!];
    await FirebaseFirestore.instance
        .collection('friends')
        .doc(relationId)
        .delete();
    friends.remove(friend.userUid);
    friendRelations.remove(relationId);
  }

  List<String> closeFriends() {
    List<String> result = List.from(friends);
    result.add(userUid!);
    return result;
  }

  void addMesage(String message, String relationId) async {
    Map<String, dynamic> messageDoc = <String, dynamic>{};
    messageDoc.putIfAbsent('message', () => message);
    messageDoc.putIfAbsent('userUid', () => userUid);
    messageDoc.putIfAbsent('createdDate', () => DateTime.now().toString());
    messageDoc.putIfAbsent('userAvatarPath', () => avatarPath);
    messageDoc.putIfAbsent('userName', () => name);
    messageDoc.putIfAbsent('userUserName', () => userName);
    print("Adding message: $messageDoc to relationId $relationId");
    await FirebaseFirestore.instance
        .collection('friends')
        .doc(relationId)
        .collection('chat')
        .add(messageDoc);
  }

  Future getMessages(String relationId) async {
    friendMessages[relationId] = <Map<String, dynamic>>[];
    // messages = <Map<String, dynamic>>[];
    final ref = FirebaseFirestore.instance
        .collection("friends")
        .doc(relationId)
        .collection("chat")
        .orderBy("createdDate", descending: false);
    final querySnap = await ref.get();
    for (var message in querySnap.docs) {
      friendMessages[relationId]!.add(message.data());
    }
  }

  Future updateAvatarPath(Uint8List webImage) async {
    // Upload image to Storage
    await FirebaseStorage.instance.ref('pictures/$userUid').putData(webImage);

    // Get image path and add it to user object
    avatarPath = await FirebaseStorage.instance
        .ref("pictures/$userUid")
        .getDownloadURL();

    // Update all direct chat messages
    for (String relationId in friendRelations.values) {
      var ref = FirebaseFirestore.instance
          .collection("friends")
          .doc(relationId)
          .collection("chat")
          .where("userUid", isEqualTo: userUid);
      var querySnap = await ref.get();
      for (var doc in querySnap.docs) {
        print("Changing message $doc");
        await doc.reference.update({'userAvatarPath': avatarPath});
      }
    }

    // Update all post chat messages
    var ref = FirebaseFirestore.instance.collection("posts");
    var querySnap = await ref.get();
    for (var doc in querySnap.docs) {
      var ref2 = FirebaseFirestore.instance
          .collection("posts")
          .doc(doc.data()["postUid"])
          .collection("chat")
          .where("userUid", isEqualTo: userUid);
      var querySnap2 = await ref2.get();
      for (var doc2 in querySnap2.docs) {
        print("Changing message $doc2");
        await doc2.reference.update({'userAvatarPath': avatarPath});
      }
    }
  }
}

Future<CustomUser?> getUserObject() async {
  final ref = FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .withConverter(
        fromFirestore: CustomUser.fromFirestore,
        toFirestore: (CustomUser user, _) => user.toFirestore(),
      );
  final docSnap = await ref.get();
  final user = docSnap.data(); // Convert to User object
  return user;
}

Future<CustomUser?> getUserObjectFromUid(String userUid) async {
  final ref =
      FirebaseFirestore.instance.collection("users").doc(userUid).withConverter(
            fromFirestore: CustomUser.fromFirestore,
            toFirestore: (CustomUser user, _) => user.toFirestore(),
          );
  final docSnap = await ref.get();
  final user = docSnap.data(); // Convert to User object
  return user;
}

Future<List<CustomUser>> getUserObjects(String userUid) async {
  List<CustomUser> users = <CustomUser>[];
  final ref = FirebaseFirestore.instance
      .collection("users")
      .orderBy("userName", descending: false)
      .withConverter(
        fromFirestore: CustomUser.fromFirestore,
        toFirestore: (CustomUser user, _) => user.toFirestore(),
      );
  final querySnap = await ref.get();
  for (var element in querySnap.docs) {
    if (element['userUid'] != userUid) users.add(element.data());
  }
  return users;
}
