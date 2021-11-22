import 'package:flutter/material.dart';
//import 'package:hive/hive.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:mover/models/zakaz_model.dart';
import '/helpers/misc.dart';
import '/controllers/zakaz_controller.dart';
import '/helpers/styles.dart';
import '/helpers/alerts.dart';
import '/widgets/map.dart';
import '/widgets/my_widgets.dart';
import '../helpers/api_req.dart';

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
    //initMap();
    //zctr.listenLocation();
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
          //child: mymap.gmapX(),
          child: const SizedBox(),
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
        maxChildSize: .8,
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
      actionBtn(),
      const Divider(height: 8),
      contact(),
      cancelBtn()
    ];

    return list;
  }

  Widget statuses() {
    return Obx(() {
      var statId = widget.zkz.statusId;
      if (zctr.statusMap.containsKey(widget.zkz.id)) {
        statId = zctr.statusMap[widget.zkz.id]!;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          txt2('Статус:'),
          const SizedBox(width: 16),
          Text(Zakaz.statusStr(statId))
        ]),
      );
    });
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

  Widget actionBtn() {
    return Obx(() {
      Widget ret = const SizedBox();

      var statId = widget.zkz.statusId;
      if (zctr.statusMap.containsKey(widget.zkz.id)) {
        statId = zctr.statusMap[widget.zkz.id]!;
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
    void onPresd() async {
      //zctr.periodic();
      var res = await postAction('approach', {
        'id': widget.zkz.id.toString(),
        'zctg_id': widget.zkz.ctgId.toString()
      });
      if (res is int && res == 0) {
        //await Get.off(OrderStatus(widget.zkz));
      } else {
        errorAlert('Произошла ошибка');
      }
    }

    return MyWid.txtBtn(const Text('Выезжаю'), onPresd, safearea: false);
  }

  Widget startBtn() {
    return Obx(() {
      Widget contnt = const Text('Начать отчёт времени');
      Function onPresd = () async {
        //zctr.periodic();
        zctr.isLoadingMap['start'] = true;
        var res = await postAction('start', {
          'id': widget.zkz.id.toString(),
          'zctg_id': widget.zkz.ctgId.toString()
        });
        if (res is int && res == 0) {
          zctr.statusMap[widget.zkz.id] = Zakaz.statusInProgress;
          widget.zkz.ctgId = Zakaz.statusInProgress;
          widget.zkz.start = Misc.currentTs();
        } else {
          errorAlert('Произошла ошибка');
          zctr.isLoadingMap['start'] = false;
        }
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
      Function onPresd = () async {
        //zctr.periodic();
        zctr.isLoadingMap['finish'] = true;
        var res = await postAction('finish', {
          'id': widget.zkz.id.toString(),
          'zctg_id': widget.zkz.ctgId.toString()
        });
        if (res is int && res == 0) {
          zctr.statusMap[widget.zkz.id] = Zakaz.statusCompleted;
          widget.zkz.ctgId = Zakaz.statusCompleted;
          widget.zkz.finish = Misc.currentTs();
        } else {
          errorAlert('Произошла ошибка');
          zctr.isLoadingMap['finish'] = false;
        }
      };

      if (zctr.isLoadingMap.containsKey('finish') &&
          zctr.isLoadingMap['finish']!) {
        contnt = MyWid.loading();
        onPresd = () {};
      }
      return MyWid.txtBtn(contnt, onPresd, safearea: false);
    });
  }

  Widget doneBtn2() {
    void onPresd() async {
      var res = await postAction('finish', {
        'id': widget.zkz.id.toString(),
        'zctg_id': widget.zkz.ctgId.toString()
      });
      if (res is int && res == 0) {
        //await Get.off(OrderStatus(widget.zkz));
      } else {
        errorAlert('Произошла ошибка');
      }
    }

    return MyWid.txtBtn(const Text('Завершить'), onPresd, safearea: false);
  }

  Widget cancelBtn() {
    return TextButton(
      child: const Text('Отменить заказ',
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
      onPressed: () async {
        var res = await postAction('cancel', {
          'id': widget.zkz.id.toString(),
          'zctg_id': widget.zkz.ctgId.toString()
        });
        if (res is int && res == 0) {
          //await Get.off(OrderStatus(widget.zkz));
        } else {
          errorAlert('Произошла ошибка');
        }
      },
    );
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
