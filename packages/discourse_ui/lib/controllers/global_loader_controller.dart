import 'package:get/get.dart';

class DiscourseGlobalLoaderController extends GetxController {
  final RxInt _loadingCount = 0.obs;

  static DiscourseGlobalLoaderController get to => Get.find<DiscourseGlobalLoaderController>();

  void show() {
    _loadingCount.value++;
  }

  void hide() {
    if (_loadingCount.value > 0) {
      _loadingCount.value--;
    }
  }

  /// Force loader to be hidden (e.g. after login success so navigation is not blocked).
  void forceHide() {
    _loadingCount.value = 0;
  }

  bool get isLoading => _loadingCount.value > 0;
}
