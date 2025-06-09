import 'package:flutter/material.dart';
import 'package:flutterproject/features/screens/User_info/user_info.dart' as userInfo;
import 'package:flutterproject/features/screens/User_info/user_info.dart';
import 'package:flutterproject/features/screens/home/home.dart' as home;
// import 'package:flutterproject/features/screens/statistics/statistics_screen_home.dart';
import 'package:flutterproject/utils/constants/colors.dart';
import 'package:flutterproject/utils/helpers/helper_functions.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = AppHelperFunctions.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar:  Obx(
        () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          backgroundColor: darkMode ? AppColors.black : Colors.white,
          indicatorColor: darkMode ? AppColors.white.withOpacity(0.1) : AppColors.black.withOpacity(0.1),

          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Statistics'),
          ],
        ),
      ),
      body: Obx( () => controller.screens[controller.selectedIndex.value]),
    );
  }
}




class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [ const home.HomeScreen(), AccountPage()];
}