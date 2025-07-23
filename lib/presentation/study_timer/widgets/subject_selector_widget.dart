import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SubjectSelectorWidget extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  final String selectedSubject;
  final Function(String) onSubjectChanged;
  final bool isEnabled;

  const SubjectSelectorWidget({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.onSubjectChanged,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            'Select Subject',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 12.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            itemCount: subjects.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final subject = subjects[index];
              final isSelected = subject['name'] == selectedSubject;

              return GestureDetector(
                onTap:
                    isEnabled ? () => onSubjectChanged(subject['name']) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20.w,
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (subject['color'] as Color).withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (subject['color'] as Color)
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (subject['color'] as Color)
                                  .withValues(alpha: 0.2),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: subject['icon'],
                        color: isSelected
                            ? (subject['color'] as Color)
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        subject['name'],
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? (subject['color'] as Color)
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 1.w, vertical: 0.2.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (subject['color'] as Color)
                                  .withValues(alpha: 0.2)
                              : AppTheme.lightTheme.colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${subject['sessions']}',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: isSelected
                                ? (subject['color'] as Color)
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
