import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SubjectOverviewWidget extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;

  const SubjectOverviewWidget({
    super.key,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    return subjects.isEmpty
        ? _buildEmptyState()
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subjects.length,
            separatorBuilder: (context, index) => SizedBox(height: 3.h),
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return _buildSubjectCard(subject, context);
            },
          );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'school',
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.4),
            size: 15.w,
          ),
          SizedBox(height: 3.h),
          Text(
            'No subjects added yet',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Add your first subject to start tracking your academic progress',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to add subject screen
            },
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 5.w,
            ),
            label: Text(
              'Add Your First Subject',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject, BuildContext context) {
    final Color subjectColor = Color(subject["color"] as int);
    final double progress = subject["progress"] as double;
    final bool hasUrgentDeadline =
        (subject["nextDeadline"] as String).contains('tomorrow');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              subjectColor.withValues(alpha: 0.05),
              Colors.transparent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with subject name and color indicator
            Row(
              children: [
                Container(
                  width: 1.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: subjectColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject["name"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        '${subject["totalHours"]} hours studied',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'school',
                    color: subjectColor,
                    size: 5.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            // Progress section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: subjectColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: subjectColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
                        minHeight: 1.h,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '${subject["completedTopics"]} of ${subject["totalTopics"]} topics completed',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            // Deadline section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: hasUrgentDeadline
                    ? AppTheme.getWarningColor(true).withValues(alpha: 0.1)
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasUrgentDeadline
                      ? AppTheme.getWarningColor(true).withValues(alpha: 0.3)
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: hasUrgentDeadline ? 'warning' : 'schedule',
                    color: hasUrgentDeadline
                        ? AppTheme.getWarningColor(true)
                        : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                    size: 4.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      subject["nextDeadline"] as String,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: hasUrgentDeadline
                            ? AppTheme.getWarningColor(true)
                            : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                        fontWeight: hasUrgentDeadline
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to subject details
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                '${subject["name"]} details coming soon!')),
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'visibility',
                      color: subjectColor,
                      size: 4.w,
                    ),
                    label: Text(
                      'View Details',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: subjectColor,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: subjectColor),
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Start study session for this subject
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Starting ${subject["name"]} study session!')),
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'play_arrow',
                      color: Colors.white,
                      size: 4.w,
                    ),
                    label: Text(
                      'Study Now',
                      style:
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: subjectColor,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
