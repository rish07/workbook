import 'package:flutter/material.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/user.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Share post',
          style: TextStyle(color: teal2, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.clear,
              color: teal2,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: MaterialButton(
                minWidth: 80,
                color: teal2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(
                  'Share',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {}),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              subtitle: Text(""),
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('images/userPhoto.jpg'),
              ),
              title: Text(
                'Super Admin',
                style: TextStyle(color: teal2, fontSize: 18),
              ),
            ),
            TextFormField(
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: Colors.black, fontSize: 18),
              cursorColor: teal2,
              cursorRadius: Radius.circular(8),
              maxLines: 25,
              decoration: InputDecoration(
                hintText: 'What is on your mind?',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: teal2,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.collections,
                  color: teal2,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.description,
                  color: teal2,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
