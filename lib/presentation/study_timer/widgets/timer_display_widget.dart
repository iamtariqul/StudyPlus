import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TimerDisplayWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final Color sessionColor;
  final AnimationController progressController;
  final bool isRunning;

  const TimerDisplayWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.sessionColor,
    required this.progressController,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0
        ? (totalSeconds - remainingSeconds) / totalSeconds
        : 0.0;
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return Container(
      width: 70.w,
      height: 70.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: sessionColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Progress ring
          SizedBox(
            width: 65.w,
            height: 65.w,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: sessionColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(sessionColor),
              strokeCap: StrokeCap.round,
            ),
          ),

          // Timer text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: AppTheme.getDataTextStyle(
                  isLight: true,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                ).copyWith(
                  color: sessionColor,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                isRunning ? 'Focus Time' : 'Ready to Start',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          // Pulse effect when running
          if (isRunning) ...[
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: sessionColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
