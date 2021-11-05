import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/helpers/misc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'misc_controller.dart';
/* import '../helpers/api_req.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
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

  @override
  void onInit() {
    super.onInit();
    polylinePoints = PolylinePoints();
  }

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

  Future<void> createPolylines() async {
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
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      //_calcDistance();

      // Defining an ID
      var id = const PolylineId('poly');

      // Initializing Polyline
      var polyline = Polyline(
        polylineId: id,
        color: Colors.black,
        points: polylineCoordinates,
        width: 3,
      );

      // Adding the polyline to the map
      //setState(() {});
      mapPolylines[id] = polyline;
      //update();
    }
  }

  void createMarkers() {
    cprint('createMarkers');
    markers.clear();
    var latSum = 0.0;
    var lngSum = 0.0;
    var points = 0;
    pointsMap.forEach((key, value) {
      //cprint('adding marker for ${value['title']}');
      var icn = BitmapDescriptor.defaultMarker;

      var mid = MarkerId('m$key');
      markersMap[mid] = Marker(
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
      var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 20);
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
}
