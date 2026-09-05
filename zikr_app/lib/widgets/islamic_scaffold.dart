import 'dart:ui';
import 'package:flutter/material.dart';
import 'islamic_background.dart';

/// Общий каркас экрана: полупрозрачный размытый AppBar (liquid glass)
/// поверх мягкого градиентного фона с исламским геометрическим узором.
/// Используется всеми основными экранами приложения вместо голого Scaffold.
class IslamicScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget body;
  final Widget? floatingActionButton;

  const IslamicScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottom,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final toolbarExtra = bottom?.preferredSize.height ?? 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + toolbarExtra),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              title: Text(title),
              centerTitle: true,
              backgroundColor:
                  scheme.surface.withValues(alpha: isDark ? 0.45 : 0.55),
              elevation: 0,
              scrolledUnderElevation: 0,
              actions: actions,
              bottom: bottom,
            ),
          ),
        ),
      ),
      body: IslamicBackground(
        child: Padding(
          padding: EdgeInsets.only(top: kToolbarHeight + toolbarExtra),
          child: body,
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
