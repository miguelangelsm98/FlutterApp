import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? name;
  final String? description;
  final String? userUid;

  Post(this.name, this.description, this.userUid);

  factory Post.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Post(
      data?['name'],
      data?['description'],
      data?['userUid'],
    );
  }

  Map<String, dynamic> toFirestore() => <String, dynamic>{
        'name': name,
        'description': description,
        'user uid': userUid,
      };

  void save() async {
    await FirebaseFirestore.instance.collection('posts').add(toFirestore());
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


