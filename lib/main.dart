import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:mover/views/serviceman.dart';
import 'package:mover/views/test_bg_loc.dart';
import '/helpers/misc.dart';
import 'controllers/zakaz_controller.dart';
import '/helpers/styles.dart';
import 'views/order_list.dart';
import 'views/my_order_list.dart';
import 'views/socket_test.dart';
import 'views/login_view.dart';
import 'views/test.dart';
import 'views/test_mrkranim.dart';

/* Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  cprint('Handling a background message: ${message.messageId}');
} */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Hive.initFlutter();
  await Hive.openBox('sharedPref');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    //var iniPage = '/test';
    var iniPage = '/list';
    //String iniPage = '/detail';
    //var iniPage = '/socket';
    if (prefBox.get('userId') == null) {
      iniPage = '/login';
    }
    return GetMaterialApp(
      title: 'Perevozchik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: purpleMain,
        appBarTheme: const AppBarTheme(
            backgroundColor: purpleMain,
            elevation: 0,
            titleTextStyle:
                TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        bottomSheetTheme:
            const BottomSheetThemeData(backgroundColor: Colors.transparent),
      ),
      getPages: Router.route,
      initialRoute: iniPage,
      initialBinding: BindingsBuilder(() => {
            Get.put(ZakazController()),
          }),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'),
        Locale('en', 'US'),
      ],
    );
  }
}

class Router {
  static final route = <GetPage>[
    GetPage(
      name: '/list',
      page: () => const OrderList(),
      //transition: Transition.rightToLeft
    ),
    GetPage(
      name: '/myorders',
      page: () => const MyOrderList(),
      //transition: Transition.rightToLeft
    ),
    GetPage(
      name: '/socket',
      page: () => const SocketTest(title: 'yoba'),
    ),
    GetPage(
      name: '/test',
      //page: () => Test(),
      //page: () => const BgLocTest(),
      page: () => SimpleMarkerAnimationExample(),
    ),
    GetPage(
      name: '/login',
      page: () => LoginView(),
    ),
    GetPage(
      name: '/serviceman',
      page: () => const ServicemanForm(),
    ),
    /* GetPage(
      name: '/filter',
      page: () => FilterView(),
    ), */
  ];
}
