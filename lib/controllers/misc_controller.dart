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
import '/helpers/alerts.dart';
import '/helpers/api_req.dart';
import '/models/profile_model.dart';
/* 
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'package:http/http.dart' as http; */

class MiscController extends BaseController {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  var authFirebase = FirebaseAuth.instance;

  String? smsVerId;

  var isSMSverifying = false.obs;
  var phoneField = TextEditingController();
  var codeField = TextEditingController();
  var phoneFieldError = ''.obs;
  var codeFieldError = ''.obs;
  var codeView = false.obs;
  Timer? smsTimer;
  var smsTimerValue = 0.obs;
  Timer? durTimer;
  var durTimerValue = 0.obs;

  var profileFormIsDirty = false.obs;
  Profile? prof;
  var isSubmittingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    _onNotif();
    _getToken();
    _getDeviceId();
    downloadProfile();
  }

  void downloadProfile() async {
    if (prefBox.get('userId') != null) {
      var pro = await getProfile();
      if (pro != null) {
        prof = Profile.fromJson(pro);
        await prefBox.put('name', prof!.user['name']);
      }
    }
  }

  void enterPhone() async {
    startTimer();
    codeView(true);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneField.text,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) {
        cprint('verificationCompleted $credential');
        userServer();
      },
      verificationFailed: (FirebaseAuthException e) {
        cprint('verificationFailed $e');
        if (e.code == 'invalid-phone-number') {
          phoneFieldError.value = 'Неправильный формат';
        }
        codeView(false);
      },
      codeSent: (String vid, int? resendToken) {
        cprint('codeSent $vid, rt: $resendToken');
        smsVerId = vid;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        codeView(false);
        //cprint('codeAutoRetrievalTimeout $verificationId');
      },
    );
  }

  void saveAuth(Map<String, dynamic> map) async {
    await prefBox.put('userId', map['id']);
    await prefBox.put('name', map['name']);
    await prefBox.put('phone', phoneField.text);
    await prefBox.put('authKey', map['auth_key']);
    downloadProfile();
  }

  void removeAuth() {
    prefBox.delete('userId');
    prefBox.delete('name');
    prefBox.delete('authKey');
    prefBox.delete('phone');
  }

  //SignOut
  void signOut() async {
    cprint('signing out');
    if (authFirebase.isBlank != null && !authFirebase.isBlank!) {
      cprint('authFirebase signing out');
      await authFirebase.signOut();
    } else {
      cprint('authFirebase is $authFirebase');
    }
    codeView(false);
    phoneField.clear();
    codeField.clear();
    removeAuth();
    await Get.toNamed('/login');
  }

  Future<bool> verifySMS(String smsCode) async {
    if (smsVerId != null) {
      isSMSverifying(true);
      var cred = PhoneAuthProvider.credential(
          verificationId: smsVerId!, smsCode: smsCode);
      try {
        var ucred = await authFirebase.signInWithCredential(cred);
        if (ucred.user != null) {
          userServer();
        }
      } on FirebaseAuthException catch (e) {
        cprint(' FirebaseAuthException code: ${e.code}');
        cprint(' FirebaseAuthException message: ${e.message}');
        /* if (e.code == 'firebase_auth/invalid-verification-code') {
        errorAlert('Неверный код');
      } */
        if (e.code == 'invalid-verification-code') {
          codeFieldError.value = 'Неверный код';
          errorAlert('Неверный код');
        } else {
          codeFieldError.value = 'Ошибка, попробуйте позднее';
        }
        isSMSverifying(false);
        cprint('$e');
      } on PlatformException catch (e) {
        cprint(' PlatformException code: ${e.code}');
        cprint(' PlatformException message: ${e.message}');
        isSMSverifying(false);
      }
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

  void userServer() async {
    cancelTimer();
    var res = await postUser({
      'phone': phoneField.text,
      'device_id': prefBox.get('deviceId'),
      'fcm_token': prefBox.get('tokenId')
    });
    if (res != null) {
      cprint('saving user $res');
      saveAuth(res);
      if (res['is_new']) {
        await Get.offNamed('/profile');
      } else {
        await Get.offNamed('/list');
      }
    } else {
      cprint('userServer fail $res');
    }
  }

  void startTimer() {
    smsTimerValue.value = 60;
    const oneSec = Duration(seconds: 1);
    smsTimer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (smsTimerValue.value == 0) {
          timer.cancel();
        } else {
          smsTimerValue.value--;
        }
      },
    );
  }

  void durationTimer(int beginTs) {
    durTimerValue.value = (Misc.currentTs() - beginTs);
    const oneSec = Duration(seconds: 1);
    durTimer = Timer.periodic(
      oneSec,
      (Timer timer) {
        durTimerValue.value++;
        cprint('durTimer ${durTimerValue.value}');
      },
    );
  }

  void cancelTimer() {
    if (smsTimer != null) {
      smsTimerValue.value = 0;
      smsTimer!.cancel();
    }
    if (durTimer != null) {
      durTimer!.cancel();
    }
  }

  @override
  void onClose() {
    cancelTimer();
    super.onClose();
  }
}
