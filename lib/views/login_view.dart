import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/controllers/zakaz_controller.dart';
import '/helpers/misc.dart';
import '/widgets/my_widgets.dart';

class LoginView extends StatelessWidget {
  LoginView({Key? key}) : super(key: key);
  final ZakazController zctr = Get.find<ZakazController>();
  final logo = SizedBox(
    width: 150,
    child: SvgPicture.asset(
      'assets/images/logo.svg',
      alignment: Alignment.center,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          children: [
            const SizedBox(height: 20),
            codeView(),
            login(),
            countdown()
          ],
        ));
  }

  Widget login() {
    return Obx(() {
      if (zctr.codeView.value) {
        return const SizedBox();
      }
      if (zctr.phoneField.text == '') {
        zctr.phoneField.text = '+996';
        zctr.phoneField.selection =
            TextSelection.fromPosition(const TextPosition(offset: 4));
      }
      String? err;
      if (zctr.phoneFieldError.value != '') {
        err = zctr.phoneFieldError.value;
      }
      return Column(
        children: [
          //Text('номер телефона'),
          logo,
          const SizedBox(height: 30),
          Container(
            // height: 10,
            // width: double.infinity,
            margin: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
            child: TextField(
              //maxLength: 13,
              //autofocus: true,
              controller: zctr.phoneField,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Номер телефона',
                errorText: err,
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.yellow[800]!, width: 2.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          submitPhoneBtn(zctr.isPhoneSubmitting.value),
        ],
      );
    });
  }

  Widget codeView() {
    return Obx(() {
      if (zctr.codeView.value) {
        String? err;
        if (zctr.codeFieldError.value != '') {
          err = zctr.codeFieldError.value;
        }
        return Column(
          children: [
            logo,
            const SizedBox(height: 30),
            Container(
              // height: 10,
              // width: double.infinity,
              margin: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
              child: TextField(
                //textAlign: TextAlign.right,
                autofocus: true,
                // maxLength: 8,
                controller: zctr.codeField,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onChanged: (val) {
                  if (val.length == 6) {
                    sendSms();
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Введите код из СМС',
                  errorText: err,
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.yellow[800]!, width: 2.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            submitSmsBtn(zctr.isSMSverifying.value),
          ],
        );
      }

      return const SizedBox();
    });
  }

  Widget submitSmsBtn(bool isLoading) {
    Widget contnt;
    Function onPresd;
    if (isLoading) {
      contnt = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      );
      onPresd = () {};
    } else {
      contnt =
          const Text('Отправить код', style: TextStyle(color: Colors.white));
      onPresd = () {
        sendSms();
      };
    }
    return MyWid.txtBtn(contnt, onPresd);
  }

  Widget submitPhoneBtn(bool isLoading) {
    Widget contnt;
    Function onPresd;
    if (isLoading) {
      contnt = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      );
      onPresd = () {};
    } else {
      contnt = const Text('Отправить', style: TextStyle(color: Colors.white));
      onPresd = () {
        if (zctr.phoneField.text.length < 13) {
          zctr.phoneFieldError.value = 'Заполните поле';
        } else {
          zctr.phoneFieldError.value = '';
          zctr.enterPhone();
        }
      };
    }

    return MyWid.txtBtn(contnt, onPresd);
  }

//codeView

  void sendSms() {
    var codeText = zctr.codeField.text.trim();
    if (zctr.codeField.text.length < 6) {
      zctr.codeFieldError.value = 'Заполните поле';
    } else {
      zctr.codeFieldError.value = '';
    }
    zctr.verifySMS(codeText);
  }

  Widget countdown() {
    return GetX<ZakazController>(builder: (ctr) {
      Widget time = Text('${zctr.smsTimerValue.value}',
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center);
      if (zctr.smsTimerValue.value == 0) {
        time = const SizedBox();
      }
      return Container(
          height: 50,
          width: double.infinity,
          padding: const EdgeInsets.only(top: 20),
          child: time);
    });
  }
}
