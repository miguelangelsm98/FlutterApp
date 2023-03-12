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

  List<Post> posts = <Post>[];
  List<String> ownRequests = <String>[];
  List<String> friendRequests = <String>[];
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
    // this.ownRequests,
    // this.friendRequests,
  });

  factory CustomUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
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
      // ownRequests: data?['ownRequests'] != null
      //     ? data!['ownRequests'] as List<String>?
      //     : <String>[],
      // friendRequests: data?['friendRequests'] != null
      //     ? data!['friendRequests'] as List<String>?
      //     : <String>[],
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
      // "ownRequests": ownRequests,
      // "friendRequests": friendRequests,
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

//todo
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
    await FirebaseFirestore.instance.collection('friends').add({
      "firstUserUid": friend.userUid,
      "secondUserUid": userUid,
    });
  }

  // Django Model
  // email = models.EmailField(('email address'), unique=True)

  // # Optional attributes
  // name = models.CharField(max_length = 32, blank=True, null=True)
  // lastname = models.CharField(max_length = 32, blank=True, null=True)
  // birth_date = models.DateField(blank=True, null=True)
  // avatar = models.ImageField(default="pictures/default.png", upload_to='pictures/')
  // is_company = models.BooleanField(default = False)
  // is_staff = models.BooleanField(default = False)
  // is_active = models.BooleanField(default = True)
  // date_joined = models.DateTimeField(default = timezone.now)
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
