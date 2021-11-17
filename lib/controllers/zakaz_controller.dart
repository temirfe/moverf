import 'dart:async';
import 'package:get/get.dart';
import '../helpers/api_req.dart';
import 'map_controller.dart';
import '/helpers/misc.dart';
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
  final orderList = [].obs;
  var olIsEmpty = false.obs;
  int loaderPrice = 0;
  int currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    requestCategories();
  }

  void populateList() async {
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
  RxList categories = [].obs; //List<Map>
  RxInt formCtgParId = 0.obs;
  RxInt formCtgChilId = 0.obs;

  Future<void> requestCategories() async {
    categories.assignAll(await getCategories());
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

  /*  @override
  void onClose() {
    super.onClose();
  } */
}
