import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  var validation;
  final String labelText;
  final String errorText;
  final TextEditingController controller;
  final String helpText;

  PasswordInput(
      {Key key,
      this.labelText,
      this.validation,
      this.errorText,
      this.controller,
      this.helpText})
      : super(key: key);
  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool isVisible = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        child: TextFormField(
          validator: widget.validation,
          cursorColor: Colors.white,
          controller: widget.controller,
          style: TextStyle(color: Colors.white, fontSize: 18),
          obscureText: !isVisible,
          decoration: InputDecoration(
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
            helperText: widget.helpText ?? null,
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2)),
            suffixIcon: IconButton(
                color: Colors.white,
                icon: isVisible
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                }),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white70)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2)),
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
