import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/helpers/misc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'misc_controller.dart';
import '/helpers/api_req.dart';
import 'dart:ui' as ui;

/*
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; */

class MapController extends MiscController {
  var pointsMap = SplayTreeMap<int, Map<String, dynamic>>();
  var mapPolylines = <PolylineId, Polyline>{}.obs;
  var camPos = const CameraPosition(
    target: LatLng(42.8763158, 74.6069835),
    zoom: 14.4746,
  );
  late final PolylinePoints polylinePoints;
  Completer<GoogleMapController> mapCmpl = Completer();
  GoogleMapController? gmctr;
  final Map<MarkerId, Marker> markersMap = <MarkerId, Marker>{};
  final Set<Marker> markers = {};
  IOWebSocketChannel? _channel;
  var iter = 0;
  BitmapDescriptor? cMarker;

  @override
  void onInit() {
    super.onInit();
    circleMarker();
    //_channel = IOWebSocketChannel.connect(wsUrl);
    //_channel!.sink.add(json.encode({'action': 'setId', 'id': 3}));
    polylinePoints = PolylinePoints();
  }

  void periodic() {
    const dur = Duration(seconds: 3);
    Timer.periodic(dur, (Timer t) => sendLoc());
  }

  void sendLoc() async {
    if (iter < points.length) {
      mapPolylines.clear();
      var coord = points[iter].split(',');
      //cprint('coord $coord');
      pointsMap[0] = {
        'title': 'Текущее положение',
        'lat': double.parse(coord[0]),
        'lng': double.parse(coord[1])
      };
      iter++;
      createMarkers(circle: true);
      //await createStraightPolylines();
      await checkCameraLocation();
    }
  }

  void sendLoc2() {
    if (iter < points.length) {
      var data = {'action': 'chat', 'text': points[iter], 'to': 1};
      //_channel!.sink.add(json.encode(data));
      iter++;
    }
  }

  var points = [
    '42.881377, 74.583476',
    '42.881951, 74.583583',
    '42.881910, 74.584229',
    '42.881859, 74.585305',
    '42.881808, 74.586748',
    '42.881745, 74.587789',
    '42.881686, 74.588883',
    '42.881631, 74.590364',
    '42.881545, 74.592161',
    '42.881431, 74.593835',
    '42.881404, 74.594866',
    '42.881624, 74.595129'
  ];

