import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import './widgets/grade_level_picker_widget.dart';
import './widgets/password_strength_widget.dart';
import './widgets/terms_checkbox_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Focus nodes
  final _fullNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // Form state
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String _selectedGradeLevel = '';
  bool _termsAccepted = false;
  bool _privacyAccepted = false;
  bool _coppaCompliant = false;

  // Validation states
  bool _isFullNameValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _isGradeLevelValid = false;

  // Password strength requirements
  Map<String, bool> _passwordRequirements = {
    'minLength': false,
    'hasUppercase': false,
    'hasLowercase': false,
    'hasNumber': false,
    'hasSpecialChar': false,
  };

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _setupFormListeners();
  }

  Future<void> _initializeServices() async {
    _authService = AuthService();
    await _authService.initialize();
  }

  void _setupFormListeners() {
    _fullNameController.addListener(_validateFullName);
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _validateFullName() {
    setState(() {
      _isFullNameValid = _fullNameController.text.trim().length >= 2 &&
          _fullNameController.text.trim().contains(' ');
    });
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;

    setState(() {
      _passwordRequirements = {
        'minLength': password.length >= 8,
        'hasUppercase': password.contains(RegExp(r'[A-Z]')),
        'hasLowercase': password.contains(RegExp(r'[a-z]')),
        'hasNumber': password.contains(RegExp(r'[0-9]')),
        'hasSpecialChar': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      };

      _isPasswordValid = _passwordRequirements.values.every((req) => req);
    });

    if (_confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword();
    }
  }

  void _validateConfirmPassword() {
    setState(() {
      _isConfirmPasswordValid =
          _confirmPasswordController.text == _passwordController.text &&
              _passwordController.text.isNotEmpty;
    });
  }

  void _onGradeLevelSelected(String gradeLevel) {
    setState(() {
      _selectedGradeLevel = gradeLevel;
      _isGradeLevelValid = gradeLevel.isNotEmpty;
    });
  }

  bool get _isFormValid {
    return _isFullNameValid &&
        _isEmailValid &&
        _isPasswordValid &&
        _isConfirmPasswordValid &&
        _isGradeLevelValid &&
        _termsAccepted &&
        _privacyAccepted &&
        _coppaCompliant;
  }

  Future<void> _createAccount() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        gradeLevel: _selectedGradeLevel,
      );

      if (response.user != null) {
        _showEmailVerificationDialog();
      } else {
        _showErrorDialog('Account creation failed. Please try again.');
      }
    } catch (e) {
      String errorMessage = 'Failed to create account. Please try again.';

      if (e.toString().contains('already registered')) {
        errorMessage = 'An account with this email already exists.';
      } else if (e.toString().contains('Password should be at least')) {
        errorMessage = 'Password does not meet requirements.';
      } else if (e.toString().contains('Unable to validate email')) {
        errorMessage = 'Please enter a valid email address.';
      }

      _showErrorDialog(errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'email',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Verify Email',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We have sent a verification email to:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              _emailController.text.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Please check your email and click the verification link to activate your account.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await _authService.resendEmailVerification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification email resent!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to resend email. Please try again.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Resend Email'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/login-screen');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Registration Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeSection(),
                      SizedBox(height: 4.h),
                      _buildFullNameField(),
                      SizedBox(height: 3.h),
                      _buildEmailField(),
                      SizedBox(height: 3.h),
                      _buildPasswordField(),
                      SizedBox(height: 2.h),
                      PasswordStrengthWidget(
                        requirements: _passwordRequirements,
                      ),
                      SizedBox(height: 3.h),
                      _buildConfirmPasswordField(),
                      SizedBox(height: 3.h),
                      GradeLevelPickerWidget(
                        selectedGradeLevel: _selectedGradeLevel,
                        onGradeLevelSelected: _onGradeLevelSelected,
                      ),
                      SizedBox(height: 4.h),
                      TermsCheckboxWidget(
                        termsAccepted: _termsAccepted,
                        privacyAccepted: _privacyAccepted,
                        coppaCompliant: _coppaCompliant,
                        onTermsChanged: (value) =>
                            setState(() => _termsAccepted = value),
                        onPrivacyChanged: (value) =>
                            setState(() => _privacyAccepted = value),
                        onCoppaChanged: (value) =>
                            setState(() => _coppaCompliant = value),
                      ),
                      SizedBox(height: 4.h),
                      _buildCreateAccountButton(),
                      SizedBox(height: 3.h),
                      _buildLoginLink(),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'Sign Up',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Your StudyPlus Account',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Join thousands of students who are already improving their study habits and academic performance.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildFullNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'person',
              color: _isFullNameValid
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Full Name',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (_isFullNameValid) ...[
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
        TextFormField(
          controller: _fullNameController,
          focusNode: _fullNameFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _emailFocus.requestFocus(),
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'person_outline',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your full name';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            if (!value.trim().contains(' ')) {
              return 'Please enter your first and last name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'email',
              color: _isEmailValid
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Email Address',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (_isEmailValid) ...[
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
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          decoration: InputDecoration(
            hintText: 'Enter your email address',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'email_outlined',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email address';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'lock',
              color: _isPasswordValid
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Password',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (_isPasswordValid) ...[
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
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
          decoration: InputDecoration(
            hintText: 'Create a strong password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock_outline',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: GestureDetector(
              onTap: () =>
                  setState(() => _isPasswordVisible = !_isPasswordVisible),
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName:
                      _isPasswordVisible ? 'visibility_off' : 'visibility',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (!_isPasswordValid) {
              return 'Password does not meet security requirements';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'lock',
              color: _isConfirmPasswordValid
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Confirm Password',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            if (_isConfirmPasswordValid) ...[
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
        TextFormField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          obscureText: !_isConfirmPasswordVisible,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Confirm your password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock_outline',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            suffixIcon: GestureDetector(
              onTap: () => setState(
                  () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: _isConfirmPasswordVisible
                      ? 'visibility_off'
                      : 'visibility',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: _isFormValid && !_isLoading ? _createAccount : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'person_add',
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pushReplacementNamed(context, '/login-screen'),
        child: RichText(
          text: TextSpan(
            text: 'Already have an account? ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
            children: [
              TextSpan(
                text: 'Login',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
