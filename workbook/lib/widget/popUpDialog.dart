import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';

void popDialog(
    {String title,
    BuildContext context,
    String content,
    Function onPress,
    String buttonTitle}) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: Center(
            child: Text(
          title,
          style: TextStyle(color: violet1),
        )),
        content: Text(
          content,
          style: TextStyle(color: violet1),
        ),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              color: violet2,
              child: new Text(
                buttonTitle,
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
