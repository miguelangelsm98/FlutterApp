import 'package:flutter/material.dart';
import 'package:flutter_application/gui/gui_sections/image_page.dart';
import 'package:flutter_application/gui/gui_sections/posts_add_page.dart';
import 'package:flutter_application/gui/gui_sections/posts_list_page.dart';
import 'package:flutter_application/gui/gui_sections/user_info_page.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

import 'logout_page.dart';
import 'login_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    bool isLoggedIn = appState.isLoggedIn;

    var colorScheme = Theme.of(context).colorScheme;

    if (!isLoggedIn) {
      return LoginPage();
    } else {
      Widget page;

      switch (selectedIndex) {
        case 0:
          page = LogoutPage();
          break;
        case 1:
          page = PostsAddPage();
          break;
        case 2:
          page = PostsListPage();
          break;
        case 3:
          page = ImagePage();
          break;
        case 4:
          page = UserInfoPage();
          break;
        default:
          throw UnimplementedError('no widget for $selectedIndex');
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
                      currentIndex: selectedIndex,
                      onTap: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
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
                          icon: Icon(Icons.logout),
                          label: Text('Logout'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.post_add),
                          label: Text('Add Post'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.favorite),
                          label: Text('Posts'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.image),
                          label: Text('Image'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.verified_user),
                          label: Text('User'),
                        ),
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  ),
                  Expanded(child: mainArea),
                ],
              );
            }
          },
        ),
      );
    }
  }
}
