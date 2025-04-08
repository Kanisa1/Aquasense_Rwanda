import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedProgressBar extends StatefulWidget {
  final double value;
  final double height;
  final Color backgroundColor;
  final Color foregroundColor;
  final Widget? label;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool showPercentage;
  final TextStyle? percentageTextStyle;
  final BorderRadius? borderRadius;
  final bool showShadow;

  const AnimatedProgressBar({
    Key? key,
    required this.value,
    this.height = 10.0,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.foregroundColor = const Color(0xFF0E77B7),
    this.label,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOut,
    this.showPercentage = false,
    this.percentageTextStyle,
    this.borderRadius,
    this.showShadow = false,
  }) : super(key: key);

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.animationCurve,
      ),
    );
    _previousValue = widget.value;
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animation = Tween<double>(begin: _previousValue, end: widget.value).animate(
        CurvedAnimation(
          parent: _controller,
          curve: widget.animationCurve,
        ),
      );
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(widget.height / 2);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          widget.label!,
          const SizedBox(height: 4),
        ],
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: widget.showShadow ? BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(
                    color: widget.foregroundColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ) : null,
              child: ClipRRect(
                borderRadius: borderRadius,
                child: Stack(
                  children: [
                    // Background
                    Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        borderRadius: borderRadius,
                      ),
                    ),
                    // Foreground
                    Container(
                      height: widget.height,
                      width: math.max(widget.height, MediaQuery.of(context).size.width * _animation.value),
                      decoration: BoxDecoration(
                        color: widget.foregroundColor,
                        borderRadius: borderRadius,
                      ),
                    ),
                    // Percentage text
                    if (widget.showPercentage)
                      Positioned.fill(
                        child: Center(
                          child: Text(
                            '${(_animation.value * 100).toInt()}%',
                            style: widget.percentageTextStyle ??
                                TextStyle(
                                  color: Colors.white,
                                  fontSize: math.max(widget.height * 0.6, 10),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

