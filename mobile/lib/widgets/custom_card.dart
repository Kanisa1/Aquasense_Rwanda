import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final Widget? trailing;
  final Widget? leading;
  final bool isLoading;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.elevation = 2.0,
    this.color,
    this.borderRadius,
    this.onTap,
    this.showBorder = false,
    this.borderColor = Colors.grey,
    this.borderWidth = 1.0,
    this.boxShadow,
    this.gradient,
    this.trailing,
    this.leading,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? Theme.of(context).cardTheme.color ?? Colors.white;
    final radius = borderRadius ?? BorderRadius.circular(12);

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              color: gradient == null ? cardColor : null,
              gradient: gradient,
              borderRadius: radius,
              border: showBorder ? Border.all(color: borderColor, width: borderWidth) : null,
              boxShadow: boxShadow ??
                  [
                    if (elevation > 0)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: elevation * 2,
                        offset: Offset(0, elevation),
                      ),
                  ],
            ),
            child: Padding(
              padding: padding,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : leading != null || trailing != null
                      ? Row(
                          children: [
                            if (leading != null) ...[
                              leading!,
                              const SizedBox(width: 16),
                            ],
                            Expanded(child: child),
                            if (trailing != null) ...[
                              const SizedBox(width: 16),
                              trailing!,
                            ],
                          ],
                        )
                      : child,
            ),
          ),
        ),
      ),
    );
  }
}

