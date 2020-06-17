import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputField extends StatefulWidget {
  final int maxLines;
  final TextCapitalization captial;
  final String errorText;
  final TextEditingController controller;

  var validation;
  final String labelText;
  final TextInputType textInputType;
  InputField(
      {Key key,
      @required this.labelText,
      this.validation,
      this.textInputType,
      this.controller,
      this.errorText,
      this.captial,
      this.maxLines})
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
        child: TextFormField(
          onChanged: (value) {
            setState(() {});
          },
          validator: widget.validation,
          textInputAction: TextInputAction.next,
          autocorrect: true,
          maxLines: widget.maxLines,
          cursorRadius: Radius.circular(8),
          cursorColor: Colors.white,
          keyboardType: widget.textInputType ?? TextInputType.text,
          textCapitalization: widget.captial ?? TextCapitalization.words,
          controller: widget.controller,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            isDense: true,
            errorMaxLines: 1,
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2),
            ),
            errorStyle: TextStyle(height: 0, fontSize: 10),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white70, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2.0),
            ),
            fillColor: Colors.lightBlueAccent,
            labelText: widget.labelText,
            alignLabelWithHint: true,
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
