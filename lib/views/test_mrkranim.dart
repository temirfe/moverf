import 'dart:async';
import 'package:get/get.dart';
import '/controllers/zakaz_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import '/helpers/misc.dart';

const kStartPosition = LatLng(42.881377, 74.583476);
const kSantoDomingo = CameraPosition(target: kStartPosition, zoom: 15);
const kMarkerId = MarkerId('MarkerId1');
const kDuration = Duration(seconds: 5);
const kLocations = [
  kStartPosition,
  LatLng(42.881951, 74.583583),
  LatLng(42.881910, 74.584229),
  LatLng(42.881859, 74.585305),
  LatLng(42.881808, 74.586748),
  LatLng(42.881745, 74.587789),
  LatLng(42.881686, 74.588883),
  LatLng(42.881631, 74.590364),
  LatLng(42.881545, 74.592161),
  LatLng(42.881431, 74.593835),
  LatLng(42.881404, 74.594866),
  LatLng(42.881624, 74.595129),
];

class SimpleMarkerAnimationExample extends StatefulWidget {
  @override
  SimpleMarkerAnimationExampleState createState() =>
      SimpleMarkerAnimationExampleState();
}

class SimpleMarkerAnimationExampleState
    extends State<SimpleMarkerAnimationExample> {
  final markers = <MarkerId, Marker>{};
  final controller = Completer<GoogleMapController>();
  final stream = Stream.periodic(kDuration, (count) => kLocations[count])
      .take(kLocations.length);
  final ZakazController zctr = Get.find<ZakazController>();
  final mapCmpl = Completer<GoogleMapController>();

  @override
  void initState() {
    stream.forEach((value) => newLocationUpdate(value));
    /* const marker = RippleMarker(
      markerId: kMarkerId,
      position: kStartPosition,
      ripple: true,
    );
    zctr.markersMap[kMarkerId] = marker;
    zctr.markers.assignAll(Set<Marker>.of(zctr.markersMap.values)); */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    cprint('build');
    // var mapid = controller.future.then<int>((value) => value.mapId);
    //var mapid = zctr.mapCmpl.future.then<int>((value) => value.mapId);
    return GetBuilder<ZakazController>(builder: (zctr) {
      cprint('gbuild');
      return Animarker(
        mapId: mapCmpl.future
            .then<int>((value) => value.mapId), //Grab Google Map Id
        markers: zctr.markersMap.values.toSet(),
        duration: kDuration,
        //markers: markers.values.toSet(),
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: kSantoDomingo,
          onMapCreated: (gController) {
            //controller.complete(gController);
            mapCmpl.complete(gController);
            zctr.gmctr = gController;
            zctr.checkCameraLocation();
          }, //Complete the future GoogleMapController
        ),
      );
    });
  }

  void newLocationUpdate(LatLng latLng) {
    var marker = Marker(
      markerId: kMarkerId,
      position: latLng,
    );
    zctr.markersMap[kMarkerId] = marker;
    zctr.update();
  }

  void newLocationUpdate2(LatLng latLng) {
    var marker = RippleMarker(
      markerId: kMarkerId,
      position: latLng,
      ripple: true,
    );
    setState(() => markers[kMarkerId] = marker);
  }
}
