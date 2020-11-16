import 'package:flutter/material.dart';
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/screens/landing_page.dart';
import 'package:flutter/services.dart';
import 'package:workbook/screens/profile_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
