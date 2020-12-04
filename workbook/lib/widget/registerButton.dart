import 'package:flutter/material.dart';
import 'package:universal_io/prefer_sdk/io.dart';
import 'package:workbook/constants.dart';

MaterialButton registerButton({String role, BuildContext context, Function onPressed, Color fontColor, Color color}) {
  Size size = MediaQuery.of(context).size;
  return MaterialButton(
    padding: EdgeInsets.all(16),
    minWidth: Platform.isAndroid ? 250 : 0,
    color: color ?? Colors.white,
    child: Text(
      role,
      style: TextStyle(fontWeight: FontWeight.bold, color: fontColor ?? violet2, fontSize: 18),
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    onPressed: onPressed,
  );
}
