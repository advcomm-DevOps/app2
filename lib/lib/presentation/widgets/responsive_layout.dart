// // lib/presentation/widgets/responsive_widget.dart
// import 'package:flutter/material.dart';

// class Responsive extends StatelessWidget {
//   final Widget mobile;
//   final Widget? tablet;
//   final Widget desktop;

//   const Responsive({
//     Key? key,
//     required this.mobile,
//     this.tablet,
//     required this.desktop,
//   }) : super(key: key);

//   static bool isMobile(BuildContext context) =>
//       MediaQuery.of(context).size.width < 576;

//   static bool isTablet(BuildContext context) =>
//       MediaQuery.of(context).size.width >= 576 &&
//       MediaQuery.of(context).size.width <= 992;

//   static bool isDesktop(BuildContext context) =>
//       MediaQuery.of(context).size.width > 992;

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;
//     if (size.width > 992) {
//       return desktop;
//     } else if (size.width >= 576 && tablet != null) {
//       return tablet!;
//     } else {
//       return mobile;
//     }
//   }
// }

// import 'package:flutter/material.dart';

// class ResponsiveLayout extends StatelessWidget {
//   final Widget channelColumn;
//   final Widget docColumn;
//   final Widget workareaColumn;

//   const ResponsiveLayout({
//     super.key,
//     required this.channelColumn,
//     required this.docColumn,
//     required this.workareaColumn,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         // Channel Column (Left)
//         channelColumn,
//         // Vertical divider
//         const VerticalDivider(width: 1, thickness: 1),
//         // Doc Column (Middle)
//         Expanded(
//           flex: 1, // 40% of remaining space
//           child: docColumn,
//         ),
//         // Vertical divider
//         const VerticalDivider(width: 1, thickness: 1),
//         // Workarea Column (Right)
//         Expanded(
//           flex: 4, // 60% of remaining space
//           child: workareaColumn,
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget channelColumn;
  final Widget docColumn;
  final Widget workareaColumn;

  const ResponsiveLayout({
    super.key,
    required this.channelColumn,
    required this.docColumn,
    required this.workareaColumn,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 900) {
      // Mobile layout: show only channelColumn and docColumn
      return Row(
        children: [
          channelColumn,
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(flex: 1, child: docColumn),
        ],
      );
    }

    // Desktop layout: show all three columns
    return Row(
      children: [
        channelColumn,
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          flex: 1, // Doc column
          child: docColumn,
        ),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(
          flex: 4, // Workarea column
          child: workareaColumn,
        ),
      ],
    );
  }
}
