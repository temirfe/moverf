import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/helpers/styles.dart';
import '/helpers/misc.dart';

class MyWid {
  static Widget trailing(bool isChecked) {
    var icon;
    if (isChecked) {
      icon = Icon(
        Icons.check,
        color: purpleMain,
      );
    } else {
      icon = Container(width: 0.0, height: 0.0);
    }
    return icon;
  }

  static Widget elevBtn(String txt, Function onpres) {
    return ElevatedButton(
      onPressed: () {
        onpres();
      },
      child: Text(
        txt,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
          shadowColor: purpleMain,
          elevation: 4,
          primary: purpleMain,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // <-- Radius
          ),
          padding: EdgeInsets.symmetric(vertical: 16)),
    );
  }

  static Widget elevBtnWide(String txt, Function onpres) {
    return SafeArea(
      child: Container(
        width: Get.width,
        padding: EdgeInsets.all(horizpad),
        child: elevBtn(txt, onpres),
      ),
    );
  }

  static Widget txtBtn(String txt, Function onpres,
      {bool shad = false, bool isLoading = false}) {
    var elev = 0.0;
    if (shad) {
      elev = 8;
    }
    return SafeArea(
      child: Container(
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
          child: textMy(txt, s: 16, w: FontWeight.w600),
        ),
      ),
    );
  }
}
