/*
 * @author lsy
 * @date   2019-10-18
 **/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/commonModel/live/LiveData.dart';

import 'DialogRouter.dart';

class BaseCenterPicker extends StatefulWidget {
  ICenterPicker picker;
  bool cancelOutSide = true;
  double backMaxAlp = 255 / 2 - 10;
  bool interruptBackEvent = false;

  setBackMaxAlp(double max) {
    this.backMaxAlp = max;
  }

  setPicker(ICenterPicker picker) {
    this.picker = picker;
  }

  setCancelOutside(bool cancel) {
    this.cancelOutSide = cancel;
  }

  setInterruptBackEvent(bool set) {
    interruptBackEvent = set;
  }

  Future show(BuildContext content) {
    return Navigator.push(content, DialogRouter(this));
  }

  @override
  State<StatefulWidget> createState() => BaseCenterPickerState();
}

class BaseCenterPickerState extends State<BaseCenterPicker>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  VoidCallback dismissCall;
  LiveData<double> backLive = LiveData();
  bool isDismissing = false;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 260), vsync: this);
    controller
      ..addStatusListener((state) {
        if (state == AnimationStatus.dismissed && controller.value == 0) {
          Navigator.pop(context);
        }
      });
    animation = new Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        backAnim(animation.value.abs());
      });
    controller.forward();
    widget.picker.initState(() {
      if (isDismissing) {
        return;
      }
      isDismissing = true;
      controller.reverse();
    }, context);
  }

  void backAnim(double dy) {
    backLive.notifyView(dy);
  }

  @override
  void dispose() {
    controller.dispose();
    backLive.dispost();
    widget.picker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if (widget.cancelOutSide) {
                      controller.reverse();
                    }
                  },
                  child: StreamBuilder<double>(
                    stream: backLive.stream,
                    initialData: 0,
                    builder: (c, data) {
                      int alp = (data.data * widget.backMaxAlp).floor();
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Color.fromARGB(alp, 0, 0, 0),
                      );
                    },
                  ),
                ),
                Center(
                    child: StreamBuilder<double>(
                  stream: backLive.stream,
                  initialData: 0,
                  builder: (c, data) {
                    int alp = (data.data * 255).ceil();
                    return widget.picker.build(context, alp);
                  },
                ))
              ],
            ),
          )),
      onWillPop: () {
        if (!widget.interruptBackEvent) {
          if (isDismissing) {
            return;
          }
          isDismissing = true;
          controller.reverse();
        }
      },
    );
  }
}

abstract class ICenterPicker {
  void initState(VoidCallback dismissCall, BuildContext context);

  Widget build(BuildContext context, int alp);

  void dispose();
}
