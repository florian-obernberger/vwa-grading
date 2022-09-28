import 'package:flutter/material.dart';
import 'package:vwa_grading/destinations/destinations_mixin.dart';

abstract class PageSliderDestination extends StatelessWidget
    with PageSliderDestinationMixin {
  const PageSliderDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return buildBrowserScreen(context);
        } else if (constraints.maxWidth >= 500) {
          return buildTabletScreen(context);
        } else {
          return buildMobileScreen(context);
        }
      },
    );
  }

  /// Screen size >= 900px
  Widget buildBrowserScreen(BuildContext context);

  /// Screen size >= 500px < 900px
  Widget buildTabletScreen(BuildContext context);

  /// Screen size < 500px
  Widget buildMobileScreen(BuildContext context);
}
