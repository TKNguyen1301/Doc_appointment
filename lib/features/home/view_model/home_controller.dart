import 'package:get/get.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final carousalCurrentIndex = 0.obs;
  final List<String> carousalImages = [
    'assets/images/carousal1.jpg',
    'assets/images/carousal2.jpg',
    'assets/images/carousal3.jpg',
  ];
  
  void updatePageIndicator(index) {
    carousalCurrentIndex.value = index;
  }
 }