import 'package:flutter/material.dart';

class ProgressWidget extends StatefulWidget {
  final String title;
  final String progressText;
  final double progressValue;
  final Color color;

  const ProgressWidget({
    super.key,
    required this.title,
    required this.progressText,
    required this.progressValue,
    required this.color,
  });

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progressValue,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progressValue != widget.progressValue) {
      _progressAnimation = Tween<double>(
        begin: oldWidget.progressValue,
        end: widget.progressValue,
      ).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  widget.color.withOpacity(0.25),
                  widget.color.withOpacity(0.1),
                ]
              : [
                  widget.color.withOpacity(0.12),
                  widget.color.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                    ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  widget.progressText,
                  key: ValueKey(widget.progressText),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 16,
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: isDark
                        ? Colors.grey[800]
                        : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}