import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/dashboard.dart';
import 'package:workbook/screens/login_page.dart';

class LandingPage extends StatefulWidget {
  final TargetPlatform platform;

  const LandingPage({Key key, this.platform}) : super(key: key);
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  Future<void> _loginExists() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('userEmail');

    print(email);
    Navigator.push(
        context,
        PageTransition(
            child: email == null
                ? LoginPage()
                : DashBoard(
                    platform: widget.platform,
                  ),
            type: null));
  }

  @override
  void initState() {
    Timer(Duration(seconds: 4), () {
      _loginExists();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [teal1, teal2])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: AutoSizeText('Workbook',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 70, color: Colors.white)),
            ),
            Image.asset('images/book.gif'),
          ],
        ),
      ),
    );
  }
}
