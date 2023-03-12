import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/post.dart';

class PostsListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    final ScrollController firstController = ScrollController();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: [
              Text(
                "Posts",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Check created Posts",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  controller: firstController,
                  itemCount: appState.currentUser!.posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    return createPost(appState.currentUser!.posts[index]);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget createPost(Post p) {
    Widget widget = Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(children: [
        Text(
          "Title: ${p.name}",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text("Description: ${p.description!}"),
        Text("Created Date: ${p.createdDate.toString()}"),
        Text("Owner: ${p.user!.email}"),
        SizedBox(
            height: 60,
            child: Image.network(p.user!.avatarPath!, fit: BoxFit.scaleDown)),
      ]),
    );
    return widget;
  }
}
