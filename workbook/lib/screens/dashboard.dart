import 'dart:convert';

import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:basic_utils/basic_utils.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image/network.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:page_transition/page_transition.dart';

import 'dart:math';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:workbook/constants.dart';
import 'package:workbook/screens/add_GD.dart';
import 'package:workbook/screens/add_post.dart';
import 'package:workbook/screens/approve_user.dart';
import 'package:workbook/screens/login_page.dart';
import 'package:workbook/screens/profile_page.dart';
import 'package:workbook/screens/settings.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/drawer.dart';
import 'package:workbook/widget/popUpDialog.dart';
import 'package:http/http.dart' as http;

class DashBoard extends StatefulWidget {
  final TargetPlatform platform;

  const DashBoard({Key key, this.platform}) : super(key: key);
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String _localPath;
  static final Random random = Random();
  bool _isLoading = false;
  List posts = [];
  String dirloc;

  @override
  void initState() {
    _setData();

    _getAllPosts();
    // TODO: implement initState
    super.initState();
  }

  Future _setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      User.userName = prefs.getString('userName');
      User.userEmail = prefs.getString('userEmail');
      User.userID = prefs.getString('userID');
      User.userRole = prefs.getString('userRole');
      User.instituteImage = prefs.getString('instituteImage');
      User.instituteName = prefs.getString('instituteName');
      User.userInstituteType = prefs.getString('userInstituteType');
      User.numberOfMembers = prefs.getInt('numberOfMembers');
      User.state = prefs.getString('state');
      User.city = prefs.getString('city');
      User.mailAddress = prefs.getString('mailAddress');
      User.aadharNumber = prefs.getInt('aadharNumber');
      User.grade = prefs.getString('grade');
      User.division = prefs.getString('division');
      User.contactNumber = prefs.getInt('contactNumber');
      User.userPhotoData = prefs.getString('userPhotoData');
      User.profilePicExists = prefs.getBool('profilePicExists');
    });
  }

  Future _getAllPosts() async {
    var response = await http.get('$baseUrl/post/viewAllPost');
    print(response.statusCode);
    print(response.body);
    setState(() {
      posts = json.decode(response.body)['payload']['post'];
      posts = posts.reversed.toList();
    });
  }

  Future _likePost({String postId, String userName}) async {
    var response = await http.post("$baseUrl/post/like", body: {
      "id": postId,
      "userName": User.userName,
      "userID": User.userEmail
    });
    print(json.decode(response.body)['statusCode']);
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    List<SpeedDialChild> _superAdmin = [
      SpeedDialChild(
        child: Icon(
          Icons.person,
          color: teal2,
        ),
        label: 'Admins',
        labelStyle: TextStyle(color: teal2),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
                child: ApproveUser(
                  isDriver: false,
                ),
                type: PageTransitionType.fade),
          );
        },
      ),
      SpeedDialChild(
        child: Icon(
          Icons.settings,
          color: teal2,
        ),
        label: 'Settings',
        labelStyle: TextStyle(color: teal2),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(child: Settings(), type: PageTransitionType.fade),
          );
        },
      ),
      SpeedDialChild(
        child: Icon(
          Icons.edit,
          color: teal2,
        ),
        label: 'Create Post',
        labelStyle: TextStyle(color: teal2),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(child: AddPost(), type: PageTransitionType.fade),
          );
        },
      ),
    ];
    List<SpeedDialChild> _admin = [
      SpeedDialChild(
        child: Icon(
          Icons.arrow_downward,
          color: teal2,
        ),
        labelWidget: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey, blurRadius: 1, offset: Offset(1, 1))
            ],
          ),
          child: Text(
            'Grades & Divisions',
            style: TextStyle(color: teal2),
          ),
        ),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(child: AddGD(), type: PageTransitionType.fade),
          );
        },
      ),
      SpeedDialChild(
        child: Icon(
          Icons.person,
          color: teal2,
        ),
        label: 'Employees',
        labelStyle: TextStyle(color: teal2),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
                child: ApproveUser(
                  isDriver: false,
                ),
                type: PageTransitionType.fade),
          );
        },
      ),
      SpeedDialChild(
        child: Icon(
          Icons.directions_car,
          color: teal2,
        ),
        label: 'Drivers',
        labelStyle: TextStyle(color: teal2),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
                child: ApproveUser(
                  isDriver: true,
                ),
                type: PageTransitionType.fade),
          );
        },
      ),
      SpeedDialChild(
        child: Icon(
          Icons.settings,
          color: teal2,
        ),
        label: 'Settings',
        labelStyle: TextStyle(color: teal2),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(child: Settings(), type: PageTransitionType.fade),
          );
        },
      ),
    ];
    List<SpeedDialChild> _employee = [
      SpeedDialChild(
        child: Icon(
          Icons.person,
          color: teal2,
        ),
        label: 'Customers',
        labelStyle: TextStyle(color: teal2),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
                child: ApproveUser(
                  isDriver: false,
                ),
                type: PageTransitionType.fade),
          );
        },
      ),
      SpeedDialChild(
        child: Icon(
          Icons.settings,
          color: teal2,
        ),
        label: 'Settings',
        labelStyle: TextStyle(color: teal2),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(child: Settings(), type: PageTransitionType.fade),
          );
        },
      ),
    ];
    List<SpeedDialChild> _customer = [
      SpeedDialChild(
        child: Icon(
          Icons.settings,
          color: teal2,
        ),
        label: 'Settings',
        labelStyle: TextStyle(color: teal2),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(child: Settings(), type: PageTransitionType.fade),
          );
        },
      ),
    ];
    List<SpeedDialChild> _driver = [
      SpeedDialChild(
        child: Icon(
          Icons.settings,
          color: teal2,
        ),
        label: 'Settings',
        labelStyle: TextStyle(color: teal2),
        backgroundColor: Colors.white,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(child: Settings(), type: PageTransitionType.fade),
          );
        },
      ),
    ];
    return ModalProgressHUD(
      progressIndicator: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(teal2),
        backgroundColor: Colors.transparent,
      ),
      inAsyncCall: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Feed',
            style: TextStyle(
                color: teal2, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          child: ProfilePage(),
                          type: PageTransitionType.rightToLeft));
                },
                child: Hero(
                  tag: "profile",
                  child: CircleAvatar(
                    radius: 23,
                    backgroundImage: !User.profilePicExists
                        ? AssetImage('images/userPhoto.jpg')
                        : NetworkImageWithRetry((User.userPhotoData)),
                  ),
                ),
              ),
            ),
          ],
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: teal2),
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return _getAllPosts();
          },
          child: Container(
            child: _isLoading || posts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 64),
                          child: AutoSizeText(
                            User.userRole != "superAdmin"
                                ? 'Welcome to ${User.instituteName},\n${User.userName?.split(" ")[0]}!'
                                : "Welcome,\n${User.userName}",
                            maxLines: 2,
                            style: TextStyle(color: teal2, fontSize: 50),
                          ),
                        ),
                        posts.isEmpty
                            ? Text('No Posts')
                            : TyperAnimatedTextKit(
                                speed: Duration(milliseconds: 200),
                                text: ['Loading...'],
                                textStyle:
                                    TextStyle(fontSize: 25, color: teal1),
                                onFinished: () {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                },
                              ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: ((context, index) {
                      var randid = random.nextInt(10000);
                      if (posts[index]['mediaType'] == 'pdf') {}
                      final TextEditingController contro =
                          TextEditingController();
                      List temp = [];
                      posts[index]['likedBy'].forEach((element) {
                        temp.add(element['userID']);
                      });
                      return (posts[index]['enabled'] == true ||
                              User.userRole == 'superAdmin')
                          ? VisibilityDetector(
                              onVisibilityChanged: (visibilityInfo) async {
                                if (visibilityInfo.visibleFraction == 1.0) {
                                  var response = await http.post(
                                      '$baseUrl/post/updateViews',
                                      body: {"id": posts[index]['_id']});
                                  print(response.body);
                                }
                              },
                              key: Key(index.toString()),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 16),
                                child: Stack(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 10,
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            (posts[index]['mediaUrl'] !=
                                                        "null" &&
                                                    posts[index]['mediaType'] ==
                                                        'image')
                                                ? Container(
                                                    padding: EdgeInsets.all(8),
                                                    child: Image.network(
                                                        posts[index]
                                                            ['mediaUrl']),
                                                  )
                                                : (posts[index]['mediaUrl'] !=
                                                            "null" &&
                                                        posts[index]
                                                                ['mediaType'] ==
                                                            'pdf')
                                                    ? Container(
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: ListTile(
                                                          title: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                height: 50,
                                                                width: 50,
                                                                child:
                                                                    Image.asset(
                                                                  'images/pdf.png',
                                                                ),
                                                              ),
                                                              IconButton(
                                                                  icon: Icon(Icons
                                                                      .file_download),
                                                                  color: teal2,
                                                                  onPressed:
                                                                      () async {
                                                                    await launch(
                                                                        posts[index]
                                                                            [
                                                                            'mediaUrl']);
                                                                  })
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                            Container(
                                              padding: EdgeInsets.all(8),
                                              child: Text(
                                                posts[index]['content'],
                                                style: TextStyle(fontSize: 14),
                                                textAlign: TextAlign.left,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 10),
                                                  child: Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(
                                                          temp.contains(User
                                                                  .userEmail)
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          color: teal2,
                                                        ),
                                                        onPressed: () async {
                                                          if (temp.contains(
                                                              User.userEmail)) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    'Liked already!');
                                                          } else {
                                                            await _likePost(
                                                                postId:
                                                                    posts[index]
                                                                        ['_id'],
                                                                userName: User
                                                                    .userName);
                                                            await _getAllPosts();
                                                            setState(() {});
                                                          }
                                                        },
                                                      ),
                                                      Text(
                                                        posts[index]['likes']
                                                            .toString(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.show_chart,
                                                      color: teal2,
                                                    ),
                                                    Text(
                                                      posts[index]['views']
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: teal1),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                                  child: IconButton(
                                                      icon: Icon(
                                                        Icons.share,
                                                        color: teal2,
                                                      ),
                                                      onPressed: () {
                                                        Share.share(
                                                          posts[index]
                                                              ['content'],
                                                        );
                                                      }),
                                                ),
                                              ],
                                            ),
                                            posts[index]['commentEnabled']
                                                ? Container(
                                                    height: posts[index]
                                                                    ['comments']
                                                                .length !=
                                                            0
                                                        ? 200
                                                        : 20,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        Text(posts[index][
                                                                        'comments']
                                                                    .length !=
                                                                0
                                                            ? 'Comments'
                                                            : ''),
                                                        posts[index]['comments']
                                                                    .length !=
                                                                0
                                                            ? Container(
                                                                height: 180,
                                                                child: ListView
                                                                    .builder(
                                                                  shrinkWrap:
                                                                      true,
                                                                  itemCount: posts[
                                                                              index]
                                                                          [
                                                                          'comments']
                                                                      .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          i) {
                                                                    return Column(
                                                                      children: [
                                                                        ListTile(
                                                                          title:
                                                                              Text(
                                                                            posts[index]['comments'][i]['userName'],
                                                                            style:
                                                                                TextStyle(color: teal2, fontWeight: FontWeight.bold),
                                                                          ),
                                                                          subtitle:
                                                                              Text(
                                                                            posts[index]['comments'][i]['comment'],
                                                                            style:
                                                                                TextStyle(color: Colors.black),
                                                                          ),
                                                                        ),
                                                                        Divider(),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  )
                                                : Container(),
                                            posts[index]['commentEnabled']
                                                ? TextFormField(
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                    maxLines: 1,
                                                    controller: contro,
                                                    cursorRadius:
                                                        Radius.circular(8),
                                                    cursorColor: Colors.black,
                                                    decoration: InputDecoration(
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                              borderSide:
                                                                  BorderSide(
                                                        color: Colors.grey,
                                                      )),
                                                      isDense: true,
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: Colors.grey,
                                                            width: 2),
                                                      ),
                                                      hintText: 'Add a comment',
                                                      suffixIcon: IconButton(
                                                          icon:
                                                              Icon(Icons.send),
                                                          color: teal2,
                                                          onPressed: () async {
                                                            print(contro.text);
                                                            if (contro.text
                                                                .isNotEmpty) {
                                                              var response =
                                                                  await http.post(
                                                                      '$baseUrl/post/comment',
                                                                      body: {
                                                                    "id": posts[
                                                                            index]
                                                                        ['_id'],
                                                                    "comment": contro
                                                                        .text
                                                                        .toString(),
                                                                    "userName":
                                                                        User.userName
                                                                  });

                                                              print(response
                                                                  .body);
                                                              if (json.decode(response
                                                                          .body)[
                                                                      'statusCode'] ==
                                                                  200) {
                                                                Fluttertoast
                                                                    .showToast(
                                                                        msg:
                                                                            'Comment posted');
                                                                setState(() {
                                                                  _getAllPosts();
                                                                });
                                                              }
                                                            } else {
                                                              Fluttertoast
                                                                  .showToast(
                                                                      msg:
                                                                          'Comment can\'t be empty');
                                                            }
                                                          }),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                    User.userRole == 'superAdmin'
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                top: 8.0,
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.83),
                                            child: PopupMenuButton(
                                              onSelected: (value) async {
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                                if (value == 1) {
                                                  var response = await http.post(
                                                      posts[index]['enabled'] ==
                                                              true
                                                          ? '$baseUrl/post/disablePost'
                                                          : '$baseUrl/post/enablePost',
                                                      body: {
                                                        "id": posts[index]
                                                            ['_id'],
                                                      });
                                                  print(response.body);
                                                  setState(() {
                                                    _getAllPosts();
                                                    _isLoading = false;
                                                  });
                                                } else if (value == 2) {
                                                  var response = await http.post(
                                                      posts[index][
                                                                  'commentEnabled'] ==
                                                              true
                                                          ? '$baseUrl/post/disableComment'
                                                          : '$baseUrl/post/enableComment',
                                                      body: {
                                                        "id": posts[index]
                                                            ['_id'],
                                                      });
                                                  print(response.body);
                                                  setState(() {
                                                    _getAllPosts();
                                                    _isLoading = false;
                                                  });
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 1,
                                                  child: Text(posts[index]
                                                              ['enabled'] ==
                                                          true
                                                      ? 'Disable Post'
                                                      : 'Enable Post'),
                                                ),
                                                PopupMenuItem(
                                                  value: 2,
                                                  child: Text(posts[index][
                                                              'commentEnabled'] ==
                                                          true
                                                      ? 'Disable Comments'
                                                      : 'Enable Comments'),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    posts[index]['enabled']
                                        ? Container()
                                        : Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey,
                                                  blurRadius: 2,
                                                ),
                                              ],
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'DISABLED',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            padding: EdgeInsets.all(8),
                                          ),
                                  ],
                                ),
                              ),
                            )
                          : Container();
                    }),
                  ),
          ),
        ),
        floatingActionButton: buildSpeedDial(
            superAdmin: _superAdmin,
            admin: _admin,
            customer: _customer,
            employee: _employee,
            driver: _driver),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  SpeedDial buildSpeedDial(
      {List<SpeedDialChild> superAdmin,
      List<SpeedDialChild> admin,
      List<SpeedDialChild> employee,
      List<SpeedDialChild> customer,
      List<SpeedDialChild> driver}) {
    return SpeedDial(
        marginBottom: 30,
        marginRight: MediaQuery.of(context).size.width * 0.46,
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        // child: Icon(Icons.add),
        backgroundColor: teal2,
        onOpen: () => print('OPENING DIAL'),
        onClose: () => print('DIAL CLOSED'),
        curve: Curves.bounceIn,
        children: User.userRole == 'superAdmin'
            ? superAdmin
            : (User.userRole == 'admin')
                ? admin
                : (User.userRole == 'employee')
                    ? employee
                    : (User.userRole == 'customer') ? customer : driver);
  }

