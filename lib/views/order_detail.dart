import 'package:flutter/material.dart';
//import 'package:hive/hive.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:mover/models/zakaz_model.dart';
import '/helpers/misc.dart';
import '/controllers/zakaz_controller.dart';
import '/helpers/styles.dart';
import '/widgets/map.dart';
import '/widgets/my_widgets.dart';
import '../helpers/api_req.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail(this.zakazId, {Key? key}) : super(key: key);
  final int zakazId;

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final ZakazController zctr = Get.find<ZakazController>();
  final EdgeInsets pad =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  Zakaz? zkz;

  @override
  void initState() {
    super.initState();
    zkz = zctr.zakazMap[widget.zakazId]!;
    initMap();
    checkStatus();
  }

  void checkStatus() async {
    var freshStatus = await getStatus(zkz!.id);
    if (freshStatus != zkz!.statusId) {
      setState(() {
        zctr.zakazMap[widget.zakazId]!.statusId = freshStatus;
        zctr.statusMap[widget.zakazId] = freshStatus;
      });
    }
  }

  void initMap() {
    zctr.pointsMap.clear();
    zctr.pointsMap[0] = {
      'title': zkz!.address,
      'lat': zkz!.lat,
      'lng': zkz!.lng
    };
    for (Map dest in zkz!.destinations) {
      var key = 1;
      zctr.pointsMap[key] = {
        'title': dest['address'],
        'lat': dest['lat'],
        'lng': dest['lng']
      };
      key++;
    }
    zctr.createMarkers();
    zctr.createPolylines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(zkz!.longTitle), centerTitle: true),
      backgroundColor: Colors.white,
      body: myBody(),
      bottomSheet: _acceptBtn(),
    );
  }

  Widget myBody() {
    return Column(children: [
      SizedBox(
        height: Get.height / 4,
        child: MyMap(),
        //child: const SizedBox(),
      ),
      Expanded(
          child: ListView(
        children: bodyList(),
      ))
    ]);
  }

  List<Widget> bodyList() {
    var list = <Widget>[
      status(),
      myTile('Когда', zkz!.startDateLong),
      const Divider(height: 8),
      myTile('Откуда', zkz!.address, tale: zkz!.distance),
      const Divider(height: 8),
      dest(),
      const Divider(height: 8),
      _totalPrice()
    ];

    return list;
  }

  Widget status() {
    if (zkz!.statusId != 1) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          txt2('Статус:'),
          const SizedBox(width: 16),
          Text(Zakaz.statusStr(zkz!.statusId)),
        ]),
      );
    }
    return const SizedBox();
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

  Widget dest() {
    var chldrn = <Widget>[txt2('Куда'), const SizedBox(height: 4)];
    var prevLat = zkz!.lat;
    var prevLng = zkz!.lng;
    for (Map dest in zkz!.destinations) {
      var dist = _distance(dest['lat'], dest['lng'], prevLat, prevLng);
      prevLat = dest['lat'];
      prevLng = dest['lng'];
      chldrn.add(
        Row(children: [
          Expanded(child: textMy(dest['address'], s: 15)),
          txt2(dist)
        ]),
      );
    }
    return Container(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: chldrn,
      ),
    );
  }

  String _distance(double lat, double lng, double lat2, double lng2) {
    var ret = '';
    if (zctr.lastLat != 0.0) {
      var dist = Misc.distance(lat, lng, lat2, lng2);
      if (dist < 0.1) {
        ret = 'рядом';
      } else {
        ret = num.parse(dist.toStringAsFixed(2)).toString() + ' км';
      }
    }
    return ret;
  }

  Widget _totalPrice() {
    var chldrn = <Widget>[
      Row(children: [
        Expanded(
          child: Text(zkz!.ctgFullTitle),
        ),
        Text('${zkz!.ctgPrice} сом/час'),
      ]),
    ];
    if (zkz!.loaders != '0') {
      chldrn.add(const SizedBox(height: 10));
      chldrn.add(Row(children: [
        Expanded(
          child: Text('Грузчики(${zkz!.loaders})'),
        ),
        Text('${zkz!.loadersPrice} сом/час'),
      ]));
    }
    chldrn.add(const SizedBox(height: 12));
    chldrn.add(
      Row(children: [
        Expanded(
          child: txtEm('Итого'),
        ),
        txtEm('${zkz!.finalPrice} сом/час'),
      ]),
    );
    if (zkz!.duration != null) {
      chldrn.add(const SizedBox(height: 5));
      chldrn.add(
        Row(children: [
          Expanded(
            child: txtEm('Время'),
          ),
          txtEm(zkz!.durStr),
        ]),
      );
      chldrn.add(const SizedBox(height: 10));

      chldrn.add(
        Row(children: [
          Expanded(
            child: txtEm('Сумма'),
          ),
          txtEm('${zkz!.sum} сом'),
        ]),
      );
    }
    return Padding(
      padding: pad,
      child: Column(children: chldrn),
    );
  }

  Widget _acceptBtn() {
    if (zkz!.statusId != 1) {
      return const SizedBox();
    }
    return Container(
      child: MyWid.txtBtn('Принять', () => zctr.accept(zkz!), shad: true),
    );
    /* return Obx(() {
    }); */
  }
}
