import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/login_page.dart';

void popDialog(
    {String title, BuildContext context, String content, Function onPress}) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: Center(
            child: Text(
          title,
          style: TextStyle(color: teal1),
        )),
        content: Text(
          content,
          style: TextStyle(color: teal1),
        ),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: teal2,
              child: new Text(
                'Close',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: onPress),
        ],
      );
    },
  );
}
