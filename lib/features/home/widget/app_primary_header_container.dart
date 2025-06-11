import 'package:flutter/widgets.dart';
import 'package:flutterproject/features/home/widget/app_circular_container.dart';
import 'package:flutterproject/features/home/widget/app_curved_edge_widget.dart';
import 'package:flutterproject/utils/constants/colors.dart';

class AppPrimaryHeaderContainer extends StatelessWidget {
  const AppPrimaryHeaderContainer({
    super.key, 
    required this.child,
    required this.height,
  });

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCurvedEdgeWidget(
      child: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.all(0),
        child: SizedBox(
          height: height, // doi o day
          child: Stack(
            children: [
              Positioned(top: -150, right: -250,child:  AppCircularContainer(backgroundColor: AppColors.textWhite.withOpacity(0.2))),
              Positioned(top: 100, right: -300,child:  AppCircularContainer(backgroundColor: AppColors.textWhite.withOpacity(0.2))),
              child,
            ],
          ),
        ),
      ),
    );
  }
}