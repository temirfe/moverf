import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/widgets/my_widgets.dart';
import '/helpers/styles.dart';
import '/helpers/misc.dart';

void errorAlert(message) {
  Get.snackbar('', '',
      titleText: const SizedBox(
        height: 0,
        width: 0,
      ),
      messageText: Text(
        message.toString(),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      icon: const Icon(
        Icons.error,
        color: Color(0xffd00000),
      ),
      shouldIconPulse: true,
      isDismissible: true,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.yellow);
}

void successAlert(String message) {
  Get.snackbar(
    '',
    '',
    titleText: const SizedBox(
      height: 0,
      width: 0,
    ),
    messageText: Text(
      message.toString(),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
    icon: const Icon(
      Icons.check_circle,
      color: Color(0xff03c4a1),
    ),
    shouldIconPulse: false,
    isDismissible: true,
    duration: const Duration(seconds: 3),
  );
}

void warningAlert(String message) {
  Get.snackbar(
    '',
    '',
    titleText: const SizedBox(height: 0, width: 0),
    messageText: Text(
      message.toString(),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
    ),
    icon: const Icon(
      Icons.warning,
      color: Color(0xfff5a25d),
    ),
    shouldIconPulse: false,
    isDismissible: true,
    duration: Duration(seconds: 3),
  );
}

void snack2(String title, String text, Icon icon) {
  Get.snackbar(title, text,
      snackPosition: SnackPosition.BOTTOM,
      borderRadius: 6,
      barBlur: 16,
      icon: icon,
      shouldIconPulse: false,
      backgroundColor: Colors.white,
      boxShadows: [
        BoxShadow(
            blurRadius: 2,
            spreadRadius: 2,
            color: Colors.grey[350]!,
            offset: const Offset(1, 2))
      ],
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10));
}

void showMdlBtm({BuildContext? cntx}) {
  cntx ??= Get.context;
  showModalBottomSheet(
      context: cntx!,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.white,
      builder: (builder) {
        return _sheetContent();
      });
}

Widget _sheetContent() {
  return Container(
    //height: 150.0,
    color: Colors.purple[50],
    child: Column(
        //crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              const SizedBox(width: 25),
              Expanded(child: Center(child: textMy('Дата и время', s: 15))),
              IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  padding: const EdgeInsets.all(0),
                  icon: const Icon(Icons.close))
            ],
          ),
          const ListTile(
            title: Text('yoa'),
            subtitle: Text('sub'),
          ),
          MyWid.txtBtn('Готово', () {}, shad: true),
        ]),
  );
}

void showBtm(BuildContext context) {
  cprint('showBtm');
  Scaffold.of(context).showBottomSheet<void>(
    (BuildContext context) {
      return Container(
        height: 200,
        color: Colors.amber,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('BottomSheet'),
              ElevatedButton(
                  child: const Text('Close BottomSheet'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          ),
        ),
      );
    },
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
    ),
    clipBehavior: Clip.antiAliasWithSaveLayer,
  );
}
