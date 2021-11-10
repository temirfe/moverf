import 'package:flutter/material.dart';
//import 'package:hive/hive.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:mover/models/zakaz_model.dart';
import '/helpers/misc.dart';
import '/controllers/zakaz_controller.dart';
import '/helpers/styles.dart';
import '/widgets/map.dart';

class OrderStatus extends StatefulWidget {
  const OrderStatus(this.zkz, {Key? key}) : super(key: key);
  final Zakaz zkz;

  @override
  State<OrderStatus> createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  final ZakazController zctr = Get.find<ZakazController>();
  final MyMap mymap = MyMap();
  final EdgeInsets pad =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  @override
  void initState() {
    super.initState();
    initMap();
    zctr.listenLocation();
  }

  void initMap() {
    zctr.pointsMap.clear();
    zctr.pointsMap[0] = {
      'title': 'Текущее положение',
      'lat': zctr.lastLat,
      'lng': zctr.lastLng
    };
    zctr.pointsMap[1] = {
      'title': widget.zkz.address,
      'lat': widget.zkz.lat,
      'lng': widget.zkz.lng
    };
    zctr.createMarkers(showFirst: false);
    zctr.createPolylines(color: purpleMain);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.yellow,
      body: myBody(),
    );
  }

  Widget myBody() {
    return Stack(
      children: [
        SizedBox(
          height: Get.height * 0.9,
          child: mymap.gmapX(),
          //color: Colors.grey,
        ),
        dss()
        /*  Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
                height: Get.height * 0.35,
                child: ListView(
                  padding: const EdgeInsets.only(top: 0),
                  children: bodyList(),
                ))), */
        /* Align(
            alignment: Alignment.bottomLeft,
            child: TextButton(
              child: const Text('Отменить заказ',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey)),
              onPressed: () {},
            )), */
      ],
    );
  }

  Widget dss() {
    return DraggableScrollableSheet(
        initialChildSize: .3,
        minChildSize: .12,
        maxChildSize: .4,
        builder: (BuildContext context, ScrollController scrollController) {
          return scrollViewContent(scrollController);
        });
  }

  Widget scrollViewContent(ScrollController sc) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 4.0,
              )
            ],
          ),
          child: ListView(
            controller: sc,
            padding: const EdgeInsets.only(top: 10),
            children: bodyList(),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: dragHandle(),
        ),
      ],
    );
  }

  Widget dragHandle() {
    return Container(
      height: 5,
      width: 30,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
    );
  }

  List<Widget> bodyList() {
    var list = <Widget>[
      ListTile(
        title: Text(widget.zkz.longTitle),
        trailing: const Icon(Icons.arrow_right),
      ),
      const Divider(height: 8),
      statuses(),
      const Divider(height: 8),
      contact(),
      TextButton(
        child: const Text('Отменить заказ',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey)),
        onPressed: () {},
      )
    ];

    return list;
  }

  Widget statuses() {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 0, bottom: 10, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          accepted(),
          startBtn(),
          doneBtn(),
        ],
      ),
    );
  }

  Widget contact() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          message(),
          call(),
        ],
      ),
    );
  }

  Widget message() {
    return TextButton(
      onPressed: () {},
      style: greyBtn(),
      child: const Text('Написать'),
    );
  }

  ButtonStyle greyBtn() {
    return TextButton.styleFrom(
        primary: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.normal),
        backgroundColor: greyEb,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6), // <-- Radius
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16));
  }

  Widget call() {
    return TextButton(
      onPressed: () {},
      style: greyBtn(),
      child: const Text('Позвонить'),
    );
  }

  Widget accepted() {
    return Column(children: [
      const TextButton(
        onPressed: null,
        child: Text('Принято'),
      ),
      timer()
    ]);
  }

  Widget startBtn() {
    return Column(children: [
      TextButton(
        child: const Text('Выполняется'),
        onPressed: () {
          zctr.periodic();
        },
      ),
      timer()
    ]);
  }

  Widget doneBtn() {
    return Column(children: [
      TextButton(
        child: const Text('Завершено'),
        onPressed: () {},
      ),
      timer()
    ]);
  }

  Widget timer() {
    return Text('2:34');
  }

  Widget myTile(String lbl, String text, {String tale = ''}) {
    return Container(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          txt2(lbl),
          const SizedBox(height: 4),
          Row(
            children: [Expanded(child: textMy(text, s: 15)), txt2(tale)],
          )
        ],
      ),
    );
  }
}
