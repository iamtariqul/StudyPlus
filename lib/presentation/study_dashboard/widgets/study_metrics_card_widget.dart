import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StudyMetricsCardWidget extends StatelessWidget {
  final double todayStudyTime;
  final double dailyGoal;
  final int totalSubjects;
  final int completedAssignments;
  final int pendingAssignments;
  final double averageGrade;

  const StudyMetricsCardWidget({
    super.key,
    required this.todayStudyTime,
    required this.dailyGoal,
    required this.totalSubjects,
    required this.completedAssignments,
    required this.pendingAssignments,
    required this.averageGrade,
  });

  @override
  Widget build(BuildContext context) {
    final double progressPercentage =
        (todayStudyTime / dailyGoal).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            // Circular Progress for Study Time
            Row(
              children: [
                SizedBox(
                  width: 25.w,
                  height: 25.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 25.w,
                        height: 25.w,
                        child: CircularProgressIndicator(
                          value: progressPercentage,
                          strokeWidth: 8,
                          backgroundColor: AppTheme
                              .lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${todayStudyTime.toStringAsFixed(1)}h',
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'of ${dailyGoal.toStringAsFixed(0)}h',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetricRow(
                        'Subjects',
                        totalSubjects.toString(),
                        'school',
                        AppTheme.lightTheme.colorScheme.secondary,
                      ),
                      SizedBox(height: 2.h),
                      _buildMetricRow(
                        'Completed',
                        completedAssignments.toString(),
                        'assignment_turned_in',
                        AppTheme.getSuccessColor(true),
                      ),
                      SizedBox(height: 2.h),
                      _buildMetricRow(
                        'Pending',
                        pendingAssignments.toString(),
                        'assignment',
                        AppTheme.getWarningColor(true),
                      ),
                      SizedBox(height: 2.h),
                      _buildMetricRow(
                        'Avg Grade',
                        '${averageGrade.toStringAsFixed(1)}%',
                        'grade',
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            // Progress message
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: progressPercentage >= 1.0
                    ? AppTheme.getSuccessColor(true).withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName:
                        progressPercentage >= 1.0 ? 'check_circle' : 'info',
                    color: progressPercentage >= 1.0
                        ? AppTheme.getSuccessColor(true)
                        : AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      progressPercentage >= 1.0
                          ? 'Great job! You\'ve reached your daily goal!'
                          : 'You\'re ${((1 - progressPercentage) * dailyGoal).toStringAsFixed(1)} hours away from your goal',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: progressPercentage >= 1.0
                            ? AppTheme.getSuccessColor(true)
                            : AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
      String label, String value, String iconName, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: color,
            size: 4.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
