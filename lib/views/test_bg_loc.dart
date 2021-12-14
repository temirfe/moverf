import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:background_location/background_location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mover/helpers/api_req.dart';
import '/helpers/misc.dart';

class BgLocTest extends StatefulWidget {
  const BgLocTest({
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<BgLocTest> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  String latitude = 'waiting...';
  String longitude = 'waiting...';
  String altitude = 'waiting...';
  String accuracy = 'waiting...';
  String bearing = 'waiting...';
  String speed = 'waiting...';
  String time = 'waiting...';

  @override
  void initState() {
    super.initState();
    //bgLoc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  //zctr.bgLocListen();
                },
                child: Text('Start Location Service')),
            ElevatedButton(
                onPressed: () {
                  BackgroundLocation.stopLocationService();
                },
                child: Text('Stop Location Service')),
            ElevatedButton(
                onPressed: () {
                  getCurrentLocation();
                },
                child: Text('Get Current Location')),
          ],
        ),
      ),
    );
  }

  void _fab() {}

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  void getCurrentLocation() {
    cprint('getcur');
    BackgroundLocation().getCurrentLocation().then((location) {
      cprint('This is current Location ' + location.toMap().toString());
    });
  }

  @override
  void dispose() {
    BackgroundLocation.stopLocationService();
    super.dispose();
  }
}
