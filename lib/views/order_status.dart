import 'package:flutter/material.dart';
//import 'package:hive/hive.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:mover/models/zakaz_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import '/helpers/misc.dart';
import '/controllers/zakaz_controller.dart';
import '/helpers/styles.dart';
import '/helpers/alerts.dart';
import '/widgets/map.dart';
import '/widgets/my_widgets.dart';
import '../helpers/api_req.dart';
import 'order_detail.dart';
import 'dart:async';

const kMarkerId = MarkerId('MarkerId1');

class OrderStatus extends StatefulWidget {
  const OrderStatus(this.zakazId, {Key? key}) : super(key: key);
  final int zakazId;

  @override
  State<OrderStatus> createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  final ZakazController zctr = Get.find<ZakazController>();
  final EdgeInsets pad =
      const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
  Zakaz? zkz;
  var iter = 0;
  Timer? perdir;

  @override
  void initState() {
    super.initState();
    cprint('orderStatus initState');
    zkz = zctr.zakazMap[widget.zakazId];
    zctr.mapPolylines.clear();
    //zctr.pointsMap.clear();
    //zctr.markers.clear();
    zctr.markersMap.clear();
    //initMap();
    //zctr.listenLocation();
    /* zctr.markersMap[kMarkerId] = const Marker(
      markerId: kMarkerId,
      position: LatLng(42.881377, 74.583476),
    );
 */
    if (zkz != null) {
      if (zkz!.statusId == Zakaz.statusInProgress && zctr.durTimer == null) {
        zctr.durationTimer(zkz!.start!);
      }
      if (zkz!.statusId == Zakaz.statusApproaching) {
        zctr.bgLocListen(zkz!.id, zkz!.userId);
      }
    }
  }

  void initMap() {
    zctr.pointsMap.clear();
    zctr.pointsMap[0] = {
      'title': 'Текущее положение',
      'lat': zctr.lastLat,
      'lng': zctr.lastLng
    };
    zctr.pointsMap[1] = {
      'title': zkz!.address,
      'lat': zkz!.lat,
      'lng': zkz!.lng
    };
    zctr.createMarkers(showFirst: false);
    zctr.createPolylines(color: purpleMain);
  }

  @override
  Widget build(BuildContext context) {
    cprint('orderStatus build');
    return Scaffold(
      //backgroundColor: Colors.yellow,
      body: Stack(
        children: [
          SizedBox(
            height: Get.height * 0.9,
            child: MyMap(),
            //child: const SizedBox(),
            //color: Colors.grey,
          ),
          DraggableScrollableSheet(
              initialChildSize: .3,
              minChildSize: .12,
              maxChildSize: .5,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return scrollViewContent(scrollController);
              })
        ],
      ),
    );
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
        title: Text(zkz!.longTitle),
        trailing: const Icon(Icons.arrow_right),
        onTap: () {
          Get.to(OrderDetail(zkz!.id));
        },
      ),
      const Divider(height: 8),
      statuses(),
      sum(),
      actionBtn(),
      const Divider(height: 8),
      contact(),
      cancelBtn()
    ];

    return list;
  }

  Widget statuses() {
    return Obx(() {
      var statId = zkz!.statusId;
      if (zctr.statusMap.containsKey(zkz!.id)) {
        statId = zctr.statusMap[zkz!.id]!;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          txt2('Статус:'),
          const SizedBox(width: 16),
          Text(Zakaz.statusStr(statId)),
          const SizedBox(width: 16),
          timer(),
          when()
        ]),
      );
    });
  }

  Widget sum() {
    return Obx(() {
      var statId = zkz!.statusId;
      if (zctr.statusMap.containsKey(zkz!.id)) {
        statId = zctr.statusMap[zkz!.id]!;
      }
      if (statId > Zakaz.statusInProgress && zkz!.sum != 0) {
        return Container(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: Row(children: [
            txt2('Сумма:'),
            const SizedBox(width: 16),
            Text('${zkz!.sum} сом')
          ]),
        );
      }
      return const SizedBox();
    });
  }

  Widget contact() {
    return Obx(() {
      var statId = zkz!.statusId;
      if (zctr.statusMap.containsKey(zkz!.id)) {
        statId = zctr.statusMap[zkz!.id]!;
      }
      if (statId > Zakaz.statusInProgress) {
        return const SizedBox();
      }
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
    });
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

  Widget actionBtn() {
    return Obx(() {
      Widget ret = const SizedBox();

      var statId = zkz!.statusId;
      if (zctr.statusMap.containsKey(zkz!.id)) {
        statId = zctr.statusMap[zkz!.id]!;
      }

      switch (statId) {
        case Zakaz.statusAccepted:
          {
            ret = approachBtn();
          }
          break;
        case Zakaz.statusApproaching:
          {
            ret = startBtn();
          }
          break;
        case Zakaz.statusInProgress:
          {
            ret = doneBtn();
          }
          break;
      }
      return ret;
    });
  }

  Widget approachBtn() {
    return Obx(() {
      Widget contnt = const Text('Выезжаю');
      Function onPresd = () {
        zctr.approach(zkz!);
      };

      if (zctr.isLoadingMap.containsKey('approach') &&
          zctr.isLoadingMap['approach']!) {
        contnt = MyWid.loading();
        onPresd = () {};
      }
      return MyWid.txtBtn(contnt, onPresd, safearea: false);
    });
  }

  Widget startBtn() {
    return Obx(() {
      Widget contnt = const Text('Начать отчёт времени');
      Function onPresd = () {
        zctr.start(zkz!);
      };

      if (zctr.isLoadingMap.containsKey('start') &&
          zctr.isLoadingMap['start']!) {
        contnt = MyWid.loading();
        onPresd = () {};
      }
      return MyWid.txtBtn(contnt, onPresd, safearea: false);
    });
  }

  Widget doneBtn() {
    return Obx(() {
      Widget contnt = const Text('Завершить');
      Function onPresd = () {
        zctr.finish(zkz!);
      };

      if (zctr.isLoadingMap.containsKey('finish') &&
          zctr.isLoadingMap['finish']!) {
        contnt = MyWid.loading();
        onPresd = () {};
      }
      return MyWid.txtBtn(contnt, onPresd, safearea: false);
    });
  }

  Widget cancelBtn() {
    return Obx(() {
      var statId = zkz!.statusId;
      if (zctr.statusMap.containsKey(zkz!.id)) {
        statId = zctr.statusMap[zkz!.id]!;
      }
      if (statId > Zakaz.statusApproaching) {
        return const SizedBox();
      }
      return TextButton(
        child: const Text('Отменить заказ',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.grey)),
        onPressed: () {
          zctr.cancel(zkz!);
        },
      );
    });
  }

  Widget timer() {
    if (zkz!.statusId != Zakaz.statusInProgress) {
      return const SizedBox();
    }
    var duration = zctr.durTimerValue.value;
    var sec = (duration % 60).toString().padLeft(2, '0');
    var minute = '00';
    if (duration >= 60) {
      minute = ((duration % 3600) / 60).floor().toString().padLeft(2, '0');
    }
    var hour = '00';
    if (duration >= 3600) {
      hour = (duration / 3600).floor().toString().padLeft(2, '0');
    }

    return Text('$hour:$minute:$sec');
  }

  Widget when() {
    if (zkz!.statusId != Zakaz.statusAccepted) {
      return const SizedBox();
    }
    return Text('Начать ${zkz!.startDate}');
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
