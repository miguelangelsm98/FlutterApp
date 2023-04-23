import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/gui/gui_sections/update_user_page.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../main.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isSwitched = false;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Center(child: Text("Herramientas")),
        automaticallyImplyLeading: false,
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            // titlePadding: EdgeInsets.all(20),
            title: Text('Preferencias'),
            tiles: [
              SettingsTile(
                title: Text('Información del usuario'),
                leading: Icon(Icons.verified_user),
                onPressed: (BuildContext context) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateUserPage(),
                    ),
                  );
                },
              ),

              SettingsTile(
                title: Text('Desconectarse'),
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
            ],
          ),
        ],
      ),
    );
  }
}
