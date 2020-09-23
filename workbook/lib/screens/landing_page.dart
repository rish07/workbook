import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/screens/auth/login_page.dart';
import 'package:universal_io/io.dart';
import 'package:workbook/screens/tasks/view_tasks.dart';

import '../ad_manager.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // check if user exists
  Future<void> _loginExists() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('userEmail');

    print(email);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => email == null ? LoginPage() : DashBoard(),
      ),
    );
  }

  Future<void> _initAdMob() {
    // TODO: Initialize AdMob SDK
    return FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
  }

  @override
  void initState() {
    Timer(Duration(seconds: 1), () {
      if (Platform.isAndroid) {
        _initAdMob();
      }
      _loginExists();

      // }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [violet1, violet2])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: AutoSizeText('Workbook', maxLines: 1, textAlign: TextAlign.center, style: TextStyle(fontSize: 70, color: Colors.white)),
            ),
            Container(
              child: Image.asset('images/book.gif'),
              height: MediaQuery.of(context).size.height * 0.3,
            ),
          ],
        ),
      ),
    );
  }
}
