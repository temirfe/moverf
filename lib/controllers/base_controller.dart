import 'package:get/get.dart';
/* import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:http/http.dart' as http; */
//import '/helpers/misc.dart';

class BaseController extends GetxController {
  Map<String, int> xPageCount = {'zakaz': 0, 'page': 0};
  Map<String, int> xTotalCount = {'zakaz': 0, 'page': 0};
  Map<String, int> xCurrentPage = {'zakaz': 0, 'page': 0};
  /* @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  } */
}
