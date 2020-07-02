import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/widget/input_field.dart';
import 'package:http/http.dart' as http;
import 'package:workbook/user.dart';
import 'package:workbook/widget/popUpDialog.dart';

class GenerateTicket extends StatefulWidget {
  @override
  _GenerateTicketState createState() => _GenerateTicketState();
}

class _GenerateTicketState extends State<GenerateTicket> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _validateName = false;
  bool _validateEmail = false;
  bool _validateDescription = false;
  bool _validateInstitution = false;
  String _selectedInstitution;

  Future createTicket() async {
    var response = await http.post('$baseUrl/guest/createQuery', body: {
      "userName": _nameController.text.toString(),
      "userID": _emailController.text.toString(),
      "message": _descriptionController.text.toString(),
      "fcmToken": User.userFcmToken,
      "instituteName": _selectedInstitution,
    });

    print(response.body);
    if (json.decode(response.body)['statusCode'] == 200) {
      popDialog(
          title: "Submitted successfully",
          context: context,
          content:
              "Your query has been submitted successfully. Please wait for the admin to approve");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [teal1, teal2]),
        ),
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Generate Ticket',
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: InputField(
                errorText: 'This field can\'t be empty',
                labelText: 'Name',
                validate: _validateName,
                controller: _nameController,
              ),
            ),
            InputField(
              validate: _validateEmail,
              captial: TextCapitalization.none,
              controller: _emailController,
              errorText: 'Please enter a valid email ID',
              labelText: 'Email',
              textInputType: TextInputType.emailAddress,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: DropdownButtonFormField(
                onTap: () {
                  setState(() {
                    _validateInstitution = false;
                  });
                },
                decoration: InputDecoration(
                  errorText:
                      _validateInstitution ? 'Please choose an option' : null,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                ),
                icon: Icon(Icons.keyboard_arrow_down),
                iconDisabledColor: Colors.white,
                iconEnabledColor: Colors.white,
                iconSize: 24,
                dropdownColor: Colors.teal,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  color: Colors.white70,
                ),
                hint: Text(
                  'Select Institution',
                  style: TextStyle(color: Colors.white70),
                ),
                value: _selectedInstitution,
                onChanged: (newValue) {
                  setState(() {
                    _selectedInstitution = newValue;
                  });
                },
                items: institutes.map((type) {
                  return DropdownMenuItem(
                    child: Text(type),
                    value: type,
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
                child: TextFormField(
                  autocorrect: true,
                  maxLines: 10,
                  onTap: () {
                    setState(() {
                      _validateDescription = false;
                    });
                  },
                  cursorRadius: Radius.circular(8),
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  controller: _descriptionController,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                    isDense: true,
                    errorMaxLines: 1,
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    errorStyle: TextStyle(height: 0, fontSize: 10),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    errorText: _validateDescription
                        ? "This field can't be empty"
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                    ),
                    fillColor: Colors.lightBlueAccent,
                    labelText: "Ticket description",
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 100.0),
              child: MaterialButton(
                padding: EdgeInsets.all(16),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                onPressed: () {},
                child: Text(
                  'Submit Ticket',
                  style: TextStyle(color: teal2, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
