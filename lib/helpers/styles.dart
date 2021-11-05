import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color filterBg = Color(0xFFedf3f4);
const Color greyEb = Color(0xFFebebeb);
const Color greyEf = Color(0xFFefefef);
const Color greyText = Color(0xFF757F8C);
const Color purpleMain = Color(0xFF613EEA);
const Color purpleLight = Color(0xFFd2c8f9);
const double horizpad = 13.0;

Text textMy(String txt, {double? s, Color? c, FontWeight? w}) {
  /* if (size == null) {
    if (Get.context != null &&
        Theme.of(Get.context!).textTheme.bodyText2 != null) {
      size = Theme.of(Get.context!).textTheme.bodyText2!.fontSize!;
    } else {
      size = 14;
    }
  }

  if (weight == null) {
    if (Get.context != null &&
        Theme.of(Get.context!).textTheme.bodyText2 != null) {
      weight = Theme.of(Get.context!).textTheme.bodyText2!.fontWeight!;
    } else {
      weight = FontWeight.normal;
    }
  } */

  return Text(
    txt,
    style: TextStyle(fontSize: s, color: c, fontWeight: w),
  );
}

Text txt2(String txt, {double s = 14}) {
  return textMy(txt, s: s, c: greyText);
}

Text txtEm(String txt) {
  return textMy(txt, s: 16, w: FontWeight.w600);
}

Text txtEm2(String txt) {
  return textMy(txt, s: 16, w: FontWeight.w600, c: greyText);
}

Text textH6(String txt, {BuildContext? ctx, Color? clr}) {
  TextStyle? stl = const TextStyle();
  if (ctx == null && Get.context != null) {
    ctx = Get.context;
    stl = Theme.of(ctx!).textTheme.headline6;
    if (clr != null) {
      stl = stl?.copyWith(color: clr);
    }
  }

  return Text(
    txt,
    style: stl,
  );
}
