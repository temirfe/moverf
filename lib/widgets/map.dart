import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/widgets/animarker.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';

//import 'package:geocoding/geocoding.dart';
//import 'package:gmf/helpers/styles.dart';
//import 'package:gmf/helpers/alerts.dart';
import '/helpers/misc.dart';
import '/controllers/zakaz_controller.dart';
//import '/widgets/myWidgets.dart';
import '/widgets/mapPin.dart';

class MyMap extends StatelessWidget {
  //final ZakazController zctr = Get.find<ZakazController>();
  final MapPickerController mpc = MapPickerController();
  final mapCmpl = Completer<GoogleMapController>();
  // LatLng? movedTo; //registers map's last stoped coords for locToAddr()

  MyMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    cprint('map build');
    return GetBuilder<ZakazController>(
      builder: (zctr) {
        cprint('map getbuild');
        return Animarker(
          mapId: mapCmpl.future.then<int>((value) => value.mapId),
          duration: const Duration(milliseconds: 6000),
          markers: zctr.markersMap.values.toSet(),
          child: GoogleMap(
            initialCameraPosition: zctr.camPos,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController c) {
              cprint('onMapCreated');
              mapCmpl.complete(c);
              zctr.gmctr = c;
              zctr.checkCameraLocation();
            },
            //markers: zctr.markers,
            polylines: Set<Polyline>.of(zctr.mapPolylines.values),
          ),
        );
      },
    );
  }
}
