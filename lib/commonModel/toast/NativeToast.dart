/*
 * @author lsy
 * @date   2020/5/8
 **/
import 'package:fluttertoast/fluttertoast.dart';

class NativeToast {
  static void showNativeToast(String text) {
    showNativeToastWithTime(text, false);
  }

  static void showNativeToastWithTime(String text, bool long) {
    Fluttertoast.showToast(
        msg: "This is Center Short Toast",
        toastLength: long ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);
  }
}
