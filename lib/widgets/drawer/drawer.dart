import 'package:flutter/material.dart';
//import 'package:get/get.dart';
import '/helpers/misc.dart';

Widget myDrawer(BuildContext context) {
  return Drawer(
    child: Container(
      color: purpleMain,
      child: ListView(
        padding: EdgeInsets.zero,
        children: _drawerList(context),
      ),
    ),
  );
}

List<Widget> _drawerList(BuildContext context) {
  List<Widget> list = [
    _buildHeader(context),
    _createDrawerItem(
        icon: Icons.person_outlined,
        text: 'Персональные данные',
        onTap: () async {
          //await Get.offAll(() => PersonalDataScreen());
        }),
    _createDrawerItem(
        icon: Icons.history_outlined,
        text: 'Мои заказы',
        onTap: () async {
          //await Get.to(DetailPage(zctr.));
        }),
    _createDrawerItem(
        icon: Icons.credit_card_outlined,
        text: 'Способы оплаты',
        onTap: () async {
          //await Get.offAll(() => SposobiOplatyScreen());
        }),
    _createDrawerItem(icon: Icons.info_outlined, text: 'Помощь'),
    const SizedBox(height: 30),
    _createDrawerItem(icon: Icons.logout_outlined, text: 'Выход'),
  ];
  return list;
}

Widget _buildHeader(BuildContext context) {
  String name = prefBox.get('name', defaultValue: '');
  String phone = prefBox.get('phone', defaultValue: '555');

  return DrawerHeader(
    margin: EdgeInsets.only(bottom: 0.0),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        child: Column(
          children: [
            //h6textWhite(context, name),
            textMy(name, c: Colors.white, s: 16),
            SizedBox(height: 10),
            _avatar(),
            SizedBox(height: 10),
            textMy(phone, c: Colors.white, s: 16)
          ],
        ),
        onTap: () {
          cprint('drawerHeader user tapped');
        },
      ),
    ),
  );
}

Widget _avatar() {
  Widget circleAvatar;
  String imgUrl = prefBox.get('image_url', defaultValue: '');

  if (imgUrl != '') {
    String avatarUrl = '${Endpoints.urlApi}/s_$imgUrl';
    circleAvatar = CircleAvatar(
      backgroundImage: NetworkImage(avatarUrl),
      radius: 30.0,
    );
  } else {
    circleAvatar = Icon(
      Icons.account_circle_outlined,
      size: 60,
      color: Colors.white,
    );
  }

  return circleAvatar;
}

Widget _createDrawerItem(
    {required IconData icon, required String text, GestureTapCallback? onTap}) {
  return Material(
    child: new Ink(
      color: purpleMain,
      child: ListTile(
        dense: true,
        title: Row(
          children: <Widget>[
            Icon(
              icon,
              color: Colors.white,
              size: 25,
            ),
            Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: Text(
                text,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            )
          ],
        ),
        onTap: onTap,
      ),
    ),
  );
}
