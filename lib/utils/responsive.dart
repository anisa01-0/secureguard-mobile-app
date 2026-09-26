import 'package:flutter/material.dart';

/// Layout helpers that keep SecureGuard readable on small phones, large
/// phones, tablets and the web preview used during the demonstration.
class Responsive {
  const Responsive._();

  static const double phoneMaxWidth = 600;
  static const double tabletMaxWidth = 1000;

  /// The widest a single column of content is allowed to grow. On a tablet or
  /// desktop window the content is centred instead of being stretched.
  static const double contentMaxWidth = 560;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < phoneMaxWidth;

  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return width >= phoneMaxWidth && width < tabletMaxWidth;
  }

  static bool isCompactHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height < 680;

  /// Horizontal page padding that grows slightly on wider screens.
  static double horizontalPadding(BuildContext context) =>
      isPhone(context) ? 20 : 28;

  /// Number of grid columns for quick actions / tips / services.
  static int gridColumns(BuildContext context, {int phone = 2}) {
    final double width = MediaQuery.sizeOf(context).width;
    if (width >= tabletMaxWidth) return phone + 2;
    if (width >= phoneMaxWidth) return phone + 1;
    return phone;
  }
}

/// Centres its child and caps the width on large screens.
///
/// Every scrollable screen wraps its body in this so the layout never looks
/// stretched when the project is demonstrated in a browser.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = Responsive.contentMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
