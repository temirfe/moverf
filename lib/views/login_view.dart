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
    width: 100,
    child: SvgPicture.asset(
      'assets/images/logo.svg',
      alignment: Alignment.center,
    ),
  );

  Widget login() {
    if (zctr.phoneField.text == '') {
      zctr.phoneField.text = '+996';
      zctr.phoneField.selection =
          TextSelection.fromPosition(const TextPosition(offset: 4));
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
          child: GetX<ZakazController>(builder: (ctr) {
            String? err;
            if (ctr.phoneFieldError.value != '') {
              err = ctr.phoneFieldError.value;
            }
            return TextField(
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
            );
          }),
        ),
        const SizedBox(height: 40),
        submitPhoneBtn(),
        countdown()
      ],
    );
  }

  Widget codeView() {
    return Column(
      children: [
        logo,
        const SizedBox(height: 30),
        Container(
          // height: 10,
          // width: double.infinity,
          margin: const EdgeInsets.only(top: 5.0, left: 20.0, right: 20.0),
          child: GetX<ZakazController>(
            builder: (ctr) {
              String? err;
              if (ctr.codeFieldError.value != '') {
                err = ctr.codeFieldError.value;
              }
              return TextField(
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
              );
            },
          ),
        ),
        const SizedBox(height: 40),
        submitSmsBtn(),
        Container(
          height: 50,
          padding: const EdgeInsets.only(top: 20),
        )
      ],
    );
  }

  Widget submitSmsBtn() {
    Widget contnt;
    Function onPresd;
    if (zctr.isSMSverifying.value) {
      contnt = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          strokeWidth: 2,
        ),
      );
      onPresd = () {};
    } else {
      contnt =
          const Text('Отправить код', style: TextStyle(color: Colors.black));
      onPresd = () {
        sendSms();
      };
    }
    return MyWid.txtBtn(contnt, onPresd);
  }

  Widget submitPhoneBtn() {
    Widget contnt;
    Function onPresd;
    if (zctr.isPhoneSubmitting.value) {
      contnt = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          strokeWidth: 2,
        ),
      );
      onPresd = () {};
    } else {
      contnt = const Text('Отправить', style: TextStyle(color: Colors.black));
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
    // Future.delayed(Duration(seconds: 2), () {
    //Future<bool> isLoged = mainCtr.signInWithOTP(codeText, mainCtr.verificationId);
    if (zctr.codeField.text.length < 6) {
      zctr.codeFieldError.value = 'Заполните поле';
    } else {
      zctr.codeFieldError.value = '';
    }
    Future<bool> isLoged = zctr.verifySMS(codeText);
    isLoged.then((value) {
      if (value) {
        //zctr.initem();
      }
    });
    // });
  }

  Widget countdown() {
    return GetX<ZakazController>(builder: (ctr) {
      Widget time = Text('${zctr.smsTimerValue.value}',
          style: const TextStyle(color: Colors.grey));
      if (zctr.smsTimerValue.value == 0) {
        time = Container();
      }
      return Container(
          height: 50, padding: const EdgeInsets.only(top: 20), child: time);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      backgroundColor: Colors.white,
      body: Obx(() {
        var list = <Widget>[];
        if (zctr.codeView.value) {
          list.add(codeView());
        } else {
          list.add(login());
        }

        return ListView(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: list,
        );
      }),
    );
  }
}
