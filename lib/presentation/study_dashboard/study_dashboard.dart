import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/study_metrics_card_widget.dart';
import './widgets/subject_overview_widget.dart';
import './widgets/weekly_chart_widget.dart';

class StudyDashboard extends StatefulWidget {
  const StudyDashboard({super.key});

  @override
  State<StudyDashboard> createState() => _StudyDashboardState();
}

class _StudyDashboardState extends State<StudyDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;

  // Mock data for dashboard
  final Map<String, dynamic> _userData = {
    "name": "Alex Johnson",
    "studyStreak": 12,
    "todayStudyTime": 3.5,
    "dailyGoal": 6.0,
    "totalSubjects": 5,
    "completedAssignments": 23,
    "pendingAssignments": 4,
    "averageGrade": 87.5,
  };

  final List<Map<String, dynamic>> _recentActivities = [
    {
      "id": 1,
      "type": "study_session",
      "title": "Mathematics Study Session",
      "duration": "2h 30m",
      "timestamp": "2 hours ago",
      "icon": "timer",
      "color": 0xFF2563EB,
    },
    {
      "id": 2,
      "type": "assignment",
      "title": "Physics Lab Report Completed",
      "grade": "A-",
      "timestamp": "5 hours ago",
      "icon": "assignment_turned_in",
      "color": 0xFF059669,
    },
    {
      "id": 3,
      "type": "achievement",
      "title": "Study Streak Achievement Unlocked!",
      "description": "10 days in a row",
      "timestamp": "1 day ago",
      "icon": "emoji_events",
      "color": 0xFF7C3AED,
    },
    {
      "id": 4,
      "type": "grade",
      "title": "Chemistry Quiz Result",
      "grade": "B+",
      "timestamp": "2 days ago",
      "icon": "grade",
      "color": 0xFFD97706,
    },
  ];

  final List<Map<String, dynamic>> _subjects = [
    {
      "id": 1,
      "name": "Mathematics",
      "progress": 0.75,
      "nextDeadline": "Assignment due in 3 days",
      "color": 0xFF2563EB,
      "totalHours": 45.5,
      "completedTopics": 12,
      "totalTopics": 16,
    },
    {
      "id": 2,
      "name": "Physics",
      "progress": 0.60,
      "nextDeadline": "Lab report due tomorrow",
      "color": 0xFF059669,
      "totalHours": 38.0,
      "completedTopics": 9,
      "totalTopics": 15,
    },
    {
      "id": 3,
      "name": "Chemistry",
      "progress": 0.85,
      "nextDeadline": "Quiz next week",
      "color": 0xFF7C3AED,
      "totalHours": 52.5,
      "completedTopics": 17,
      "totalTopics": 20,
    },
    {
      "id": 4,
      "name": "Biology",
      "progress": 0.45,
      "nextDeadline": "Project due in 1 week",
      "color": 0xFFD97706,
      "totalHours": 28.0,
      "completedTopics": 7,
      "totalTopics": 18,
    },
  ];

  final List<Map<String, dynamic>> _weeklyData = [
    {"day": "Mon", "hours": 4.5, "date": "Jul 7"},
    {"day": "Tue", "hours": 3.2, "date": "Jul 8"},
    {"day": "Wed", "hours": 5.8, "date": "Jul 9"},
    {"day": "Thu", "hours": 3.5, "date": "Jul 10"},
    {"day": "Fri", "hours": 0.0, "date": "Jul 11"},
    {"day": "Sat", "hours": 0.0, "date": "Jul 12"},
    {"day": "Sun", "hours": 0.0, "date": "Jul 13"},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _startStudySession() {
    Navigator.pushNamed(context, '/study-timer');
  }

  void _navigateToAddAssignment() {
    // Navigate to add assignment screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Assignment feature coming soon!')),
    );
  }

  void _navigateToGrades() {
    // Navigate to grades screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View Grades feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top row with greeting and notification
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good morning,',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              _userData["name"] as String,
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: 'notifications',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 6.w,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Study streak counter
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.lightTheme.colorScheme.primary,
                          AppTheme.lightTheme.colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'local_fire_department',
                          color: Colors.white,
                          size: 8.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Study Streak',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              Text(
                                '${_userData["studyStreak"]} days',
                                style: AppTheme.lightTheme.textTheme.titleLarge
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Keep it up!',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Dashboard'),
                      Tab(text: 'Subjects'),
                      Tab(text: 'Calendar'),
                      Tab(text: 'Profile'),
                    ],
                  ),
                ],
              ),
            ),
            // Tab Bar View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Dashboard Tab
                  RefreshIndicator(
                    onRefresh: _handleRefresh,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Study Metrics Card
                          StudyMetricsCardWidget(
                            todayStudyTime:
                                _userData["todayStudyTime"] as double,
                            dailyGoal: _userData["dailyGoal"] as double,
                            totalSubjects: _userData["totalSubjects"] as int,
                            completedAssignments:
                                _userData["completedAssignments"] as int,
                            pendingAssignments:
                                _userData["pendingAssignments"] as int,
                            averageGrade: _userData["averageGrade"] as double,
                          ),
                          SizedBox(height: 3.h),
                          // Quick Actions
                          QuickActionsWidget(
                            onStartStudySession: _startStudySession,
                            onAddAssignment: _navigateToAddAssignment,
                            onViewGrades: _navigateToGrades,
                          ),
                          SizedBox(height: 3.h),
                          // Weekly Chart
                          WeeklyChartWidget(weeklyData: _weeklyData),
                          SizedBox(height: 3.h),
                          // Recent Activity
                          RecentActivityWidget(activities: _recentActivities),
                          SizedBox(height: 10.h), // Bottom padding for FAB
                        ],
                      ),
                    ),
                  ),
                  // Subjects Tab
                  SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Subjects',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        SubjectOverviewWidget(subjects: _subjects),
                      ],
                    ),
                  ),
                  // Calendar Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'calendar_today',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 15.w,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Calendar View',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Coming Soon',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Profile Tab
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 15.w,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Profile Settings',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Coming Soon',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _startStudySession,
              icon: CustomIconWidget(
                iconName: 'play_arrow',
                color: Colors.white,
                size: 6.w,
              ),
              label: Text(
                'Start Session',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            )
          : null,
    );
  }
}
