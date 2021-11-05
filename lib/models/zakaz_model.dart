//import 'package:intl/intl.dart';
//import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/helpers/misc.dart';
import '/controllers/zakaz_controller.dart';

class Zakaz {
  final ZakazController zctr = Get.find<ZakazController>();
  int id;
  String address;
  String phone;
  double lat;
  double lng;
  String note;
  int statusId;
  int shouldStart;
  int createdAt;
  int? start;
  int? finish;
  int? duration;
  int userId;
  int ctgId;
  String loaders;
  List destinations;
  Map? serviceman; //<string,dynamic>

  /* Zakaz(
      {required this.id,
      required this.address,
      required this.phone,
      required this.lat,
      required this.lng,
      required this.note,
      required this.statusId,
      required this.shouldStart,
      this.start,
      this.finish,
      this.duration,
      required this.userId,
      required this.ctgId,
      required this.destinations}); */

  Zakaz.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        address = json['address'],
        phone = json['phone'],
        lat = json['lat'],
        lng = json['lng'],
        note = json['note'],
        statusId = json['status'],
        shouldStart = json['should_start_at'],
        createdAt = json['created_at'],
        start = json['started_at'],
        finish = json['finished_at'],
        duration = json['duration'],
        userId = json['created_by'],
        ctgId = json['ctg_load']['category'],
        loaders = json['ctg_load']['loaders'],
        destinations = json['destinations'],
        serviceman = json['serviceman'];

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

  String get startDate {
    return Misc.dateStr2(Misc.dateFromTs(shouldStart));
  }

  String get startDateLong {
    return Misc.dateStr2(Misc.dateFromTs(shouldStart), long: true);
  }

  String get createDate {
    return Misc.dateStr3(Misc.dateFromTs(createdAt));
  }

  String get ctgParentTitle {
    if (zctr.childParent.containsKey(ctgId)) {
      var parId = zctr.childParent[ctgId]!;
      return zctr.ctgTitles[parId]!;
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

  String get longTitle {
    var title = ctgFullTitle;
    if (loaders != '0') {
      title += ' + $loaders грузчика';
    }
    return title;
  }

  int get ctgPrice {
    return zctr.ctgPrice[ctgId]!;
  }

  String get distance {
    var ret = '';
    if (zctr.lastLat != 0.0) {
      var dist = Misc.distance(lat, lng, zctr.lastLat, zctr.lastLng);
      if (dist < 0.1) {
        ret = 'рядом';
      } else {
        ret = num.parse(dist.toStringAsFixed(2)).toString() + ' км';
      }
    }
    return ret;
  }
}
