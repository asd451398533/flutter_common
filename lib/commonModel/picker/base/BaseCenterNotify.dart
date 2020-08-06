/*
 * @author lsy
 * @date   2020/8/6
 **/
import 'package:flutter/cupertino.dart';
import 'package:flutter_common/commonModel/picker/base/BaseCenterPicker.dart';

class BaseCenterNotify extends ChangeNotifier {
  ICenterPicker iCenterPicker;

  void showNextPicker(ICenterPicker iCenterPicker) {
    this.iCenterPicker = iCenterPicker;
    notifyListeners();
  }

  void dismiss() {
    this.iCenterPicker = null;
    notifyListeners();
  }
}
