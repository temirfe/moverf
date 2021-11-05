import 'package:flutter/material.dart';

class MapPickerController {
  Function mapMoving = () {};
  Function mapFinishedMoving = () {};
}

class MapPicker extends StatefulWidget {
  final Widget? child;
  final Widget? iconWidget;
  final bool? showDot;
  final MapPickerController? mapPickerController;
  final double? offsetLeft;
  final double? offsetTop;

  MapPicker({
    @required this.mapPickerController,
    @required this.iconWidget,
    this.showDot = true,
    @required this.child,
    @required this.offsetLeft,
    @required this.offsetTop,
  });

  @override
  _MapPickerState createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    if (widget.mapPickerController != null) {
      widget.mapPickerController?.mapMoving = mapMoving;
      widget.mapPickerController?.mapFinishedMoving = mapFinishedMoving;
    }
  }

  void mapMoving() {
    if (animationController != null && !animationController!.isCompleted ||
        !animationController!.isAnimating) {
      animationController!.forward();
    }
  }

  void mapFinishedMoving() {
    animationController?.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child!,
        Container(),
        AnimatedBuilder(
            animation: animationController!,
            builder: (context, snapshot) {
              return Positioned(
                top: widget.offsetTop,
                left: widget.offsetLeft,
                child: _pin(),
              );
            }),
      ],
    );
  }

  Widget _pinDot() {
    return Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
          color: Colors.black87, borderRadius: BorderRadius.circular(3)),
    );
  }

  Widget _pin() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.translate(
          offset: Offset(0, -10 * animationController!.value),
          child: widget.iconWidget,
        ),
        if (widget.showDot!) _pinDot()
      ],
    );
  }
}
