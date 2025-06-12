import 'package:flutter/widgets.dart';
import 'package:flutterproject/common/styles/widgets/custom_shapes/curved_edges/curved_edges.dart';

class AppCurvedEdgeWidget extends StatelessWidget {
  const AppCurvedEdgeWidget({
    super.key, this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: AppCustomCurvedEdges(),
      child: child,
    );
  }
}