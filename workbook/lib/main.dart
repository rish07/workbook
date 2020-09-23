import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:workbook/screens/auth/active_users.dart';
import 'package:workbook/screens/auth/admin_form.dart';
import 'package:workbook/screens/auth/login_page.dart';
import 'package:workbook/screens/auth/registration_page.dart';
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/screens/landing_page.dart';
import 'package:flutter/services.dart';
import 'package:workbook/screens/tasks/create_tasks.dart';
import 'package:workbook/screens/tasks/view_tasks.dart';

import 'ad_manager.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      home: LandingPage(),
    );
  }
}
