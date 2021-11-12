import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'base_controller.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart' show PlatformException;
import '/helpers/misc.dart';
/* 
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:http/http.dart' as http; */

class MiscController extends BaseController {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  var authFirebase = FirebaseAuth.instance;

  String? smsVerId;

  var isLogedIn = false.obs;
  var isPhoneSubmitting = false.obs;
  var isSMSverifying = false.obs;
  var phoneField = TextEditingController();
  var codeField = TextEditingController();
  var phoneFieldError = ''.obs;
  var codeFieldError = ''.obs;
  var codeView = false.obs;
  Timer? smsTimer;
  var smsTimerValue = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _onNotif();
  }

  void enterPhone() async {
    isPhoneSubmitting(true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      //phoneNumber: phoneField.text,
      phoneNumber: '+996702805125',
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        cprint('verificationCompleted $credential');
      },
      verificationFailed: (FirebaseAuthException e) {
        cprint('verificationFailed $e');
        if (e.code == 'invalid-phone-number') {
          phoneFieldError.value = 'Неправильный формат';
        }
      },
      codeSent: (String vid, int? resendToken) {
        cprint('codeSent $vid, rt: $resendToken');
        smsVerId = vid;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        //cprint('codeAutoRetrievalTimeout $verificationId');
      },
    );
    isPhoneSubmitting(false);
  }

  Future<bool> verifySMS(String smsCode) async {
    if (smsVerId != null) {
      var cred = PhoneAuthProvider.credential(
          verificationId: smsVerId!, smsCode: smsCode);
      cprint('cred $cred');
      var ucred = await authFirebase.signInWithCredential(cred);
      cprint('ucred $ucred');
    } else {
      cprint('smsVerId is null: $smsVerId');
    }
    return false;
  }

  void _onNotif() async {
    var settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        //print('Message data: ${message.data}');

        if (message.notification != null) {
          var title = message.notification!.title ?? '';
          var body = message.notification!.body ?? '';
          Misc.successAlert(title, body);
        }
      });
    }
  }

  void _getToken() async {
    await _fcm.getToken().then((token) {
      cprint('Device Token: $token');
      prefBox.put('tokenId', token);
    });
  }

  void _getDeviceId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        //cprint('androidId ${build.androidId}');
        await prefBox.put('deviceId', build.androidId);
        //cprint("Device id: ${build.androidId}");
        //return build.androidId; //UUID for Android
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        await prefBox.put('deviceId', data.identifierForVendor);
        //return data.identifierForVendor; //UUID for iOS
      }
    } on PlatformException {
      cprint('Failed to get platform version');
    }
    //return '';
  }

  void userServer() {
    /* final ApiServices apiClient = ApiServices();
    Map param = {};
    param['device_id'] = session.getString('deviceId');
    param['token'] = session.getString('tokenId');
    apiClient.postUser(param); //returns user sensor id */
  }

  void startTimer() {
    smsTimerValue.value = 60;
    const oneSec = Duration(seconds: 1);
    smsTimer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (smsTimerValue.value == 0) {
          timer.cancel();
          isPhoneSubmitting(false);
        } else {
          smsTimerValue.value--;
        }
      },
    );
  }

  @override
  void onClose() {
    if (smsTimer != null) {
      smsTimer!.cancel();
    }
    super.onClose();
  }
}
