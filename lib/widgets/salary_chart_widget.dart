import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalaryChartWidget extends StatefulWidget {
  final List<double> dailyData;
  final String period;
  final Color color;

  const SalaryChartWidget({
    super.key,
    required this.dailyData,
    required this.period,
    this.color = Colors.blue,
  });

  @override
  State<SalaryChartWidget> createState() => _SalaryChartWidgetState();
}

class _SalaryChartWidgetState extends State<SalaryChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
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
                  widget.color.withOpacity(0.2),
                  widget.color.withOpacity(0.05),
                ]
              : [
                  widget.color.withOpacity(0.1),
                  Colors.white,
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
            children: [
              Icon(
                Icons.show_chart,
                color: widget.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                '收入趋势',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: widget.color,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LineChart(
                  _buildChartData(isDark),
                  duration: const Duration(milliseconds: 300),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(bool isDark) {
    final data = widget.dailyData;
    if (data.isEmpty) {
      return LineChartData();
    }

    final maxY = data.reduce((a, b) => a > b ? a : b);
    final minY = data.reduce((a, b) => a < b ? a : b);
    final range = maxY - minY;
    final paddedMaxY = maxY + (range * 0.1);
    final paddedMinY = minY - (range * 0.1).clamp(0, minY);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (paddedMaxY - paddedMinY) / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: isDark ? Colors.white24 : Colors.black12,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (data.length / 5).ceilToDouble().clamp(1, data.length.toDouble()),
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= data.length) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${value.toInt() + 1}',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.black54,
                    fontSize: 10,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: (paddedMaxY - paddedMinY) / 4,
            getTitlesWidget: (value, meta) {
              return Text(
                _formatCompact(value),
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: paddedMinY,
      maxY: paddedMaxY,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            (data.length * _animation.value).ceil(),
            (index) => FlSpot(index.toDouble(), data[index]),
          ),
          isCurved: true,
          color: widget.color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.color.withOpacity(0.3),
                widget.color.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => widget.color.withOpacity(0.8),
          tooltipRoundedRadius: 8,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                _formatCurrency(spot.y),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  String _formatCurrency(double value) {
    return '¥${value.toStringAsFixed(2)}';
  }
}
