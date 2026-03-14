import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom app bar widget for DBC.AI business management app
/// Implements clean, purposeful design with strategic white space
/// Supports multiple variants for different screen contexts
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text for the app bar
  final String? title;

  /// Title widget (takes precedence over title text)
  final Widget? titleWidget;

  /// Leading widget (typically back button or menu icon)
  final Widget? leading;

  /// Actions widgets (typically icons on the right side)
  final List<Widget>? actions;

  /// Whether to show back button automatically
  final bool automaticallyImplyLeading;

  /// Background color override
  final Color? backgroundColor;

  /// Foreground color override (affects text and icons)
  final Color? foregroundColor;

  /// Elevation of the app bar
  final double? elevation;

  /// Whether to center the title
  final bool centerTitle;

  /// Variant of the app bar
  final CustomAppBarVariant variant;

  /// Bottom widget (typically TabBar)
  final PreferredSizeWidget? bottom;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  /// Whether to show a gradient background
  final bool showGradient;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = false,
    this.variant = CustomAppBarVariant.standard,
    this.bottom,
    this.onBackPressed,
    this.showGradient = false,
  });

  @override
  Size get preferredSize {
    final double bottomHeight = bottom?.preferredSize.height ?? 0.0;
    switch (variant) {
      case CustomAppBarVariant.standard:
        return Size.fromHeight(56.0 + bottomHeight);
      case CustomAppBarVariant.large:
        return Size.fromHeight(112.0 + bottomHeight);
      case CustomAppBarVariant.minimal:
        return Size.fromHeight(48.0 + bottomHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomAppBarVariant.standard:
        return _buildStandardAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.large:
        return _buildLargeAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.minimal:
        return _buildMinimalAppBar(context, theme, colorScheme);
    }
  }

  /// Standard app bar with normal height
  Widget _buildStandardAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;

    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      backgroundColor: showGradient ? null : effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context, effectiveForegroundColor),
      title: _buildTitle(theme, effectiveForegroundColor),
      actions: _buildActions(context, effectiveForegroundColor),
      bottom: bottom,
      flexibleSpace: showGradient ? _buildGradientBackground() : null,
    );
  }

  /// Large app bar with extended height for prominent screens
  Widget _buildLargeAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;

    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
      ),
      backgroundColor: showGradient ? null : effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      pinned: true,
      expandedHeight: 112.0,
      leading: _buildLeading(context, effectiveForegroundColor),
      actions: _buildActions(context, effectiveForegroundColor),
      bottom: bottom,
      flexibleSpace: FlexibleSpaceBar(
        title: _buildTitle(theme, effectiveForegroundColor),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
        background: showGradient ? _buildGradientBackground() : null,
      ),
    );
  }

  /// Minimal app bar with reduced height
  Widget _buildMinimalAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final effectiveBackgroundColor = backgroundColor ?? colorScheme.surface;
    final effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;

    return PreferredSize(
      preferredSize: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: showGradient ? null : effectiveBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1.0,
            ),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 48.0,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                if (_buildLeading(context, effectiveForegroundColor) != null)
                  _buildLeading(context, effectiveForegroundColor)!,
                Expanded(
                  child: _buildTitle(theme, effectiveForegroundColor) ??
                      const SizedBox(),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build leading widget
  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) {
      return leading;
    }

    if (automaticallyImplyLeading && Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        color: foregroundColor,
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      );
    }

    return null;
  }

  /// Build title widget
  Widget? _buildTitle(ThemeData theme, Color foregroundColor) {
    if (titleWidget != null) {
      return titleWidget;
    }

    if (title != null) {
      return Text(
        title!,
        style: theme.textTheme.titleLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return null;
  }

  /// Build actions widgets
  List<Widget>? _buildActions(BuildContext context, Color foregroundColor) {
    if (actions == null) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return IconButton(
          icon: action.icon,
          color: foregroundColor,
          onPressed: action.onPressed,
          tooltip: action.tooltip,
        );
      }
      return action;
    }).toList();
  }

  /// Build gradient background
  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B46C1), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

/// Variants of the custom app bar
enum CustomAppBarVariant {
  /// Standard app bar with normal height (56dp)
  standard,

  /// Large app bar with extended height (112dp) for prominent screens
  large,

  /// Minimal app bar with reduced height (48dp) for compact layouts
  minimal,
}
