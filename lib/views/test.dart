import 'package:flutter/material.dart';
import 'dart:convert';
import '/helpers/misc.dart';
import 'package:get/get.dart';
import '/controllers/zakaz_controller.dart';

class Test extends StatelessWidget {
  Test({Key? key}) : super(key: key);

  final TextEditingController _controller = TextEditingController();
  final ZakazController zctr = Get.find<ZakazController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _acceptBtn(),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: 'SMS code'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.text != '') {
            zctr.verifySMS(_controller.text);
          } else {
            cprint('enter sms');
          }
        },
        tooltip: 'Submit sms',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _acceptBtn() {
    return TextButton(
        onPressed: () {
          zctr.enterPhone();
        },
        child: const Text('verify'));
  }
}
