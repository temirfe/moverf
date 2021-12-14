import 'dart:async';
import 'package:get/get.dart';
import '../helpers/api_req.dart';
import 'map_controller.dart';
import '/helpers/misc.dart';
import 'package:mover/helpers/alerts.dart';
import 'package:mover/models/zakaz_model.dart';
import 'package:mover/views/order_status.dart';
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
  final myOrderList = [].obs;
  var olIsEmpty = false.obs;
  var myOlIsEmpty = false.obs;
  int loaderPrice = 0;
  int currentPage = 1;
  int currentPageMy = 1;
  var isLoadingMap = <String, bool>{}.obs;
  var statusMap = <int, int>{}.obs;
  Map<int, Zakaz> zakazMap = {};

  @override
  void onInit() {
    super.onInit();
    requestCategories();
  }

  /* @override
  void onReady() {
    super.onReady();
    listenLocation();
  } */

  void populateList({bool refreshList = false}) async {
    await getLocation();
    requestOrders(refresh: refreshList);
    requestMyOrders();
  }

  void requestOrders({bool refresh = false}) async {
    var ctg = 'zakaz';
    if (xCurrentPage[ctg] != 0 && currentPage < xPageCount[ctg]!) {
      currentPage = (xCurrentPage[ctg]! + 1);
    }

    var list = await getOrders();
    if (list.isNotEmpty) {
      if (refresh) {
        orderList.assignAll(list);
      } else {
        orderList.addAll(list);
      }
    } else {
      olIsEmpty.value = true;
    }
  }

  void requestMyOrders() async {
    var ctg = 'myOrders';
    if (xCurrentPage[ctg] != 0 && currentPageMy < xPageCount[ctg]!) {
      currentPageMy = (xCurrentPage[ctg]! + 1);
    }

    var list = await getOrders(params: 'p=true', forwho: 'myOrders');
    if (list.isNotEmpty) {
      myOrderList.addAll(list);
    } else {
      myOlIsEmpty.value = true;
    }
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

  void accept(Zakaz zkz) async {
    if (prof == null) {
      errorAlert('Заполните профиль');
    } else {
      var res = await postAction(
          'accept', {'id': zkz.id.toString(), 'zctg_id': zkz.ctgId.toString()});
      if (res == 0) {
        errorAlert('Произошла ошибка');
      } else {
        zakazMap[zkz.id]!.statusId = res;
        zctr.statusMap[zkz.id] = res;
        if (res == Zakaz.statusApproaching) {
          bgLocListen(zkz.id, zkz.userId);
        }
        await Get.off(OrderStatus(zkz.id));
      }
    }
  }

  void approach(Zakaz zkz) async {
    //zctr.periodic();
    zctr.isLoadingMap['approach'] = true;
    var res = await postAction(
        'approach', {'id': zkz.id.toString(), 'zctg_id': zkz.ctgId.toString()});
    if (res is int && res == 0) {
      zkz.approaching();
      bgLocListen(zkz.id, zkz.userId);
    } else {
      errorAlert('Произошла ошибка');
      zctr.isLoadingMap['approach'] = false;
    }
  }

  void start(Zakaz zkz) async {
    //zctr.periodic();
    zctr.isLoadingMap['start'] = true;
    var res = await postAction(
        'start', {'id': zkz.id.toString(), 'zctg_id': zkz.ctgId.toString()});
    if (res is int && res == 0) {
      zkz.started();
    } else {
      errorAlert('Произошла ошибка');
      zctr.isLoadingMap['start'] = false;
    }
  }

  void finish(Zakaz zkz) async {
    zctr.isLoadingMap['finish'] = true;
    var res = await postAction(
        'finish', {'id': zkz.id.toString(), 'zctg_id': zkz.ctgId.toString()});
    if (res is int && res == 0) {
      zkz.done();
      stopBgLoc();
    } else {
      errorAlert('Произошла ошибка');
      zctr.isLoadingMap['finish'] = false;
    }
  }

  void cancel(Zakaz zkz) async {
    var res = await postAction(
        'cancel', {'id': zkz.id.toString(), 'zctg_id': zkz.ctgId.toString()});
    if (res is int && res != 0) {
      zkz.cancel(res);
      stopBgLoc();
      Get.back();
    } else {
      errorAlert('Произошла ошибка');
    }
  }

  /* Future<int> orderAction(String action, Map param) async {
    return await postAction(action, param);
  } */

  /*  @override
  void onClose() {
    super.onClose();
  } */
}
