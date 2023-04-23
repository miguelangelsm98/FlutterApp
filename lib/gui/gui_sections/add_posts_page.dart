import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/post.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

import 'home_page.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';

const defaultPicturePath =
    "https://firebasestorage.googleapis.com/v0/b/tfg-project-a9320.appspot.com/o/pictures%2Fpicture1.jpg?alt=media&token=43ccd598-d79f-4c2b-93a5-2ccc773553cc";

class PostsAddPage extends StatefulWidget {
  @override
  State<PostsAddPage> createState() => _PostsAddPageState();
}

class _PostsAddPageState extends State<PostsAddPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String dateTime = DateTime.now().toString();

  File? pickedImage;
  Uint8List webImage = Uint8List(8);
  String imagePath = "";
  List<bool> selectedPrivacy = <bool>[true, false];
  bool? isPrivate = true;

  // var dateController = TextEditingController(
  //     text: DateFormat('dd-MM-yyyy').format(DateTime.now()));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    const List<Widget> privacyOptions = <Widget>[
      Text('Todos'),
      Text('Solo amigos'),
    ];

    // DateTime? pickedDate = DateTime.now();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Añadir actividad"),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.black,
            )),
      ),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                height: 150,
                child: pickedImage == null
                    ? Image.network(defaultPicturePath, fit: BoxFit.scaleDown)
                    : kIsWeb
                        ? Image.memory(webImage, fit: BoxFit.fill)
                        : Image.file(pickedImage!, fit: BoxFit.scaleDown)),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: selectImage,
                    child: const Text("Seleccione una imagen")),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  makeInput(
                      label: "Nombre",
                      controller: nameController,
                      maxLines: 1,
                      maxLength: 32),
                  makeInput(
                      label: "Descripción",
                      controller: descriptionController,
                      maxLines: 6,
                      maxLength: 180),
                  DateTimePicker(
                    type: DateTimePickerType.dateTime,
                    dateMask: 'dd-MM-yyyy hh:mm',
                    initialValue: '',
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                    dateLabelText: 'Fecha de la actividad',
                    onChanged: (val) => dateTime = val,
                    validator: (val) {
                      print(val);
                      return null;
                    },
                    onSaved: (val) => print(val),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "¿Quién puede ver la actividad?",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      ToggleButtons(
                        direction: Axis.horizontal,
                        onPressed: (int index) {
                          setState(() {
                            for (int i = 0; i < selectedPrivacy.length; i++) {
                              selectedPrivacy[i] = i == index;
                            }
                            isPrivate = selectedPrivacy[0];
                          });
                        },
                        constraints: const BoxConstraints(
                          minHeight: 40.0,
                          minWidth: 135.0,
                        ),
                        isSelected: selectedPrivacy,
                        children: privacyOptions,
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: EdgeInsets.only(top: 3, left: 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border(
                        bottom: BorderSide(color: Colors.black),
                        top: BorderSide(color: Colors.black),
                        right: BorderSide(color: Colors.black),
                        left: BorderSide(color: Colors.black))),
                child: MaterialButton(
                  minWidth: double.infinity,
                  height: 60,
                  onPressed: () async {
                    Post post = Post(
                        name: nameController.text,
                        description: descriptionController.text,
                        userUid: appState.currentUser?.userUid,
                        createdDate: DateTime.now(),
                        postDate: DateTime.parse(dateTime),
                        isPrivate: isPrivate);
                    await post.addPost();
                    if (pickedImage != null) {
                      await FirebaseStorage.instance
                          .ref('pictures/${post.postUid}')
                          .putData(webImage);
                      post.picturePath = await FirebaseStorage.instance
                          .ref("pictures/${post.postUid}")
                          .getDownloadURL();
                    }
                    await post.saveDatabase();
                    await appState.doGetPosts();

                    Widget okButton = ElevatedButton(
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyHomePage()));
                      },
                    );
                    // set up the AlertDialog
                    AlertDialog alert = AlertDialog(
                      title: Text("Mensaje"),
                      content: Text("Actividad creada correctamente"),
                      actions: [
                        okButton,
                      ],
                    );
                    // show the dialog
                    // ignore: use_build_context_synchronously
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return alert;
                      },
                    );
                  },
                  color: Colors.indigoAccent[400],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  child: Text(
                    "Crear actividad",
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white70),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future selectImage() async {
    if (!kIsWeb) {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        File? croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          maxWidth: 1080,
          maxHeight: 1080,
          aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        );
        var f = await croppedImage?.readAsBytes();
        var selected = File((croppedImage?.path)!);
        setState(() {
          pickedImage = selected;
          webImage = f!;
        });
      } else {
        print('No se ha seleccionado imagen');
      }
    } else if (kIsWeb) {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          pickedImage = File('a');
        });
      } else {
        print('No se ha seleccionado imagen');
      }
    } else {
      print('Algo ha ido mal');
    }
  }
}

Widget makeInput({label, controller, obsureText = false, maxLines, maxLength}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      SizedBox(
        height: 5,
      ),
      TextField(
        controller: controller,
        obscureText: obsureText,
        maxLines: maxLines,
        maxLength: maxLength,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          border:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        ),
      ),
      SizedBox(
        height: 15,
      )
    ],
  );
}
