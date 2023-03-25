import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/models/post.dart';

const defaultAvatarPath =
    "https://firebasestorage.googleapis.com/v0/b/tfg-project-a9320.appspot.com/o/pictures%2Fprofile1.png?alt=media&token=6edb382b-14d5-47f2-a17e-d274624c3e89";

class CustomUser {
  String? userUid;
  String email;
  String password;
  String? name;
  String? lastName;
  String? avatarPath;
  DateTime? birthDate;
  DateTime? joinedDate;
  List<String>? ownRequests;
  List<String>? friendRequests;

  List<Post> posts = <Post>[];
  List<String> friends = <String>[];

  CustomUser({
    this.userUid,
    required this.email,
    required this.password,
    this.name,
    this.lastName,
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
        ownRequests.add(request);      }
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
      lastName: data?['lastName'],
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
      if (lastName != null) "lastName": lastName,
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
    name = "";
    lastName = "";
    birthDate = DateTime(1900, 1, 1);
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
    await FirebaseFirestore.instance
        .collection('friends')
        .doc(friend.userUid! + userUid!)
        .set({
      "firstUserUid": friend.userUid,
      "secondUserUid": userUid,
    });

    friendRequests?.remove(friend.userUid!);
    friends.add(friend.userUid!);
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
    await FirebaseFirestore.instance
        .collection('friends')
        .doc(friend.userUid! + userUid!)
        .delete();
    await FirebaseFirestore.instance
        .collection('friends')
        .doc(userUid! + friend.userUid!)
        .delete();
    friends.remove(friend.userUid);
  }

  List<String> closeFriends() {
    List<String> result = friends;
    result.add(userUid!);
    return result;
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
      .where("userUid", isNotEqualTo: userUid)
      .withConverter(
        fromFirestore: CustomUser.fromFirestore,
        toFirestore: (CustomUser user, _) => user.toFirestore(),
      );
  final querySnap = await ref.get();
  for (var element in querySnap.docs) {
    users.add(element.data());
  } // Convert to User object
  return users;
}
