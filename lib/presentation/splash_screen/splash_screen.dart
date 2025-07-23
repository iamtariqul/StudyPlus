import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _loadingAnimation;

  bool _showRetryOption = false;
  bool _isInitializing = true;
  String _initializationStatus = 'Initializing StudyPlus...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _loadingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _loadingAnimationController,
      curve: Curves.easeInOut,
    ));

    _logoAnimationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate initialization steps
      await _performInitializationSteps();

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _showRetryOption = true;
          _isInitializing = false;
          _initializationStatus = 'Failed to initialize. Please try again.';
        });
      }
    }
  }

  Future<void> _performInitializationSteps() async {
    // Step 1: Check authentication status
    setState(() {
      _initializationStatus = 'Checking authentication...';
    });
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 2: Load user preferences
    setState(() {
      _initializationStatus = 'Loading study preferences...';
    });
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 3: Sync cached data
    setState(() {
      _initializationStatus = 'Syncing study data...';
    });
    await Future.delayed(const Duration(milliseconds: 700));

    // Step 4: Prepare offline database
    setState(() {
      _initializationStatus = 'Preparing offline database...';
    });
    await Future.delayed(const Duration(milliseconds: 500));

    // Final step
    setState(() {
      _initializationStatus = 'Ready to study!';
    });
    await Future.delayed(const Duration(milliseconds: 400));
  }

  void _navigateToNextScreen() {
    // Simulate navigation logic based on user state
    final bool isAuthenticated = _checkAuthenticationStatus();
    final bool isFirstTime = _checkFirstTimeUser();

    String nextRoute;
    if (isAuthenticated) {
      nextRoute = '/study-dashboard';
    } else if (isFirstTime) {
      nextRoute = '/onboarding-flow';
    } else {
      nextRoute = '/login-screen';
    }

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  bool _checkAuthenticationStatus() {
    // Mock authentication check
    return false; // Simulate non-authenticated user
  }

  bool _checkFirstTimeUser() {
    // Mock first-time user check
    return true; // Simulate first-time user
  }

  void _retryInitialization() {
    setState(() {
      _showRetryOption = false;
      _isInitializing = true;
      _initializationStatus = 'Retrying initialization...';
    });
    _initializeApp();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.lightTheme.primaryColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.lightTheme.primaryColor,
                AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
                AppTheme.lightTheme.colorScheme.secondary,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildLogo(),
                SizedBox(height: 8.h),
                _buildLoadingSection(),
                const Spacer(flex: 3),
                _buildBottomSection(),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoFadeAnimation.value,
            child: Column(
              children: [
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'school',
                      color: Colors.white,
                      size: 12.w,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'StudyPlus',
                  style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Your Study Companion',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        _isInitializing ? _buildLoadingIndicator() : const SizedBox.shrink(),
        SizedBox(height: 2.h),
        Text(
          _initializationStatus,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        if (_showRetryOption) ...[
          SizedBox(height: 3.h),
          _buildRetryButton(),
        ],
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _loadingAnimation,
      builder: (context, child) {
        return Container(
          width: 60.w,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 60.w * _loadingAnimation.value,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton(
      onPressed: _retryInitialization,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.lightTheme.primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'refresh',
            color: AppTheme.lightTheme.primaryColor,
            size: 18,
          ),
          SizedBox(width: 2.w),
          Text(
            'Retry',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Column(
      children: [
        Text(
          'Empowering students to achieve academic excellence',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeatureIcon('timer', 'Study Timer'),
            SizedBox(width: 8.w),
            _buildFeatureIcon('assignment', 'Track Progress'),
            SizedBox(width: 8.w),
            _buildFeatureIcon('trending_up', 'Analytics'),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureIcon(String iconName, String label) {
    return Column(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: Colors.white.withValues(alpha: 0.9),
              size: 6.w,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
