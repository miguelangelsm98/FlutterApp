import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/user.dart';

class Post {
  String name;
  String? description;
  String? userUid;
  DateTime? createdDate;

  CustomUser? user;

  Post({
    required this.name,
    this.description,
    this.userUid,
    this.createdDate,
  });

  factory Post.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Post(
      name: data?['name'],
      description: data?['description'],
      userUid: data?['userUid'],
      createdDate: data?['createdDate'] != null
          ? DateTime.parse(data?['createdDate'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      if (description != null) "description": description,
      if (userUid != null) "userUid": userUid,
      if (createdDate != null) "createdDate": createdDate?.toIso8601String(),
    };
  }

  void save() async {
    await FirebaseFirestore.instance.collection('posts').add(toFirestore());
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
