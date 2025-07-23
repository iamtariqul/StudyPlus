import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SessionControlsWidget extends StatelessWidget {
  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onStop;
  final Color sessionColor;

  const SessionControlsWidget({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.onStart,
    required this.onPause,
    required this.onStop,
    required this.sessionColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop button (only when running or paused)
        if (isRunning || isPaused) ...[
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border.all(
                color: AppTheme.getErrorColor(true).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: IconButton(
              onPressed: onStop,
              icon: CustomIconWidget(
                iconName: 'stop',
                color: AppTheme.getErrorColor(true),
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 6.w),
        ],

        // Main play/pause button
        Container(
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: sessionColor,
            boxShadow: [
              BoxShadow(
                color: sessionColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 4,
              ),
            ],
          ),
          child: IconButton(
            onPressed: isRunning ? onPause : onStart,
            icon: CustomIconWidget(
              iconName: isRunning ? 'pause' : 'play_arrow',
              color: Colors.white,
              size: 32,
            ),
          ),
        ),

        // Spacer for symmetry when stop button is visible
        if (isRunning || isPaused) ...[
          SizedBox(width: 6.w),
          SizedBox(width: 14.w),
        ],
      ],
    );
  }
}
