import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/quick_notes_widget.dart';
import './widgets/session_controls_widget.dart';
import './widgets/session_type_toggle_widget.dart';
import './widgets/subject_selector_widget.dart';
import './widgets/timer_display_widget.dart';

class StudyTimer extends StatefulWidget {
  const StudyTimer({super.key});

  @override
  State<StudyTimer> createState() => _StudyTimerState();
}

class _StudyTimerState extends State<StudyTimer> with TickerProviderStateMixin {
  // Timer state
  Timer? _timer;
  int _remainingSeconds = 1500; // 25 minutes default
  bool _isRunning = false;
  bool _isPaused = false;

  // Session types
  SessionType _currentSessionType = SessionType.focus;
  String _selectedSubject = 'Mathematics';

  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Notes
  final TextEditingController _notesController = TextEditingController();

  // Mock subjects data
  final List<Map<String, dynamic>> subjects = [
    {
      'name': 'Mathematics',
      'color': Color(0xFF2563EB),
      'icon': 'calculate',
      'sessions': 12,
    },
    {
      'name': 'Physics',
      'color': Color(0xFF7C3AED),
      'icon': 'science',
      'sessions': 8,
    },
    {
      'name': 'Chemistry',
      'color': Color(0xFF059669),
      'icon': 'biotech',
      'sessions': 6,
    },
    {
      'name': 'Biology',
      'color': Color(0xFFD97706),
      'icon': 'local_florist',
      'sessions': 4,
    },
    {
      'name': 'History',
      'color': Color(0xFFDC2626),
      'icon': 'history_edu',
      'sessions': 3,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _preventScreenLock();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: Duration(seconds: _remainingSeconds),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  void _preventScreenLock() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _startTimer() {
    if (_isPaused) {
      _resumeTimer();
      return;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _progressController.duration = Duration(seconds: _remainingSeconds);
    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeSession();
        }
      });
    });

    HapticFeedback.lightImpact();
  }

  void _pauseTimer() {
    _timer?.cancel();
    _progressController.stop();

    setState(() {
      _isRunning = false;
      _isPaused = true;
    });

    HapticFeedback.mediumImpact();
  }

  void _resumeTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _completeSession();
        }
      });
    });

    HapticFeedback.lightImpact();
  }

  void _stopTimer() {
    _showEndSessionDialog();
  }

  void _completeSession() {
    _timer?.cancel();
    _progressController.reset();

    setState(() {
      _isRunning = false;
      _isPaused = false;
    });

    HapticFeedback.heavyImpact();
    _showSessionCompleteDialog();
    _logSessionData();
  }

  void _resetTimer() {
    _timer?.cancel();
    _progressController.reset();

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _getSessionDuration(_currentSessionType);
    });
  }

  void _changeSessionType(SessionType type) {
    if (_isRunning) return;

    setState(() {
      _currentSessionType = type;
      _remainingSeconds = _getSessionDuration(type);
    });

    _progressController.reset();
  }

  void _changeSubject(String subject) {
    setState(() {
      _selectedSubject = subject;
    });
  }

  int _getSessionDuration(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return 1500; // 25 minutes
      case SessionType.shortBreak:
        return 300; // 5 minutes
      case SessionType.longBreak:
        return 900; // 15 minutes
    }
  }

  Color _getSessionColor(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return AppTheme.lightTheme.primaryColor;
      case SessionType.shortBreak:
        return AppTheme.getSuccessColor(true);
      case SessionType.longBreak:
        return AppTheme.getWarningColor(true);
    }
  }

  void _showEndSessionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'End Session?',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to end this study session? Your progress will be saved.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
              _logSessionData();
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }

  void _showSessionCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'celebration',
              color: AppTheme.getSuccessColor(true),
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Session Complete!',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.getSuccessColor(true),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Great job! You completed a ${_currentSessionType.name} session.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Summary',
                    style: AppTheme.lightTheme.textTheme.titleSmall,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subject:',
                          style: AppTheme.lightTheme.textTheme.bodySmall),
                      Text(_selectedSubject,
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Duration:',
                          style: AppTheme.lightTheme.textTheme.bodySmall),
                      Text(
                          '${_getSessionDuration(_currentSessionType) ~/ 60} minutes',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500)),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Type:',
                          style: AppTheme.lightTheme.textTheme.bodySmall),
                      Text(_currentSessionType.name.toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_currentSessionType == SessionType.focus) ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _changeSessionType(SessionType.shortBreak);
              },
              child: const Text('Take Break'),
            ),
          ],
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('Start New Session'),
          ),
        ],
      ),
    );
  }

  void _logSessionData() {
    // Mock session logging - in real app would save to SQLite/Supabase
    final sessionData = {
      'subject': _selectedSubject,
      'type': _currentSessionType.name,
      'duration': _getSessionDuration(_currentSessionType),
      'completed': _remainingSeconds == 0,
      'timestamp': DateTime.now().toIso8601String(),
      'notes': _notesController.text.trim(),
    };

    print('Session logged: $sessionData');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _notesController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _getSessionColor(_currentSessionType).withValues(alpha: 0.05),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_isRunning) {
              _showEndSessionDialog();
            } else {
              Navigator.pop(context);
            }
          },
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Study Timer',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isRunning ? null : _resetTimer,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: _isRunning
                  ? AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.3)
                  : AppTheme.lightTheme.colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            children: [
              SizedBox(height: 2.h),

              // Subject Selector
              SubjectSelectorWidget(
                subjects: subjects,
                selectedSubject: _selectedSubject,
                onSubjectChanged: _changeSubject,
                isEnabled: !_isRunning,
              ),

              SizedBox(height: 4.h),

              // Session Type Toggle
              SessionTypeToggleWidget(
                currentType: _currentSessionType,
                onTypeChanged: _changeSessionType,
                isEnabled: !_isRunning,
              ),

              SizedBox(height: 4.h),

              // Timer Display
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isRunning ? _pulseAnimation.value : 1.0,
                    child: TimerDisplayWidget(
                      remainingSeconds: _remainingSeconds,
                      totalSeconds: _getSessionDuration(_currentSessionType),
                      sessionColor: _getSessionColor(_currentSessionType),
                      progressController: _progressController,
                      isRunning: _isRunning,
                    ),
                  );
                },
              ),

              SizedBox(height: 4.h),

              // Session Controls
              SessionControlsWidget(
                isRunning: _isRunning,
                isPaused: _isPaused,
                onStart: _startTimer,
                onPause: _pauseTimer,
                onStop: _stopTimer,
                sessionColor: _getSessionColor(_currentSessionType),
              ),

              SizedBox(height: 4.h),

              // Quick Notes
              QuickNotesWidget(
                controller: _notesController,
                isEnabled: true,
              ),

              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}

enum SessionType {
  focus,
  shortBreak,
  longBreak,
}

extension SessionTypeExtension on SessionType {
  String get name {
    switch (this) {
      case SessionType.focus:
        return 'Focus';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  String get description {
    switch (this) {
      case SessionType.focus:
        return '25 minutes of focused study';
      case SessionType.shortBreak:
        return '5 minutes to recharge';
      case SessionType.longBreak:
        return '15 minutes to relax';
    }
  }
}
