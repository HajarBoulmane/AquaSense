// lib/utils/responsive.dart
// ─────────────────────────────────────────────────────────
// Import this in every screen. Gives you breakpoints,
// padding, column counts, and a PageWrapper widget.
// ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class R {
  static double w(BuildContext ctx) => MediaQuery.of(ctx).size.width;

  static bool isMobile(BuildContext ctx)  => w(ctx) < 650;
  static bool isTablet(BuildContext ctx)  => w(ctx) >= 650  && w(ctx) < 1100;
  static bool isDesktop(BuildContext ctx) => w(ctx) >= 1100;
  static bool isWide(BuildContext ctx)    => w(ctx) >= 1400;

  /// Horizontal padding for page content
  static double pad(BuildContext ctx) {
    final v = w(ctx);
    if (v >= 1400) return 56;
    if (v >= 1100) return 36;
    if (v >= 650)  return 24;
    return 16;
  }

  /// Max content width — prevents cards from stretching on 4K
  static double maxW(BuildContext ctx) {
    final v = w(ctx);
    if (v >= 1600) return 1440;
    if (v >= 1100) return 1100;
    return v;
  }

  /// Stat card columns
  static int statCols(BuildContext ctx) {
    final v = w(ctx);
    if (v >= 1100) return 4;
    if (v >= 650)  return 2;
    return 2;
  }

  /// General grid columns (for cards/wells/alerts)
  static int gridCols(BuildContext ctx) {
    final v = w(ctx);
    if (v >= 1200) return 3;
    if (v >= 750)  return 2;
    return 1;
  }

  /// Two-column layout (chart + list side-by-side) on desktop
  static bool useTwoCols(BuildContext ctx) => w(ctx) >= 900;

  /// Chart height — taller on big screens
  static double chartH(BuildContext ctx) {
    final v = w(ctx);
    if (v >= 1400) return 300;
    if (v >= 1100) return 240;
    return 180;
  }
}

// ─────────────────────────────────────────────────────────
// PageWrapper — wrap your page body with this.
// Centers and constrains content, adds correct padding.
// ─────────────────────────────────────────────────────────
class PageWrapper extends StatelessWidget {
  final Widget child;

  const PageWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final p    = R.pad(context);
    final maxW = R.maxW(context);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Padding(
            padding: EdgeInsets.fromLTRB(p, 24, p, 32),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ResponsiveGrid — use instead of GridView.count so columns
// auto-adjust to screen width.
// ─────────────────────────────────────────────────────────
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? columns;       // override auto column count
  final double spacing;
  final double childAspect; // width / height ratio per cell

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.columns,
    this.spacing = 12,
    this.childAspect = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    final cols = columns ?? R.statCols(context);
    return GridView.count(
      crossAxisCount: cols,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspect,
      children: children,
    );
  }
}