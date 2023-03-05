import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Text(appState.currentUser.toString());
  }
}
