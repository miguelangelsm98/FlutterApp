import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/gui/gui_sections/update_user_page.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../main.dart';

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// class SettingsPage extends StatefulWidget {
//   SettingsPage({Key key, this.title}) : super(key: key);
//   final String title;
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

class _SettingsPageState extends State<SettingsPage> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Center(child: Text("Settings")),
        automaticallyImplyLeading: false,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            // titlePadding: EdgeInsets.all(20),
            title: Text('Preferences'),
            tiles: [
              SettingsTile(
                title: Text('User information'),
                leading: Icon(Icons.verified_user),
                onPressed: (BuildContext context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateUserPage(),
                      // Pass the arguments as part of the RouteSettings. The
                      // DetailScreen reads the arguments from these settings.
                    ),
                  );
                },
              ),
              // SettingsTile(
              //   title: Text('Language'),
              //   leading: Icon(Icons.language),
              //   onPressed: (BuildContext context) {},
              // ),
              SettingsTile(
                title: Text('Log Out'),
                leading: Icon(Icons.logout),
                onPressed: (BuildContext context) async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    appState.doUserLogout();
                  } on FirebaseAuthException catch (e) {
                    print(e.toString());
                  }
                },
              ),
              // SettingsTile.switchTile(
              //   title: Text('Use System Theme'),
              //   leading: Icon(Icons.phone_android),
              //   // switchValue: isSwitched,
              //   onToggle: (value) {
              //     setState(() {
              //       isSwitched = value;
              //     });
              //   },
              //   initialValue: null,
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
