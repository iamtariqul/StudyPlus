import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PasswordStrengthWidget extends StatelessWidget {
  final Map<String, bool> requirements;

  const PasswordStrengthWidget({
    super.key,
    required this.requirements,
  });

  @override
  Widget build(BuildContext context) {
    final completedRequirements =
        requirements.values.where((req) => req).length;
    final totalRequirements = requirements.length;
    final strengthPercentage = completedRequirements / totalRequirements;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'security',
                color: _getStrengthColor(strengthPercentage),
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Password Strength',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              Text(
                _getStrengthText(strengthPercentage),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: _getStrengthColor(strengthPercentage),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          LinearProgressIndicator(
            value: strengthPercentage,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
                _getStrengthColor(strengthPercentage)),
            minHeight: 4,
          ),
          SizedBox(height: 2.h),
          Column(
            children: [
              _buildRequirementItem(
                'At least 8 characters',
                requirements['minLength'] ?? false,
              ),
              _buildRequirementItem(
                'One uppercase letter',
                requirements['hasUppercase'] ?? false,
              ),
              _buildRequirementItem(
                'One lowercase letter',
                requirements['hasLowercase'] ?? false,
              ),
              _buildRequirementItem(
                'One number',
                requirements['hasNumber'] ?? false,
              ),
              _buildRequirementItem(
                'One special character',
                requirements['hasSpecialChar'] ?? false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: isMet ? 'check_circle' : 'radio_button_unchecked',
            color: isMet
                ? AppTheme.getSuccessColor(true)
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 16,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Builder(
              builder: (context) => Text(
                requirement,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isMet
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: isMet ? FontWeight.w500 : FontWeight.w400,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStrengthColor(double percentage) {
    if (percentage >= 1.0) {
      return AppTheme.getSuccessColor(true);
    } else if (percentage >= 0.6) {
      return AppTheme.getWarningColor(true);
    } else {
      return AppTheme.getErrorColor(true);
    }
  }

  String _getStrengthText(double percentage) {
    if (percentage >= 1.0) {
      return 'Strong';
    } else if (percentage >= 0.6) {
      return 'Medium';
    } else {
      return 'Weak';
    }
  }
}