  LatLngBounds? getBounds(Set<Marker> markers) {
    if (markers.isEmpty) {
      return null;
    }
    var positions = markers.map((m) => m.position).toList(); //List<LatLng>
    final southwestLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value < element ? value : element); // smallest
    final southwestLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value < element ? value : element);
    final northeastLat = positions.map((p) => p.latitude).reduce(
        (value, element) => value > element ? value : element); // biggest
    final northeastLon = positions
        .map((p) => p.longitude)
        .reduce((value, element) => value > element ? value : element);
    /* var swDif = southwestLat - northeastLat;
    var latFar = southwestLat + swDif;
    var neDif = southwestLon - northeastLon;
    var lngFar = southwestLon + neDif; */
    return LatLngBounds(
        //southwest: LatLng(latFar, lngFar),
        southwest: LatLng(southwestLat, southwestLon),
        northeast: LatLng(northeastLat, northeastLon));
  }

  Set thecircle(double lat, double lng) {
    return {
      Circle(
        circleId: const CircleId('currentCircle'),
        center: LatLng(lat, lng),
        radius: 4000,
        fillColor: Colors.blue.shade100.withOpacity(0.5),
        strokeColor: Colors.blue.shade100.withOpacity(0.1),
      ),
    };
  }

  Future<void> circleMarker() async {
    // draw circle
    var rad = 15.0;
    final pr = ui.PictureRecorder();
    var c = Canvas(pr);
    final p = Paint()
      ..color = purpleMain
      ..style = PaintingStyle.fill;
    c.drawCircle(Offset(rad, rad), rad, p);

    final image = await pr.endRecording().toImage(
          rad.toInt() * 2,
          rad.toInt() * 2,
        );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    cMarker = BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<void> createPolylines({color = Colors.black}) async {
    mapPolylines.clear();
    final polylineCoordinates = <LatLng>[];
    cprint('createPolylines run');
    var leng = pointsMap.length;
    if (leng > 1) {
      //cprint('_createPolylines len 2');
      var wayPoints = <PolylineWayPoint>[];
      var startLat = myDouble(pointsMap[0]!['lat']);
      var startLng = myDouble(pointsMap[0]!['lng']);
      var last = 1;
      if (leng > 2) {
        last = leng - 1;
        pointsMap.forEach((key, value) {
          if (key != 0 && key != last) {
            wayPoints.add(
                PolylineWayPoint(location: '${value['lat']},${value['lng']}'));
          }
        });
      }
      var destLat = myDouble(pointsMap[last]!['lat']);
      var destLng = myDouble(pointsMap[last]!['lng']);

      // Generating the list of coordinates to be used for
      // drawing the polylines
      var result = await polylinePoints.getRouteBetweenCoordinates(
        Endpoints.gmapApi, // Google Maps API Key
        PointLatLng(startLat, startLng),
        PointLatLng(destLat, destLng),
        wayPoints: wayPoints,
      );

      // Adding the coordinates to the list
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }
      // Defining an ID
      var id = const PolylineId('poly');

      // Initializing Polyline
      var polyline = Polyline(
        polylineId: id,
        color: color,
        points: polylineCoordinates,
        width: 3,
      );

      // Adding the polyline to the map
      //setState(() {});
      mapPolylines[id] = polyline;
      //update();
    }
  }

  void createMarkers({bool showFirst = true, circle = false}) {
    cprint('createMarkers');
    markers.clear();
    var latSum = 0.0;
    var lngSum = 0.0;
    var points = 0;
    var count = pointsMap.length;
    pointsMap.forEach((key, value) {
      //cprint('adding marker for ${value['title']}');
      var visible = true;
      var icnRed = BitmapDescriptor.defaultMarker;
      var icnGreen =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      var icnVio =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
      var icn = icnGreen;
      if (circle) {
        icn = cMarker!;
      }
      if (points == 0 && !showFirst) {
        visible = false;
      }
      if (points > 0) {
        if ((points + 1) < count) {
          icn = icnVio;
        } else {
          icn = icnRed;
        }
      }

      var mid = MarkerId('m$key');
      markersMap[mid] = Marker(
        visible: visible,
        markerId: mid,
        icon: icn,
        position: LatLng(
          myDouble(value['lat']),
          myDouble(value['lng']),
        ),
      );
      latSum += myDouble(value['lat']);
      lngSum += myDouble(value['lng']);
      points++;
    });
    markers.addAll(Set<Marker>.of(markersMap.values));

    if (points > 0) {
      camPos = CameraPosition(
        target: LatLng(latSum / points, lngSum / points),
        zoom: 14.4746,
      );
      //cprint('markers center ${camPos!.target.latitude}');
    }
  }

  Future<void> checkCameraLocation() async {
    var bounds = getBounds(markers);
    if (bounds != null) {
      cprint('checkCameraLocation checkCAm');
      var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 30);
      await gmctr!.animateCamera(cameraUpdate);
      /* LatLngBounds l1 = await mapController.getVisibleRegion();
    LatLngBounds l2 = await mapController.getVisibleRegion();
    cprint('visible regions $l1, $l2'); */

      /* if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90) {
      return checkCameraLocation(bounds, mapController);
    } */
    } else {
      cprint('checkCameraLocation bounds null');
    }
  }

  Future<void> createStraightPolylines() async {
    mapPolylines.clear();
    const id = PolylineId('poly2');

    final polyline = Polyline(
      polylineId: id,
      consumeTapEvents: true,
      geodesic: true,
      color: Colors.black,
      width: 1,
      points: _createPoints(),
    );
    mapPolylines[id] = polyline;
  }

  List<LatLng> _createPoints() {
    final points = <LatLng>[];
    zctr.pointsMap.forEach((key, value) {
      points.add(LatLng(myDouble(value['lat']), myDouble(value['lng'])));
    });
    return points;
  }
}
