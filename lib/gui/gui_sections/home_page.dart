import 'package:flutter/material.dart';
import 'package:flutter_application/gui/gui_sections/settings_page.dart';
import 'package:flutter_application/gui/gui_sections/signup_page.dart';
import 'package:flutter_application/gui/gui_sections/list_posts_page.dart';
import 'package:flutter_application/gui/gui_sections/users_page.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

import 'login_page.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    bool isLoggedIn = appState.isLoggedIn;
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;

    if (!isLoggedIn) {
      switch (appState.selectedIndex) {
        case 0:
          return LoginPage();
        case 1:
          return SignupPage();
        default:
          throw UnimplementedError('No hay widget para ${appState.selectedIndex}');
      }
    } else {
      switch (appState.selectedIndex) {
        case 0:
          page = PostsListPage();
          break;
        case 1:
          page = UsersPage();
          break;
        case 2:
          page = SettingsPage();
          break;
        default:
          throw UnimplementedError('No hay widget para ${appState.selectedIndex}');
      }

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
              return Column(
                children: [
                  Expanded(child: mainArea),
                  SafeArea(
                    child: BottomNavigationBar(
                      items: [                        
                        BottomNavigationBarItem(
                            icon: Icon(Icons.list),
                            label: 'Actividades',
                            backgroundColor: Colors.green),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.supervised_user_circle),
                            label: 'Usuarios',
                            backgroundColor: Colors.green),
                        BottomNavigationBarItem(
                            icon: Icon(Icons.settings),
                            label: 'Herramientas',
                            backgroundColor: Colors.green),
                      ],
                      currentIndex: appState.selectedIndex,
                      onTap: (value) {
                        appState.changeSelectedIndex(value);
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
                          icon: Icon(Icons.list),
                          label: Text('Actividades'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.supervised_user_circle),
                          label: Text('Usuarios'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.settings),
                          label: Text('Herramientas'),
                        ),
                      ],
                      selectedIndex: appState.selectedIndex,
                      onDestinationSelected: (value) {
                        appState.changeSelectedIndex(value);
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
