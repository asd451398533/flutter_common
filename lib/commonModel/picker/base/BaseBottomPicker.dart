/*
 * @author lsy
 * @date   2020-01-03
 **/

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/commonModel/live/LiveData.dart';

import 'DialogRouter.dart';

class BaseBottomPicker extends StatefulWidget {
  IBottomPicker picker;
  bool cancelOutSide = true;
  double backMaxAlp = 255 / 2 - 10;

  setPicker(IBottomPicker picker) {
    this.picker = picker;
  }

  setBackMaxAlp(double max) {
    this.backMaxAlp = max;
  }

  setCancelOutside(bool cancel) {
    this.cancelOutSide = cancel;
  }

  Future show(BuildContext content) {
    return Navigator.push(content, DialogRouter(this));
  }

  @override
  State<StatefulWidget> createState() => BaseBottomPickerState();
}

class BaseBottomPickerState extends State<BaseBottomPicker>
    with SingleTickerProviderStateMixin {
  Animation<Offset> animation;
  AnimationController controller;
  LiveData<Color> backLive = LiveData();
  bool isDissmissing = false;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    controller
      ..addStatusListener((state) {
        if (state == AnimationStatus.dismissed && controller.value == 0) {
          Navigator.pop(context);
        }
      });
    animation =
        new Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(controller)
          ..addListener(() {
            backAnim(1 - animation.value.dy.abs());
          });
    controller.forward();
    widget.picker.initState(() {
      if (isDissmissing) {
        return;
      }
      isDissmissing = true;
      controller.reverse();
    });
  }

  void backAnim(double dy) {
    backLive
        .notifyView(Color.fromARGB((dy * widget.backMaxAlp).floor(), 0, 0, 0));
  }

  @override
  void dispose() {
    controller.dispose();
    widget.picker.dispose();
    backLive.dispost();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Container(
          child: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (widget.cancelOutSide) {
                    controller.reverse();
                  }
                },
                child: StreamBuilder<Color>(
                  stream: backLive.stream,
                  initialData: Color.fromARGB(0, 0, 0, 0),
                  builder: (c, data) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: data.data,
                    );
                  },
                ),
              ),
              Positioned(
                  bottom: 0,
                  child: SlideTransition(
                    position: animation,
                    child: widget.picker.build(context),
                  ))
            ],
          ),
        ));
  }
}

abstract class IBottomPicker {
  void initState(VoidCallback dismissCall);

  Widget build(BuildContext context);

  void dispose();
}
