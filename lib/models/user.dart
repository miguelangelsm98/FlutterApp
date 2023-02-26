import 'package:cloud_firestore/cloud_firestore.dart';

class CustomUser {
  final String email;
  final String password;
  //final String name;
  //final String lastname;

  CustomUser(this.email, this.password);

  //User(this.email, this.name, this.lastname);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'password': password,
        // 'name': name,
        // 'lastname': lastname,
      };

  void save() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .set(toJson());
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

CustomUser userFromJson(Map<String, dynamic> json) {
  return CustomUser(json['email'] as String, json['password'] as String);
}
