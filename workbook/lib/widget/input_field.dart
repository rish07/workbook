import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatefulWidget {
  final TextCapitalization captial;
  final String errorText;
  final TextEditingController controller;
  final bool validate;
  final String labelText;
  final TextInputType textInputType;
  InputField(
      {Key key,
      @required this.labelText,
      this.textInputType,
      this.controller,
      this.validate,
      this.errorText,
      this.captial})
      : super(key: key);
  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: TextField(
          cursorColor: Colors.white,
          keyboardType: widget.textInputType ?? TextInputType.text,
          textCapitalization: widget.captial ?? TextCapitalization.words,
          controller: widget.controller,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            errorText: widget.validate ? widget.errorText : null,
            border: InputBorder.none,
            fillColor: Colors.lightBlueAccent,
            labelText: widget.labelText,
            labelStyle: TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
