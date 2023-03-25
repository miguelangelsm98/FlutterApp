import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/user.dart';

class Post {
  String? postUid;
  String name;
  String? description;
  String? userUid;
  DateTime? createdDate;
  List<String>? users;
  DateTime? postDate;
  CustomUser? user;

  List<Map<String, dynamic>>? messages;

  Post({
    this.postUid,
    required this.name,
    this.description,
    this.userUid,
    this.createdDate,
    this.users,
    this.postDate,
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
      postDate:
          data?['postDate'] != null ? DateTime.parse(data?['postDate']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (postUid != null) "postUid": postUid,
      "name": name,
      if (description != null) "description": description,
      if (userUid != null) "userUid": userUid,
      if (createdDate != null) "createdDate": createdDate?.toIso8601String(),
      if (users != null) "users": users,
      if (postDate != null) "postDate": postDate?.toIso8601String(),
    };
  }

  void addPost() async {
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

  void addMesage(String message, String messageUserUid,
      String messageUserAvatarPath) async {
    Map<String, dynamic> messageDoc = <String, dynamic>{};
    messageDoc.putIfAbsent('message', () => message);
    messageDoc.putIfAbsent('userUid', () => messageUserUid);
    messageDoc.putIfAbsent(
        'createdDate', () => DateTime.now().toIso8601String());
    messageDoc.putIfAbsent('userAvatarPath', () => messageUserAvatarPath);
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
