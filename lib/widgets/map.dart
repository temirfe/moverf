import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/views/order_detail.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//import 'package:geocoding/geocoding.dart';
//import 'package:gmf/helpers/styles.dart';
//import 'package:gmf/helpers/alerts.dart';
import '/helpers/misc.dart';
import '/controllers/zakaz_controller.dart';
//import '/widgets/myWidgets.dart';
import '/widgets/mapPin.dart';

class MyMap {
  final ZakazController zctr = Get.find<ZakazController>();
  MapPickerController mpc = MapPickerController();
  LatLng? movedTo; //registers map's last stoped coords for locToAddr()

  final Map<MarkerId, Marker> markersMap = <MarkerId, Marker>{};
  final Set<Marker> markers = {};
  late final PolylinePoints polylinePoints;
  final List<LatLng> polylineCoordinates = [];

  Widget gmapX() {
    return Obx(() {
      cprint('gmapGet build gmap');

      var pllne = Set<Polyline>.of(zctr.mapPolylines.values);
      return gmap(pllne);
    });
  }

  GoogleMap gmap(Set<Polyline> pllne) {
    //cprint('center ${zctr.camPos!.target.latitude}');
    cprint('build gmap');
    /* Future.delayed(const Duration(milliseconds: 1500), () {
      cprint('delayed run checkCameraLocation');
      zctr.checkCameraLocation();
    }); */

    var mrkrs = zctr.markers;
    //var pllne = Set<Polyline>.of(zctr.mapPolylines.values);

    return GoogleMap(
      initialCameraPosition: zctr.camPos,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (GoogleMapController c) {
        cprint('onMapCreated');
        if (!zctr.mapCmpl.isCompleted) {
          zctr.mapCmpl.complete(c);
        }
        zctr.gmctr = c;
        zctr.checkCameraLocation();
      },
      markers: mrkrs,
      polylines: pllne,
    );
  }
}
