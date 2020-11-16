import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:universal_io/prefer_sdk/io.dart';

class TextLogin extends StatefulWidget {
  @override
  _TextLoginState createState() => _TextLoginState();
}

class _TextLoginState extends State<TextLogin> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 10.0),
      child: Container(
        padding: EdgeInsets.all(16),

        //color: Colors.green,
        height: MediaQuery.of(context).size.height * 0.35,
        width: Platform.isAndroid ? MediaQuery.of(context).size.width * 0.8 : MediaQuery.of(context).size.width * 0.35,
        child: Padding(
          padding: const EdgeInsets.only(top: 60.0),
          child: Text(
            'A world of\npossibility in\nan app',
            style: TextStyle(
              fontSize: 38,
              color: Colors.white,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ),
    );
  }
}
