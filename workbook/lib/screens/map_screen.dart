import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:page_transition/page_transition.dart';
import 'dart:async';
import 'package:workbook/screens/request_profile_page.dart';
import 'package:workbook/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:uuid/uuid.dart';
import 'package:workbook/user.dart';
import 'package:workbook/widget/popUpDialog.dart';

class GoogleMapScreen extends StatefulWidget {
  final String routeName;
  final String driverID;
  Location location = new Location();

  GoogleMapScreen({Key key, this.routeName, this.driverID}) : super(key: key);
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  void initState() {
    super.initState();
    _getLocation();
  }

  List _locations = [];
  String address = "";

  final Geolocator _geoLocator = Geolocator();

  Future _getLocationAddress(double latitude, double longitude) async {
    List<Placemark> newPlace = await _geoLocator.placemarkFromCoordinates(latitude, longitude);
    Placemark placeMark = newPlace[0];
    String name = placeMark.name;
    // String subLocality = placeMark.subLocality;
    String locality = placeMark.locality;
    String administrativeArea = placeMark.administrativeArea;
    // String subAdministrativeArea = placeMark.administrativeArea;
    String postalCode = placeMark.postalCode;
    String country = placeMark.country;
    // String subThoroughfare = placeMark.subThoroughfare;
    String thoroughfare = placeMark.thoroughfare;
    setState(() {
      address = "$name, $thoroughfare, $locality, $administrativeArea, $postalCode, $country";
    });
  }

  Completer<GoogleMapController> _controller = Completer();

  static double latitude;
  static double longitude;

  CameraPosition _kGooglePlex = CameraPosition(target: LatLng(19.07, 72.87));

  List<Marker> markers = <Marker>[];

  List<Circle> circles = <Circle>[];

  void _getLocation() async {
    LocationData loc = await widget.location.getLocation();
    //getAllMarkers();
    print(loc);
    latitude = loc.latitude;
    longitude = loc.longitude;

    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 13,
      );
      final circle = Circle(
        circleId: CircleId("curr_loc"),
        center: LatLng(loc.latitude, loc.longitude),
        fillColor: Colors.blueAccent,
        strokeColor: Colors.blueAccent,
        radius: 5,
        zIndex: 100,
      );
      final circleBackground = Circle(
        circleId: CircleId("curr_loc_bg"),
        center: LatLng(loc.latitude, loc.longitude),
        strokeColor: Color.fromRGBO(230, 230, 230, 1),
        radius: 18,
        zIndex: 10,
      );
      circles.add(circle);
      circles.add(circleBackground);
    });
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(loc.latitude, loc.longitude),
        zoom: 17.0,
      ),
    ));
  }

  Future _createRoute() async {
    var body = json.encode({
      "driverID": widget.driverID,
      "locations": _locations,
      "routeName": widget.routeName,
      "userID": User.userEmail,
      "jwtToken": User.userJwtToken,
    });
    print(body);
    var response = await http.post(
      'https://workbook.in.ngrok.io/admin/createRoute',
      body: body,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    print('--------------------------------------------------------');
    print(response.body);
  }

  Future<void> getAllMarkers() {
    markers = [];
    print("Getting marker data");
    var uuid = Uuid();
    setState(() {
      _locations.forEach((element) {
        markers.add(
          Marker(
            markerId: MarkerId(uuid.v1()),
            position: LatLng(double.parse(element['latitude']), double.parse(element['longitude'])),
            infoWindow: InfoWindow(title: element['name']),
            flat: false,
            draggable: false,
            consumeTapEvents: true,
            onTap: () {
              popDialog(
                title: 'Delete Route?',
                content: 'Do you want to delete this location from the route?',
                context: context,
                onPress: () {},
                buttonTitle: 'Delete',
              );
            },
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
            leading: IconButton(
                color: violet1,
                icon: Icon(
                  Icons.arrow_back,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            actions: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: MaterialButton(
                    minWidth: 80,
                    color: violet2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      print('working');
                      await _createRoute();
                      FlutterToast.showToast(msg: 'updated');
                    }),
              )
            ],
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            title: Text(
              'Set Route',
              style: TextStyle(color: violet2),
            )),
        body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            circles: Set<Circle>.of(circles),
            markers: Set<Marker>.of(markers),
            myLocationButtonEnabled: true,
            onTap: (LatLng location) async {
              await _getLocationAddress(location.latitude, location.longitude);

              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Add location?"),
                      content: Text("Are you sure you want to add the tapped location $address to ${widget.routeName}"),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text(
                            "Add",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            _locations.add({
                              "latitude": location.latitude.toString(),
                              "longitude": location.longitude.toString(),
                              "name": address,
                            });
                            print('here11111111111111111111111111111111111111111111111111');
                            print(_locations);
                            getAllMarkers();
                            Navigator.pop(context);
                            getAllMarkers();
                          },
                        ),
                      ],
                    );
                  });
            }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _getLocation,
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          tooltip: 'Get Location',
          label: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.gps_fixed, color: violet1),
              ),
              Text(
                'Get my Location',
                style: TextStyle(color: violet1),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
