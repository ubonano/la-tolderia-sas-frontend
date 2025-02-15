import 'package:get/get.dart';

class LayoutController extends GetxController {
  final RxBool _isDrawerCollapsed = false.obs;

  bool get isDrawerCollapsed => _isDrawerCollapsed.value;

  void toggleDrawer() {
    _isDrawerCollapsed.value = !_isDrawerCollapsed.value;
  }
}