//Widget openBottomDrawer(BuildContext context) {
//  return Container(
//    height: MediaQuery.of(context).size.height * 0.4,
//    child: Theme(
//      data: Theme.of(context).copyWith(
//        canvasColor: Colors.transparent,
//      ),
//      child: Drawer(
//        child: Container(
//          decoration: BoxDecoration(
//            borderRadius: BorderRadius.circular(32),
//            color: Colors.white,
//          ),
//          child: ListView(
//            shrinkWrap: true,
//            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 8),
//            children: [
//              buildDrawerItemDashboard(
//                  icon: Icons.home,
//                  title: "Home",
//                  onTap: () {
//                    Navigator.push(
//                        context,
//                        PageTransition(
//                            child: DashBoard(), type: PageTransitionType.fade));
//                  }),
//              User.userRole != 'superAdmin'
//                  ? buildDrawerItemDashboard(
//                      icon: Icons.account_circle,
//                      title: "Profile",
//                      onTap: () {
//                        Navigator.push(
//                            context,
//                            PageTransition(
//                                child: ProfilePage(),
//                                type: PageTransitionType.fade));
//                      })
//                  : Container(),
//              User.userRole == 'admin'
//                  ? buildDrawerItemDashboard(
//                      icon: Icons.arrow_downward,
//                      title: 'Grades and Divisions',
//                      onTap: () {
//                        Navigator.push(
//                            context,
//                            PageTransition(
//                                child: AddGD(), type: PageTransitionType.fade));
//                      })
//                  : Container(),
//              buildDrawerItemDashboard(
//                  icon: Icons.person,
//                  title: User.userRole == 'admin'
//                      ? "Employees"
//                      : (User.userRole == 'employee') ? 'Customers' : 'Admins',
//                  onTap: () {
//                    Navigator.push(
//                      context,
//                      PageTransition(
//                          child: ApproveUser(
//                            isDriver: false,
//                          ),
//                          type: PageTransitionType.fade),
//                    );
//                  }),
//              User.userRole == 'admin'
//                  ? buildDrawerItemDashboard(
//                      icon: Icons.directions_car,
//                      title: 'Drivers',
//                      onTap: () {
//                        Navigator.push(
//                          context,
//                          PageTransition(
//                              child: ApproveUser(
//                                isDriver: true,
//                              ),
//                              type: PageTransitionType.fade),
//                        );
//                      })
//                  : Container(),
//            ],
//          ),
//        ),
//      ),
//    ),
//  );
//}
}
