import 'dart:async';
import 'package:get/get.dart';
import '/helpers/misc.dart';
import '../helpers/api_req.dart';
import 'map_controller.dart';
import 'package:geolocator/geolocator.dart';
/* import 'dart:collection';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; */

class ZakazController extends MapController {
  double lastLat = 0.0; //_getLastUserLoc(), save user location
  double lastLng = 0.0;
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final orderList = [].obs;
  var olIsEmpty = false.obs;
  int loaderPrice = 0;
  var currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    populateList();
  }

  void populateList() async {
    await requestCategories();
    await getLocation();
    requestOrders();
  }

  void requestOrders() async {
    var ctg = 'zakaz';
    if (xCurrentPage[ctg] != 0 && currentPage < xPageCount[ctg]!) {
      currentPage = (xCurrentPage[ctg]! + 1);
    }

    var list = await getOrders();
    if (list.isNotEmpty) {
      orderList.addAll(list);
    } else {
      olIsEmpty.value = true;
    }
  }

  Future<int> acceptOrder(Map param) async {
    return await postAccept(param);
  }

  Map<int, List<int>> parentChild = {};
  Map<int, int> childParent = {};
  Map<int, int> ctgPrice = {};
  Map<int, String> ctgTitles = {};

  Future<void> requestCategories() async {
    var categories = await getCategories();
    for (Map c in categories) {
      ctgTitles[c['id']] = c['title'];
      ctgPrice[c['id']] = c['price'];
      if (c['parent_id'] != null) {
        childParent[c['id']] = c['parent_id'];
        if (parentChild[c['parent_id']] == null) {
          parentChild[c['parent_id']] = [];
        }
        parentChild[c['parent_id']]!.add(c['id']);
      }

      if (c['title'] == 'Грузчик' || c['title'] == 'Грузчики') {
        loaderPrice = c['price'];
      }
    }
  }

  Future<List<double>> getLastUserLoc() async {
    var lat = 0.0, lng = 0.0;
    if (lastLat != 0.0 && lastLng != 0.0) {
      lat = lastLat;
      lng = lastLng;
    } else {
      var locList = await getLocation();
      if (locList.isNotEmpty) {
        lat = locList[0];
        lng = locList[1];
      } else {
        lat = prefBox.get('lat', defaultValue: 0);
        lng = prefBox.get('lng', defaultValue: 0);
      }
    }
    return [lat, lng];
  }

  Future<List> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    var ld = await _geolocatorPlatform.getCurrentPosition();
    var lat = ld.latitude;
    var lng = ld.longitude;
    //cprint('lat: $lat, lng: $lng');
    lastLat = lat;
    lastLng = lng;
    //lastLocTime = DateTime.now().millisecondsSinceEpoch;
    await prefBox.put('lat', lat);
    await prefBox.put('lng', lng);
    return [lat, lng];
  }

  /*  @override
  void onClose() {
    super.onClose();
  } */
}
