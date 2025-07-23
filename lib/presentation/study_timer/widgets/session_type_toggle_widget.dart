import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../study_timer.dart';

class SessionTypeToggleWidget extends StatelessWidget {
  final SessionType currentType;
  final Function(SessionType) onTypeChanged;
  final bool isEnabled;

  const SessionTypeToggleWidget({
    super.key,
    required this.currentType,
    required this.onTypeChanged,
    required this.isEnabled,
  });

  Color _getTypeColor(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return AppTheme.lightTheme.primaryColor;
      case SessionType.shortBreak:
        return AppTheme.getSuccessColor(true);
      case SessionType.longBreak:
        return AppTheme.getWarningColor(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: SessionType.values.map((type) {
          final isSelected = type == currentType;
          final typeColor = _getTypeColor(type);

          return Expanded(
            child: GestureDetector(
              onTap: isEnabled ? () => onTypeChanged(type) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                decoration: BoxDecoration(
                  color: isSelected ? typeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: typeColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type.name,
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _getDurationText(type),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getDurationText(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return '25 min';
      case SessionType.shortBreak:
        return '5 min';
      case SessionType.longBreak:
        return '15 min';
    }
  }
}
