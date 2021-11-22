import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/helpers/styles.dart';
import '/helpers/misc.dart';

class MyWid {
  static Widget trailing(bool isChecked) {
    Widget icon;
    if (isChecked) {
      icon = const Icon(
        Icons.check,
        color: purpleMain,
      );
    } else {
      icon = const SizedBox(width: 0.0, height: 0.0);
    }
    return icon;
  }

  static Widget elevBtn(String txt, Function onpres) {
    return ElevatedButton(
      onPressed: () {
        onpres();
      },
      style: ElevatedButton.styleFrom(
          shadowColor: purpleMain,
          elevation: 4,
          primary: purpleMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // <-- Radius
          ),
          padding: const EdgeInsets.symmetric(vertical: 16)),
      child: Text(
        txt,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static Widget elevBtnWide(String txt, Function onpres) {
    return SafeArea(
      child: Container(
        width: Get.width,
        padding: const EdgeInsets.all(horizpad),
        child: elevBtn(txt, onpres),
      ),
    );
  }

  static Widget txtBtn(dynamic txt, Function onpres,
      {bool shad = false, bool isLoading = false, bool safearea = true}) {
    Widget widg;
    if (txt is String) {
      widg = textMy(txt, s: 16, w: FontWeight.w600);
    } else {
      widg = txt;
    }
    var elev = 0.0;
    if (shad) {
      elev = 8;
    }
    Widget cont = Container(
      width: Get.width,
      padding: const EdgeInsets.all(horizpad),
      child: TextButton(
        style: TextButton.styleFrom(
            primary: Colors.white,
            backgroundColor: purpleMain,
            shadowColor: Colors.grey[300], //not effective without elevation
            elevation: elev,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6), // <-- Radius
            ),
            padding: const EdgeInsets.symmetric(vertical: 16)),
        onPressed: () {
          onpres();
        },
        child: widg,
      ),
    );
    if (safearea) {
      cont = SafeArea(
        child: cont,
      );
    }
    return cont;
  }

  static Widget loading() {
    return const SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 2,
      ),
    );
  }
}
