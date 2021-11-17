//import 'package:intl/intl.dart';
//import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/helpers/misc.dart';
import '/controllers/zakaz_controller.dart';

class Profile {
  final ZakazController zctr = Get.find<ZakazController>();
  int id;
  int? rating;
  int? balance;
  int ctgId;
  String? note;
  int createdAt;
  Map user;
  Map? vehicle;
  //int onShift;
  //int onDuty;

  Profile.fromJson(Map json)
      : id = json['id'],
        rating = json['rating'],
        balance = json['balance'],
        ctgId = json['category_id'],
        note = json['note'],
        createdAt = json['created_at'],
        user = json['user'],
        vehicle = json['vehicle'];

  // Map<String, dynamic> toJson(){
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['name'] = this.name;
  //   return data;
  // }
  /* set setNote(String val) {
    note = val;
  } 
  int get tel {
    return phone;
  }
  */
  String get createDate {
    return Misc.dateStr3(Misc.dateFromTs(createdAt));
  }

  int? get ctgParentId {
    if (zctr.childParent.containsKey(ctgId)) {
      return zctr.childParent[ctgId]!;
    }
  }

  String get ctgParentTitle {
    if (ctgParentId != null) {
      return zctr.ctgTitles[ctgParentId]!;
    }
    return '';
  }

  String get ctgTitle {
    return zctr.ctgTitles[ctgId]!;
  }

  String get ctgFullTitle {
    var title = ctgTitle;
    if (ctgParentTitle != '') {
      title = ctgParentTitle + ' ' + ctgTitle;
    }
    return title;
  }

  int get ctgPrice {
    return zctr.ctgPrice[ctgId]!;
  }
}
