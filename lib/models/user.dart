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

  CustomUser({
    this.userUid,
    required this.email,
    required this.password,
    this.name,
    this.lastName,
    this.avatarPath = defaultAvatarPath,
    this.birthDate,
    this.joinedDate,
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
    var result = FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    if (FirebaseAuth.instance.currentUser != null) {
      userUid = FirebaseAuth.instance.currentUser!.uid;
    }
    return result;
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

Future<CustomUser> signUp(String email, String password) async {
  CustomUser u = CustomUser(email: email, password: password);
  await u.saveAuth();
  await u.login();
  u.joinedDate = DateTime.now();
  u.name = "Default Name";
  u.lastName = "Default Last Name";
  u.birthDate = DateTime(1990, 1, 1);
  await u.saveDatabase();
  return u;
}

Future<CustomUser> login(String email, String password) async {
  CustomUser u = CustomUser(email: email, password: password);
  await u.login();
  return u;
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
