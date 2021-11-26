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

  static const statusCreated = 1;
  static const statusAccepted = 2;
  static const statusApproaching = 3;
  static const statusInProgress = 4;
  static const statusCompleted = 5;
  static const statusCanceled = 10;

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

  String get status {
    return statusStr(statusId);
  }

  static String statusStr(int sid) {
    var ret = '';
    switch (sid) {
      case statusAccepted:
        ret = 'Принято';
        break;
      case statusApproaching:
        ret = 'В пути';
        break;
      case statusInProgress:
        ret = 'Выполняется';
        break;
      case statusCompleted:
        ret = 'Завершено';
        break;
      case statusCanceled:
        ret = 'Отменено';
        break;
      default:
        ret = 'Создано';
    }
    return ret;
  }

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

  int get loadersPrice {
    return int.parse(loaders) * zctr.loaderPrice;
  }

  int get finalPrice {
    return ctgPrice + loadersPrice;
  }

  int get sum {
    if (duration != null) {
      var minutes = (duration! / 60).round();
      if (minutes < 60) {
        minutes = 60;
      }
      var hours = minutes / 60;
      return (finalPrice * hours).round();
    }
    return 0;
  }

  String get durStr {
    var ret = '';
    if (duration != null) {
      if (duration! < 60) {
        return '$duration с';
      }
      var minutes = (duration! / 60).floor();
      var modulo = minutes % 60;
      var hoursWhole = ((minutes - modulo) / 60).round();
      if (hoursWhole > 0) {
        ret = '$hoursWhole ч ';
      }
      if (modulo > 0) {
        ret += '$modulo м';
      }
    }
    return ret;
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

  void approaching() {
    zctr.statusMap[id] = statusApproaching;
    statusId = statusApproaching;
  }

  void started() {
    zctr.statusMap[id] = statusInProgress;
    statusId = statusInProgress;
    start = Misc.currentTs();
    zctr.durationTimer(start!);
  }

  void done() {
    zctr.statusMap[id] = statusCompleted;
    statusId = statusCompleted;
    finish = Misc.currentTs();
    if (start != null) {
      duration = finish! - start!;
      cprint('done s $start, f $finish, d $duration');
    }
    zctr.cancelTimer();
  }

  void cancel(int statId) {
    zctr.statusMap[id] = statusId;
    statusId = statId;
  }
}
