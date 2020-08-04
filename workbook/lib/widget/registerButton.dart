import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';

MaterialButton registerButton({String role, BuildContext context, Function onPressed, Color fontColor, Color color}) {
  return MaterialButton(
    padding: EdgeInsets.all(16),
    minWidth: 250,
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
