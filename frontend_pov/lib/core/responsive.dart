import 'package:flutter/material.dart';

/// Helper responsive untuk kiosk yang harus jalan di tablet landscape,
/// HP portrait, dan desktop. Dipakai di semua screen agar tidak perlu
/// duplikasi if-else MediaQuery.
class Responsive {
  static bool isMobile(BuildContext c) => MediaQuery.of(c).size.width < 600;
  static bool isTablet(BuildContext c) =>
      MediaQuery.of(c).size.width >= 600 && MediaQuery.of(c).size.width < 1100;
  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width >= 1100;
  static bool isPortrait(BuildContext c) => MediaQuery.of(c).orientation == Orientation.portrait;

  /// Padding adaptif: HP 16, tablet 24, desktop 32
  static double padding(BuildContext c) {
    if (isMobile(c)) return 16;
    if (isTablet(c)) return 24;
    return 32;
  }

  /// Jumlah kolom grid frame: HP portrait 2, HP landscape 3, tablet 3, desktop 4
  static int frameColumns(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w < 380) return 2;
    if (w < 700) return 2;
    if (w < 900) return 3;
    return 4;
  }

  /// Kolom foto preview: HP 1-2, tablet 2, desktop 2-3
  static int photoColumns(BuildContext c) {
    if (isMobile(c)) return isPortrait(c) ? 2 : 3;
    return 2;
  }
}

/// Widget wrapper untuk batasi lebar konten di layar lebar (kiosk 4K)
class CenteredConstraint extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const CenteredConstraint({super.key, required this.child, this.maxWidth = 1200});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
