import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomUser {
  String userUid = "";
  String email = "";
  String password = "";
  String name = "";
  String lastName = "";
  String avatarPath = "";
  String birthDate = "";
  String joinedDate = "";

  CustomUser(this.email, this.password);

  CustomUser.fromJson(Map<String, dynamic> json) {
    userUid = json['userUid'] as String;
    email = json['email'] as String;
    name = json['name'] as String;
    lastName = json['lastName'] as String;
    avatarPath = json['avatarPath'] as String;
    birthDate = json['birthDate'] as String;
    joinedDate = json['joinedDate'] as String;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'userUid': userUid,
        'email': email,
        'name': name,
        'lastName': lastName,
        'avatarPath': avatarPath,
        'birthDate': birthDate,
        'joinedDate': joinedDate,
      };

  void setUserUid(String userUid) {
    userUid = userUid;
  }

  void setEmail(String email) {
    email = email;
  }

  void setPassword(String password) {
    password = password;
  }

  void setName(String name) {
    name = name;
  }

  void setLastName(String lastName) {
    lastName = lastName;
  }

  void setAvatarPath(String avatarPath) {
    avatarPath = avatarPath;
  }

  void setBirthDate(String birthDate) {
    birthDate = birthDate;
  }

  void setJoinedDate(String joinedDate) {
    joinedDate = joinedDate;
  }

  Future saveAuth() {
    return FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
  }

  Future saveDatabase() async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .set(toJson());
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
  CustomUser u = CustomUser(email, password);
  await u.saveAuth();
  await u.login();
  await u.saveDatabase();
  return u;
}

Future<CustomUser> login(String email, String password) async {
  CustomUser u = CustomUser(email, password);
  await u.login();
  return u;
}
