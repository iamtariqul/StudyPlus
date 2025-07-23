import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onStartStudySession;
  final VoidCallback onAddAssignment;
  final VoidCallback onViewGrades;

  const QuickActionsWidget({
    super.key,
    required this.onStartStudySession,
    required this.onAddAssignment,
    required this.onViewGrades,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Start Session',
                'play_arrow',
                AppTheme.lightTheme.colorScheme.primary,
                onStartStudySession,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                'Add Assignment',
                'add_task',
                AppTheme.lightTheme.colorScheme.secondary,
                onAddAssignment,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                'View Grades',
                'grade',
                AppTheme.getSuccessColor(true),
                onViewGrades,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    String iconName,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: Colors.white,
                size: 6.w,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
