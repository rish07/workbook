import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';

class ComingSoon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Coming Soon',
          style: TextStyle(fontSize: 50, color: teal2),
        ),
      ),
    );
  }
}
