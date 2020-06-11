import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final String labelText;
  final String errorText;
  bool validate;
  final TextEditingController controller;
  final String helpText;

  PasswordInput(
      {Key key,
      this.labelText,
      this.errorText,
      this.validate,
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
        child: TextField(
          onTap: () {
            setState(() {
              widget.validate = false;
            });
          },
          controller: widget.controller,
          style: TextStyle(color: Colors.white, fontSize: 18),
          obscureText: !isVisible,
          decoration: InputDecoration(
            helperText: widget.helpText ?? null,
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2)),
            errorText: widget.validate ? widget.errorText : null,
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
