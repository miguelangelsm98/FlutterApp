import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/gui/gui_sections/posts_add_page.dart';
import 'package:flutter_application/gui/gui_sections/posts_list_page.dart';
import 'package:provider/provider.dart';

import '../../main.dart';
import 'favorites_page.dart';
import 'generator_page.dart';
import 'logout_page.dart';
import 'signup_page.dart';
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
      Widget page;

      switch (selectedIndex) {
        case 0:
          page = LoginPage();
          break;
        case 1:
          page = SignupPage();
          break;
        default:
          selectedIndex = 0;
          page = LoginPage();
          break;
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
                          icon: Icon(Icons.login),
                          label: 'Login',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.app_registration),
                          label: 'Signup',
                        ),
                      ],
                      currentIndex: selectedIndex,
                      onTap: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  )
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
                          icon: Icon(Icons.login),
                          label: Text('Login'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.app_registration),
                          label: Text('Signup'),
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
    } else {
      Widget page;

      switch (selectedIndex) {
        case 0:
          page = GeneratorPage();
          break;
        case 1:
          page = FavoritesPage();
          break;
        case 2:
          page = PostsAddPage();
          break;
        case 3:
          page = PostsListPage();
          break;
        case 4:
          page = LogoutPage();
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
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.favorite),
                          label: 'Favorites',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.post_add),
                          label: 'Add Post',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.list),
                          label: 'Posts',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.logout),
                          label: 'Logout',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.verified_user),
                          label: FirebaseAuth.instance.currentUser!.email
                              .toString(),
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
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.favorite),
                          label: Text('Favorites'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.post_add),
                          label: Text('Add Post'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.list),
                          label: Text('Posts'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.logout),
                          label: Text('Logout'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.verified_user),
                          label: Text(FirebaseAuth.instance.currentUser!.email
                              .toString()),
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
