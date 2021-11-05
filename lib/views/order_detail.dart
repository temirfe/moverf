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

class OrderDetail extends StatefulWidget {
  const OrderDetail(this.zkz, {Key? key}) : super(key: key);
  final Zakaz zkz;

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final ZakazController zctr = Get.find<ZakazController>();
  final MyMap mymap = MyMap();
  final EdgeInsets pad =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  @override
  void initState() {
    super.initState();
    initMap();
  }

  void initMap() {
    zctr.pointsMap.clear();
    zctr.pointsMap[0] = {
      'title': widget.zkz.address,
      'lat': widget.zkz.lat,
      'lng': widget.zkz.lng
    };
    for (Map dest in widget.zkz.destinations) {
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
      appBar: AppBar(title: Text(widget.zkz.longTitle), centerTitle: true),
      backgroundColor: Colors.white,
      body: myBody(),
      bottomSheet: _acceptBtn(),
    );
  }

  Widget myBody() {
    return Column(children: [
      SizedBox(
        height: Get.height / 4,
        child: mymap.gmapX(),
      ),
      Expanded(
          child: ListView(
        children: bodyList(),
      ))
    ]);
  }

  List<Widget> bodyList() {
    var list = <Widget>[
      myTile('Когда', widget.zkz.startDateLong),
      const Divider(height: 8),
      myTile('Откуда', widget.zkz.address, tale: widget.zkz.distance),
      const Divider(height: 8),
      dest(),
      const Divider(height: 8),
      _totalPrice()
    ];

    return list;
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
    var prevLat = widget.zkz.lat;
    var prevLng = widget.zkz.lng;
    for (Map dest in widget.zkz.destinations) {
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
    var finalPrice = widget.zkz.ctgPrice;
    var chldrn = <Widget>[
      Row(children: [
        Expanded(
          child: Text(widget.zkz.ctgFullTitle),
        ),
        Text('${widget.zkz.ctgPrice} сом/час'),
      ]),
    ];
    if (widget.zkz.loaders != '0') {
      var lodersPrice = int.parse(widget.zkz.loaders) * zctr.loaderPrice;
      finalPrice += lodersPrice;
      chldrn.add(const SizedBox(height: 10));
      chldrn.add(Row(children: [
        Expanded(
          child: Text('Грузчики(${widget.zkz.loaders})'),
        ),
        Text('$lodersPrice сом/час'),
      ]));
    }
    chldrn.add(const SizedBox(height: 12));
    chldrn.add(Row(children: [
      Expanded(
        child: txtEm('Итого'),
      ),
      txtEm('$finalPrice сом/час'),
    ]));
    return Padding(
      padding: pad,
      child: Column(children: chldrn),
    );
  }

  Widget _acceptBtn() {
    return Obx(() {
      return Container(
        child: MyWid.txtBtn('Принять', () async {
          var res = await zctr
              .acceptOrder({'id': widget.zkz.id, 'zctg_id': widget.zkz.ctgId});
        }, shad: true),
      );
    });
  }
}