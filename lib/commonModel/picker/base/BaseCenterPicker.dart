/*
 * @author lsy
 * @date   2019-10-18
 **/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_common/commonModel/live/LiveData.dart';
import 'package:flutter_common/commonModel/picker/base/BaseCenterNotify.dart';

import 'DialogRouter.dart';

class BaseCenterPicker extends StatefulWidget {
  ICenterPicker picker;
  bool cancelOutSide = true;
  double backMaxAlp = 255 / 2 - 10;
  bool interruptBackEvent = false;
  Function(AnimationStatus status) animListener;

  setBackMaxAlp(double max) {
    this.backMaxAlp = max;
  }

  setAnimStateListener(Function(AnimationStatus status) animListener) {
    this.animListener = animListener;
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
  LiveData<double> backLive = LiveData();
  bool isDismissing = false;
  Function(ICenterPicker iCenterPicker) showOtherPicker;
  BaseCenterNotify _baseCenterNotify = new BaseCenterNotify();

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(
        duration: const Duration(milliseconds: 260), vsync: this);
    controller
      ..addStatusListener((state) {
        if (widget.animListener != null) {
          widget.animListener(state);
        }
        if (state == AnimationStatus.dismissed && controller.value == 0) {
          if (_baseCenterNotify.iCenterPicker != null) {
            widget.picker.dispose();
            widget.picker = _baseCenterNotify.iCenterPicker;
            isDismissing = false;
            _baseCenterNotify.iCenterPicker
                .initState(_baseCenterNotify, context);
            controller.forward();
          } else {
            Navigator.pop(context);
          }
        }
      });
    animation = new Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        backAnim(animation.value.abs());
      });
    controller.forward();
    if (!_baseCenterNotify.hasListeners) {
      _baseCenterNotify.addListener(() {
        if (isDismissing) {
          return;
        }
        isDismissing = true;
        controller.reverse();
      });
    }
    widget.picker.initState(_baseCenterNotify, context);
  }

  void backAnim(double dy) {
    backLive.notifyView(dy);
  }

  @override
  void dispose() {
    controller.dispose();
    backLive.dispost();
    widget.picker.dispose();
    _baseCenterNotify.dispose();
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
                      _baseCenterNotify.iCenterPicker = null;
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
          _baseCenterNotify.iCenterPicker = null;
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
  void initState(BaseCenterNotify nextListener, BuildContext context);

  Widget build(BuildContext context, int alp);

  void dispose();
}
