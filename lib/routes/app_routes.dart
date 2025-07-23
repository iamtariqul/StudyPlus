import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/study_timer/study_timer.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/study_dashboard/study_dashboard.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/subject_management/subject_management.dart';
import '../presentation/assignment_tracker/assignment_tracker.dart';
import '../presentation/study_calendar/study_calendar.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String studyTimer = '/study-timer';
  static const String registrationScreen = '/registration-screen';
  static const String studyDashboard = '/study-dashboard';
  static const String loginScreen = '/login-screen';
  static const String subjectManagement = '/subject-management';
  static const String assignmentTracker = '/assignment-tracker';
  static const String studyCalendar = '/study-calendar';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    studyTimer: (context) => const StudyTimer(),
    registrationScreen: (context) => const RegistrationScreen(),
    studyDashboard: (context) => const StudyDashboard(),
    loginScreen: (context) => const LoginScreen(),
    subjectManagement: (context) => const SubjectManagement(),
    assignmentTracker: (context) => const AssignmentTracker(),
    studyCalendar: (context) => const StudyCalendar(),
    // TODO: Add your other routes here
  };
}
