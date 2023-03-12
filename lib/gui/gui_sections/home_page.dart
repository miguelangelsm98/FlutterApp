import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/gui/gui_sections/update_user_page.dart';
import 'package:flutter_application/gui/gui_sections/add_posts_page.dart';
import 'package:flutter_application/gui/gui_sections/list_posts_page.dart';
import 'package:flutter_application/gui/gui_sections/user_info_page.dart';
import 'package:flutter_application/gui/gui_sections/users_page.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

import 'logout_page.dart';
import 'login_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    bool isLoggedIn = appState.isLoggedIn;
    var colorScheme = Theme.of(context).colorScheme;

    if (!isLoggedIn) {
      return LoginPage();
    } else {
      Widget page;

      switch (appState.selectedIndex) {
        case 0:
          page = PostsAddPage();
          break;
        case 1:
          page = PostsListPage();
          break;
        case 2:
          page = UpdateUserPage();
          break;
        case 3:
          page = UsersPage();
          break;
        default:
          throw UnimplementedError('no widget for ${appState.selectedIndex}');
      }

      // The container for the current page, with its background color
      // and subtle switching animation.
      var mainArea = ColoredBox(
        color: colorScheme.surfaceVariant,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: page,
        ),
      );

      return Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 450) {
              // Use a more mobile-friendly layout with BottomNavigationBar
              // on narrow screens.
              return Column(
                children: [
                  Expanded(child: mainArea),
                  SafeArea(
                    child: BottomNavigationBar(
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.logout),
                          label: 'Logout',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.post_add),
                          label: 'Add Post',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.favorite),
                          label: 'Posts',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.image),
                          label: 'Image',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.verified_user),
                          label: 'User',
                        ),
                      ],
                      currentIndex: appState.selectedIndex,
                      onTap: (value) {
                        appState.changeSelectedIndex(value);
                      },
                      // TODO addapt with changes
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  SafeArea(
                    child: NavigationRail(
                      extended: constraints.maxWidth >= 600,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.post_add),
                          label: Text('Add Post'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.favorite),
                          label: Text('Posts'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.supervised_user_circle),
                          label: Text('Update User'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.face),
                          label: Text('Users'),
                        ),
                      ],
                      selectedIndex: appState.selectedIndex,
                      onDestinationSelected: (value) {
                        appState.changeSelectedIndex(value);
                      },
                    ),
                  ),
                  Expanded(child: mainArea),
                  SafeArea(child: profileWidget(context)),
                ],
              );
            }
          },
        ),
      );
    }
  }
}

Widget profileWidget(BuildContext context) {
  var appState = context.watch<MyAppState>();
  var imagePath = appState.currentUser!.avatarPath;

  return Column(
    children: [
      SizedBox(
        height: 60,
      ),
      Text(
        "Hello " "${appState.currentUser!.name}!",
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      SizedBox(
        height: 20,
      ),
      SizedBox(
          height: 60, child: Image.network(imagePath!, fit: BoxFit.scaleDown)),
      SizedBox(
        height: 20,
      ),
      MaterialButton(
        // height: 5,
        onPressed: () async {
          try {
            await FirebaseAuth.instance.signOut();
            appState.doUserLogout();
          } on FirebaseAuthException catch (e) {
            print(e.toString());
          }
        },
        color: Color.fromARGB(255, 30, 226, 72),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: Text(
          "Logout",
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
      ),
    ],
  );
}
