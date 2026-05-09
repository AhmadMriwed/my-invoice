import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
    this.hoverable = false,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool hoverable;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;
  bool? _pendingHover;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.primary.withValues(alpha: _isHovered ? 0.16 : 0.08)
                : AppColors.goldDark.withValues(
                    alpha: _isHovered ? 0.13 : 0.07,
                  ),
            blurRadius: _isHovered ? 26 : 16,
            offset: Offset(0, _isHovered ? 12 : 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    if (!widget.hoverable) {
      return card;
    }

    return MouseRegion(
      onEnter: (_) => _scheduleHover(true),
      onExit: (_) => _scheduleHover(false),
      child: card,
    );
  }

  void _scheduleHover(bool value) {
    if (!widget.hoverable || _isHovered == value) {
      return;
    }
    _pendingHover = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pendingHover == null) {
        return;
      }
      final next = _pendingHover!;
      _pendingHover = null;
      if (_isHovered != next) {
        setState(() => _isHovered = next);
      }
    });
  }
}
