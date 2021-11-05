import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:hive/hive.dart';
import 'dart:math' show cos, sqrt, asin;
export 'styles.dart';

var prefBox = Hive.box('sharedPref');
void saveAuth(Map<String, dynamic> map) {
  prefBox.put('userId', map['id']);
  prefBox.put('username', map['username']);
  prefBox.put('authKey', map['auth_key']);
}

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
    var dateFormat = DateFormat('d MMMM H:m', 'ru_RU');
    if (format == 2) {
      dateFormat = DateFormat('d.MM.y');
    }
    return dateFormat.format(dt);
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
    var now = DateTime.now();
    var tomorrow = now.add(const Duration(days: 1));

    dynamic todayOrTomorrow;
    if (dtBegin.day == now.day) {
      if (long) {
        todayOrTomorrow = 'Сегодня в ';
      } else {
        todayOrTomorrow = '';
      }
    } else if (dtBegin.day == tomorrow.day) {
      todayOrTomorrow = 'Завтра в ';
    }

    if (todayOrTomorrow != null) {
      var formatter = DateFormat('H:mm');
      val = todayOrTomorrow + formatter.format(dtBegin);
    } else {
      var formatter = DateFormat('d MMMM в H:mm', 'ru_RU');
      val = formatter.format(dtBegin);
    }
    return val;
  }

  static String dateStr3(DateTime dt) {
    var val = '';
    var now = DateTime.now();
    var yest = now.subtract(const Duration(days: 1));

    var yestStr = '';
    var formatter = DateFormat('H:mm');
    /* if (dt.day == now.day) {
      formatter = DateFormat('H:mm');
    } else  */
    if (dt.day == yest.day) {
      yestStr = 'Вчера ';
    } else {
      formatter = DateFormat('d MMM H:mm', 'ru_RU');
    }
    val = formatter.format(dt);
    return yestStr + val;
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
