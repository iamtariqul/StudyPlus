import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GradeLevelPickerWidget extends StatelessWidget {
  final String selectedGradeLevel;
  final Function(String) onGradeLevelSelected;

  const GradeLevelPickerWidget({
    super.key,
    required this.selectedGradeLevel,
    required this.onGradeLevelSelected,
  });

  static const List<String> gradeLevels = [
    'Middle School (6-8)',
    'High School (9-12)',
    'College Freshman',
    'College Sophomore',
    'College Junior',
    'College Senior',
    'Graduate Student',
    'Adult Learner',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'school',
              color: selectedGradeLevel.isNotEmpty
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Grade Level',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (selectedGradeLevel.isNotEmpty) ...[
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.getSuccessColor(true),
                size: 16,
              ),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () => _showGradeLevelPicker(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedGradeLevel.isNotEmpty
                    ? AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.5)
                    : AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.5),
                width: selectedGradeLevel.isNotEmpty ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'school_outlined',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    selectedGradeLevel.isEmpty
                        ? 'Select your grade level'
                        : selectedGradeLevel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selectedGradeLevel.isEmpty
                              ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6)
                              : AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                  ),
                ),
                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showGradeLevelPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Select Grade Level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme
                            .lightTheme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                itemCount: gradeLevels.length,
                itemBuilder: (context, index) {
                  final gradeLevel = gradeLevels[index];
                  final isSelected = selectedGradeLevel == gradeLevel;

                  return GestureDetector(
                    onTap: () {
                      onGradeLevelSelected(gradeLevel);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 0.5.h),
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: isSelected
                                ? 'radio_button_checked'
                                : 'radio_button_unchecked',
                            color: isSelected
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              gradeLevel,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isSelected
                                        ? AppTheme
                                            .lightTheme.colorScheme.primary
                                        : AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                            ),
                          ),
                          if (isSelected)
                            CustomIconWidget(
                              iconName: 'check',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
