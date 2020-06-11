/*
 * @author lsy
 * @date   2020/5/8
 **/
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NativeToast {
  static int lastTime;

  static void showNativeToast(String text) {
    showNativeToastWithTime(text, false);
  }

  static void showNativeToastNotFast(String text) {
    if (lastTime == null ||
        DateTime.now().millisecondsSinceEpoch - lastTime > 2000) {
      showNativeToastWithTime(text, false);
    }
    lastTime = DateTime.now().millisecondsSinceEpoch;
  }

  static void showNativeToastWithTime(String text, bool long) {
    if (text == null) {
      text = "null";
    }
    Fluttertoast.showToast(
        msg: text,
        toastLength: long ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}
