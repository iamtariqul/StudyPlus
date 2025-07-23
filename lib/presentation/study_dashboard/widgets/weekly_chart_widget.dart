import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WeeklyChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> weeklyData;

  const WeeklyChartWidget({
    super.key,
    required this.weeklyData,
  });

  @override
  State<WeeklyChartWidget> createState() => _WeeklyChartWidgetState();
}

class _WeeklyChartWidgetState extends State<WeeklyChartWidget> {
  int _selectedBarIndex = -1;

  @override
  Widget build(BuildContext context) {
    final double maxHours = widget.weeklyData
        .map((data) => data["hours"] as double)
        .reduce((a, b) => a > b ? a : b);

    final double totalWeekHours = widget.weeklyData
        .map((data) => data["hours"] as double)
        .reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Weekly Study Time',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600)),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${totalWeekHours.toStringAsFixed(1)}h total',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600))),
        ]),
        SizedBox(height: 3.h),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.1))),
          child: Container(
            width: double.infinity,
            height: 35.h,
            padding: EdgeInsets.all(5.w),
            child: Column(
              children: [
                // Chart legend
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                      width: 3.w,
                      height: 1.h,
                      decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(2))),
                  SizedBox(width: 2.w),
                  Text('Study Hours',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.7))),
                ]),
                SizedBox(height: 3.h),
                // Bar Chart
                Expanded(
                    child: BarChart(BarChartData(
                        maxY: maxHours > 0 ? maxHours + 1 : 6,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchCallback:
                              (FlTouchEvent event, barTouchResponse) {
                            setState(() {
                              if (barTouchResponse != null &&
                                  barTouchResponse.spot != null) {
                                _selectedBarIndex =
                                    barTouchResponse.spot!.touchedBarGroupIndex;
                              } else {
                                _selectedBarIndex = -1;
                              }
                            });
                          },
                          touchTooltipData: BarTouchTooltipData(getTooltipItem:
                              (group, groupIndex, rod, rodIndex) {
                            final dayData = widget.weeklyData[groupIndex];
                            return BarTooltipItem(
                                '${dayData["day"]}, ${dayData["date"]}\n${dayData["hours"]}h studied',
                                AppTheme.lightTheme.textTheme.bodySmall!
                                    .copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.surface,
                                        fontWeight: FontWeight.w500));
                          }),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= 0 &&
                                        value.toInt() <
                                            widget.weeklyData.length) {
                                      final dayData =
                                          widget.weeklyData[value.toInt()];
                                      return Padding(
                                          padding: EdgeInsets.only(top: 1.h),
                                          child: Text(dayData["day"] as String,
                                              style: AppTheme.lightTheme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                      color: AppTheme.lightTheme
                                                          .colorScheme.onSurface
                                                          .withValues(
                                                              alpha: 0.6),
                                                      fontWeight:
                                                          FontWeight.w500)));
                                    }
                                    return const SizedBox.shrink();
                                  },
                                  reservedSize: 4.h)),
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    return Text('${value.toInt()}h',
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.onSurface
                                                    .withValues(alpha: 0.6)));
                                  },
                                  reservedSize: 8.w)),
                        ),
                        borderData: FlBorderData(
                            show: true,
                            border: Border(
                                bottom: BorderSide(
                                    color: AppTheme
                                        .lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    width: 1),
                                left: BorderSide(
                                    color: AppTheme
                                        .lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    width: 1))),
                        barGroups:
                            widget.weeklyData.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          final hours = data["hours"] as double;
                          final isSelected = index == _selectedBarIndex;

                          return BarChartGroupData(x: index, barRods: [
                            BarChartRodData(
                                toY: hours,
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.secondary
                                    : AppTheme.lightTheme.colorScheme.primary,
                                width: 6.w,
                                borderRadius: BorderRadius.circular(4),
                                backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: maxHours > 0 ? maxHours + 1 : 6,
                                    color: AppTheme
                                        .lightTheme.colorScheme.primary
                                        .withValues(alpha: 0.1))),
                          ]);
                        }).toList(),
                        gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                  color: AppTheme.lightTheme.colorScheme.outline
                                      .withValues(alpha: 0.1),
                                  strokeWidth: 1);
                            })))),
              ],
            ),
          ),
        ),
        SizedBox(height: 2.h),
        // Weekly summary
        Row(children: [
          Expanded(
              child: _buildSummaryCard(
                  'Daily Average',
                  '${(totalWeekHours / 7).toStringAsFixed(1)}h',
                  'trending_up',
                  AppTheme.lightTheme.colorScheme.primary)),
          SizedBox(width: 3.w),
          Expanded(
              child: _buildSummaryCard(
                  'Best Day',
                  widget.weeklyData.reduce((a, b) =>
                      (a["hours"] as double) > (b["hours"] as double)
                          ? a
                          : b)["day"] as String,
                  'emoji_events',
                  AppTheme.getSuccessColor(true))),
          SizedBox(width: 3.w),
          Expanded(
              child: _buildSummaryCard(
                  'Goal Progress',
                  '${((totalWeekHours / 42) * 100).toInt()}%',
                  'flag',
                  AppTheme.lightTheme.colorScheme.secondary)),
        ]),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, String value, String iconName, Color color) {
    return Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(children: [
          CustomIconWidget(iconName: iconName, color: color, size: 5.w),
          SizedBox(height: 1.h),
          Text(value,
              style: AppTheme.lightTheme.textTheme.titleMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w700)),
          Text(label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ]));
  }
}
