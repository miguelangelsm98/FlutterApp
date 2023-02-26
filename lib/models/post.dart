import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/models/user.dart';

class Post {
  final String name;
  final String description;

  Post(this.name, this.description);

  //User(this.email, this.name, this.lastname);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'description': description,
        'user uid': FirebaseAuth.instance.currentUser?.uid,
      };

  void save() async {
    await FirebaseFirestore.instance
        .collection('posts')
        .add(toJson());
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

Post userFromJson(Map<String, dynamic> json) {
  return Post(json['name'] as String, json['description'] as String);
}
