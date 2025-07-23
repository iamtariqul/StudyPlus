import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/study_logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _showBiometricPrompt = false;
  String? _emailError;
  String? _passwordError;

  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadSavedEmail();
  }

  Future<void> _initializeServices() async {
    _authService = AuthService();
    await _authService.initialize();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _loadSavedEmail() {
    // Load saved email from preferences if available
    _emailController.text = "student@studyplus.com";
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8;
  }

  void _validateInputs() {
    setState(() {
      _emailError = null;
      _passwordError = null;

      if (_emailController.text.isEmpty) {
        _emailError = "Please enter your student email";
      } else if (!_isValidEmail(_emailController.text)) {
        _emailError = "Please enter a valid email address";
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = "Please enter your password";
      } else if (!_isValidPassword(_passwordController.text)) {
        _passwordError = "Password must be at least 8 characters";
      }
    });
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _isValidEmail(_emailController.text) &&
        _isValidPassword(_passwordController.text) &&
        _emailError == null &&
        _passwordError == null;
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid) {
      _validateInputs();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Update last login timestamp
        await _authService.updateLastLogin();

        // Trigger haptic feedback
        HapticFeedback.lightImpact();

        // Show biometric prompt for first-time login
        setState(() {
          _showBiometricPrompt = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorMessage(
            "Invalid credentials. Please check your email and password.");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage = "An error occurred during login.";
      if (e.toString().contains('Invalid login credentials')) {
        errorMessage = "Invalid email or password. Please try again.";
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = "Please verify your email address before logging in.";
      } else if (e.toString().contains('network')) {
        errorMessage =
            "Network error. Please check your connection and try again.";
      }

      _showErrorMessage(errorMessage);
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.getErrorColor(
            Theme.of(context).brightness == Brightness.light),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _handleBiometricSetup(bool enabled) {
    setState(() {
      _showBiometricPrompt = false;
    });

    if (enabled) {
      HapticFeedback.mediumImpact();
    }

    // Navigate to study dashboard
    Navigator.pushReplacementNamed(context, '/study-dashboard');
  }

  Future<void> _handleForgotPassword() async {
    final emailController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Password',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter your email address to receive password reset instructions.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );

    if (result == true && emailController.text.isNotEmpty) {
      try {
        await _authService.resetPassword(email: emailController.text.trim());
        _showErrorMessage("Password reset email sent successfully!");
      } catch (e) {
        _showErrorMessage("Failed to send reset email. Please try again.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 8.h),

                      // Study Logo
                      StudyLogoWidget(),

                      SizedBox(height: 6.h),

                      // Welcome Text
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 1.h),

                      Text(
                        'Sign in to continue your study journey',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 4.h),

                      // Login Form
                      LoginFormWidget(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        emailFocusNode: _emailFocusNode,
                        passwordFocusNode: _passwordFocusNode,
                        isPasswordVisible: _isPasswordVisible,
                        emailError: _emailError,
                        passwordError: _passwordError,
                        isLoading: _isLoading,
                        isFormValid: _isFormValid,
                        onPasswordVisibilityToggle: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        onEmailChanged: (value) {
                          if (_emailError != null) {
                            setState(() {
                              _emailError = null;
                            });
                          }
                        },
                        onPasswordChanged: (value) {
                          if (_passwordError != null) {
                            setState(() {
                              _passwordError = null;
                            });
                          }
                        },
                        onForgotPassword: _handleForgotPassword,
                        onLogin: _handleLogin,
                      ),

                      const Spacer(),

                      // Sign Up Link
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New student? ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, '/registration-screen');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 2.w),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign Up',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Biometric Prompt Overlay
            if (_showBiometricPrompt)
              BiometricPromptWidget(
                onSetupComplete: _handleBiometricSetup,
              ),
          ],
        ),
      ),
    );
  }
}
