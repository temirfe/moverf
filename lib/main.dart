import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
//import '/helpers/misc.dart';
import 'controllers/zakaz_controller.dart';
import '/helpers/styles.dart';
import 'views/order_list.dart';
import 'views/socket_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('sharedPref');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //var iniPage = '/list';
    //String iniPage = '/detail';
    var iniPage = '/socket';
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
            //Get.put(ZakazController()),
            //Get.put(MapController()),
            //Get.put(MessageController()),
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
      page: () => OrderList(),
      //transition: Transition.rightToLeft
    ),
    GetPage(
      name: '/socket',
      page: () => const SocketTest(title: 'yoba'),
    ),
    /*GetPage(
      name: '/login',
      page: () => LoginView(),
    ),
    GetPage(
      name: '/filter',
      page: () => FilterView(),
    ), */
  ];
}
