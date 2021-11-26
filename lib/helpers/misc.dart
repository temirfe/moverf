import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:hive/hive.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:get/get.dart';
export 'styles.dart';

var prefBox = Hive.box('sharedPref');
//makes print() colorful
void cprint(String msg) {
  ansiColorDisabled = false;
  var pen = AnsiPen()
    ..white()
    //..rgb(r: 1.0, g: 0.8, b: 0.2); //yellow
    ..rgb(r: 0.2, g: 0.6, b: 1); //blue

  debugPrint(pen(msg));
}

int myInt(dynamic v) {
  if (v == null) {
    return 0;
  } else if (v is int) {
    return v;
  } else {
    return int.parse(v);
  }
}

String myString(dynamic v) {
  if (v == null) {
    return '';
  } else if (v is String) {
    return v;
  } else {
    return v.toString();
  }
}

double myDouble(dynamic v) {
  if (v == null) {
    return 0.0;
  } else if (v is double) {
    return v;
  } else if (v is int) {
    return v.toDouble();
  } else if (v is String) {
    v = v.replaceAll(RegExp(r'\s+'), '');
    if (v == '') {
      return 0.0;
    }
    return double.parse(v);
  }
  return 0.0;
}

class Misc {
  static double distance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295; // pi/180
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); //km
  }

  static int currentTs() {
    return (DateTime.now().millisecondsSinceEpoch / 1000).round();
  }

  static DateTime dateFromTs(int ts) {
    return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
  }

  static String dateStrFromTs(int ts, {int format = 1}) {
    return dateStr(dateFromTs(ts), format: format);
  }

  static int tsFromDate(DateTime dt) {
    return (dt.millisecondsSinceEpoch / 1000).round();
  }

  static String dateStr(DateTime dt, {int format = 1}) {
    var dateFormat = DateFormat('d MMMM H:mm', 'ru_RU');
    if (format == 2) {
      dateFormat = DateFormat('d.MM.y');
    }
    if (format == 3) {
      dateFormat = DateFormat('H:mm');
    }
    return dateFormat.format(dt);
  }

  static int dayDif(DateTime given) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    final aDate = DateTime(given.year, given.month, given.day);
    if (aDate == today) {
      return 0;
    } else if (aDate == yesterday) {
      return -1;
    } else if (aDate == tomorrow) {
      return 1;
    }
    return 2;
  }

  static String myCurrency(String v) {
    final formatter = NumberFormat('#,##0', 'fr');
    return formatter.format(int.parse(v));
  }

  static bool empty(dynamic v, {zeroIsEmpty = true}) {
    var vars = ['', null, false];
    if (zeroIsEmpty) {
      vars.add(0);
    }
    if (vars.contains(v)) {
      return true;
    }
    return false;
  }

  static String dateStr2(DateTime dtBegin, {bool long = false}) {
    var val = '';
    var dif = dayDif(dtBegin);

    dynamic todayOrTomorrow;
    if (dif == 0) {
      if (long) {
        todayOrTomorrow = 'Сегодня в ';
      } else {
        todayOrTomorrow = '';
      }
    } else if (dif == -1) {
      todayOrTomorrow = 'Завтра в ';
    }

    if (todayOrTomorrow != null) {
      val = todayOrTomorrow + dateStr(dtBegin, format: 3);
    } else {
      var formatter = DateFormat('d MMM в H:mm', 'ru_RU');
      val = formatter.format(dtBegin);
    }
    return val;
  }

  static String dateStr3(DateTime dt) {
    var val = '';
    var dif = dayDif(dt);

    var yestStr = '';
    var formatter = DateFormat('H:mm');
    /* if (dt.day == now.day) {
      formatter = DateFormat('H:mm');
    } else  */
    if (dif == -1) {
      yestStr = 'Вчера ';
    } else {
      formatter = DateFormat('d MMM H:mm', 'ru_RU');
    }
    val = formatter.format(dt);
    return yestStr + val;
  }

  static void successAlert(String title, String body) {
    Get.snackbar(
      '',
      '',
      titleText: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      messageText: Text(body),
      icon: const Icon(
        Icons.check_circle,
        color: Color(0xff03c4a1),
      ),
      shouldIconPulse: false,
      isDismissible: true,
      duration: const Duration(seconds: 3),
    );
  }
}

class Endpoints {
  //static final String scheme = "https";
  //static final String authority = "youcan.kg";
  static const String gmapApi = 'AIzaSyCR3STKo6nCfM3hRHX9cseRDbeb81Xa7Zo';
  static const String gmapUrl = 'https://maps.googleapis.com/maps/api/place/';
  static const String placesUrl = gmapUrl +
      'autocomplete/json?key=' +
      gmapApi +
      '&types=geocode&components=country:kg&language=ru';
  static const String placeDetailUrl =
      gmapUrl + 'details/json?key=' + gmapApi + '&fields=geometry';
  //static final String urlServer = "https://youcan.prosoft.kg";
  static const String urlLoc = 'http://192.168.88.244:8086';
  static const String urlBase = urlLoc; //change to urlServer
  static const String urlApi = urlBase + 'api/';
  static const String users = urlApi + '/users';
}

class MyImg {
  static const String splashImage = 'assets/splash.png';
  static const String logo = 'assets/images/logo.svg';
  static const String sliderSvg1 = 'assets/images/slider_svg_1.svg';
  static const String sliderSvg2 = 'assets/images/slider_svg_2.svg';
  static const String sliderSvg3 = 'assets/images/slider_svg_3.svg';
  static const String hamburger = 'assets/images/hamburger.png';
  static const String miniContainer1 = 'assets/images/van.svg';
  static const String miniContainer2 = 'assets/images/group.svg';
  static const String miniContainer3 = 'assets/images/towTruck1.svg';
  static const String miniContainer4 = 'assets/images/excav.svg';
  static const String mapMarker = 'assets/images/bbb.png';
  static const String giveMoney = 'assets/images/giveMoney.svg';
}
