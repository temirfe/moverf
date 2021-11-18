import 'package:flutter/material.dart';
//import 'package:hive/hive.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import 'package:mover/models/zakaz_model.dart';
import 'package:mover/widgets/drawer/drawer.dart';
import '/helpers/misc.dart';
import '/controllers/zakaz_controller.dart';
//import '/helpers/styles.dart';
import 'order_detail.dart';
import 'order_status.dart';

class OrderList extends StatefulWidget {
  const OrderList({Key? key}) : super(key: key);

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  final ZakazController zctr = Get.find<ZakazController>();

  final scrollMap = {'max': 0.0};

  final ctg = 'zakaz';

  @override
  void initState() {
    super.initState();
    zctr.populateList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Открытые заказы'), centerTitle: true),
      backgroundColor: Colors.grey[200],
      drawer: myDrawer(context, zctr),
      body: myBody(),
    );
  }

  Widget myBody() {
    return Obx(() {
      if (zctr.orderList.isNotEmpty) {
        return NotificationListener(
          onNotification: _onScrollNotification,
          child: RefreshIndicator(
            onRefresh: () async {
              zctr.xCurrentPage[ctg] = 0;
              zctr.orderList.value = [];
              zctr.requestOrders();
            },
            child: Scrollbar(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                children: orderList(zctr.orderList),
              ),
            ),
          ),
        );
      } else if (zctr.olIsEmpty.value) {
        return const Center(child: Text('Нет заказов'));
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    });
  }

  List<Widget> orderList(List orderList) {
    var list = <Widget>[];
    for (var order in orderList) {
      list.add(tile(order));
    }
    return list;
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      final after = notification.metrics.extentAfter;
      final max = notification.metrics.maxScrollExtent;
      if (after < 200) {
        if (scrollMap['max'] != max) {
          if (zctr.xPageCount[ctg] != 0 &&
              zctr.xCurrentPage[ctg]! < zctr.xPageCount[ctg]!) {
            zctr.requestOrders();
          }
          scrollMap['max'] = max;
        }
      }
    }
    return false;
  }

  Widget tile(Map<String, dynamic> order) {
    var zakaz = Zakaz.fromJson(order);

    return InkWell(
      onTap: () {
        Get.to(OrderDetail(zakaz));
        //Get.to(OrderStatus(zakaz));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          txtEm(zakaz.longTitle),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Text(zakaz.address)),
              Text(zakaz.distance)
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Container()),
              txt2(zakaz.startDate, s: 12)
            ],
          ),
        ]),
      ),
    );
  }
}
