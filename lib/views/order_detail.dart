import 'package:flutter/material.dart';
//import 'package:hive/hive.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:mover/helpers/alerts.dart';
import 'package:mover/models/zakaz_model.dart';
import 'package:mover/views/order_status.dart';
import '/helpers/misc.dart';
import '/controllers/zakaz_controller.dart';
import '/helpers/styles.dart';
import '/widgets/map.dart';
import '/widgets/my_widgets.dart';
import '../helpers/api_req.dart';

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
    //initMap();
    checkStatus();
  }

  void checkStatus() async {
    var freshStatus = await getStatus(widget.zkz.id);
    if (freshStatus != widget.zkz.statusId) {
      setState(() {
        widget.zkz.statusId = freshStatus;
        zctr.statusMap[widget.zkz.id] = freshStatus;
      });
    }
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
        //child: mymap.gmapX(),
        child: const SizedBox(),
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

  Widget status() {
    if (widget.zkz.statusId != 1) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          txt2('Статус:'),
          const SizedBox(width: 16),
          Text(Zakaz.statusStr(widget.zkz.statusId)),
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
    var chldrn = <Widget>[
      Row(children: [
        Expanded(
          child: Text(widget.zkz.ctgFullTitle),
        ),
        Text('${widget.zkz.ctgPrice} сом/час'),
      ]),
    ];
    if (widget.zkz.loaders != '0') {
      chldrn.add(const SizedBox(height: 10));
      chldrn.add(Row(children: [
        Expanded(
          child: Text('Грузчики(${widget.zkz.loaders})'),
        ),
        Text('${widget.zkz.loadersPrice} сом/час'),
      ]));
    }
    chldrn.add(const SizedBox(height: 12));
    chldrn.add(
      Row(children: [
        Expanded(
          child: txtEm('Итого'),
        ),
        txtEm('${widget.zkz.finalPrice} сом/час'),
      ]),
    );
    if (widget.zkz.duration != null) {
      chldrn.add(const SizedBox(height: 5));
      chldrn.add(
        Row(children: [
          Expanded(
            child: txtEm('Время'),
          ),
          txtEm(widget.zkz.durStr),
        ]),
      );
      chldrn.add(const SizedBox(height: 10));

      chldrn.add(
        Row(children: [
          Expanded(
            child: txtEm('Сумма'),
          ),
          txtEm('${widget.zkz.sum} сом'),
        ]),
      );
    }
    return Padding(
      padding: pad,
      child: Column(children: chldrn),
    );
  }

  Widget _acceptBtn() {
    if (widget.zkz.statusId != 1) {
      return const SizedBox();
    }
    return Container(
      child: MyWid.txtBtn('Принять', () async {
        if (zctr.prof == null) {
          errorAlert('Заполните профиль');
        } else {
          var res = await postAction('accept', {
            'id': widget.zkz.id.toString(),
            'zctg_id': widget.zkz.ctgId.toString()
          });
          if (res == 0) {
            errorAlert('Произошла ошибка');
          } else {
            widget.zkz.statusId = res;
            zctr.statusMap[widget.zkz.id] = res;
            await Get.off(OrderStatus(widget.zkz));
          }
        }
      }, shad: true),
    );
    /* return Obx(() {
    }); */
  }
}
