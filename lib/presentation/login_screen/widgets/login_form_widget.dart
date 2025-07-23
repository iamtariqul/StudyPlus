import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LoginFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool isPasswordVisible;
  final String? emailError;
  final String? passwordError;
  final bool isLoading;
  final bool isFormValid;
  final VoidCallback onPasswordVisibilityToggle;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;

  const LoginFormWidget({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.isPasswordVisible,
    this.emailError,
    this.passwordError,
    required this.isLoading,
    required this.isFormValid,
    required this.onPasswordVisibilityToggle,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onForgotPassword,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email Address',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: emailController,
                focusNode: emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                onChanged: onEmailChanged,
                onFieldSubmitted: (_) {
                  passwordFocusNode.requestFocus();
                },
                decoration: InputDecoration(
                  hintText: 'Enter your student email',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'email',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  ),
                  errorText: null,
                ),
              ),
              if (emailError != null) ...[
                SizedBox(height: 1.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'error_outline',
                      color: AppTheme.getErrorColor(
                          Theme.of(context).brightness == Brightness.light),
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        emailError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.getErrorColor(
                                  Theme.of(context).brightness ==
                                      Brightness.light),
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          SizedBox(height: 3.h),

          // Password Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: passwordController,
                focusNode: passwordFocusNode,
                obscureText: !isPasswordVisible,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                onChanged: onPasswordChanged,
                onFieldSubmitted: (_) {
                  if (isFormValid) {
                    onLogin();
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'lock',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: isLoading ? null : onPasswordVisibilityToggle,
                    icon: CustomIconWidget(
                      iconName:
                          isPasswordVisible ? 'visibility_off' : 'visibility',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 5.w,
                    ),
                  ),
                  errorText: null,
                ),
              ),
              if (passwordError != null) ...[
                SizedBox(height: 1.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'error_outline',
                      color: AppTheme.getErrorColor(
                          Theme.of(context).brightness == Brightness.light),
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        passwordError!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.getErrorColor(
                                  Theme.of(context).brightness ==
                                      Brightness.light),
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          SizedBox(height: 2.h),

          // Forgot Password Link
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Login Button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: (isFormValid && !isLoading) ? onLogin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.3),
                foregroundColor: Colors.white,
                elevation: isFormValid ? 2 : 0,
                shadowColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3.w),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Login',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
            ),
          ),

          SizedBox(height: 2.h),

          // Mock Credentials Info
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      color: Theme.of(context).colorScheme.primary,
                      size: 4.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Demo Credentials',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'Email: student@studyplus.com\nPassword: StudyPass123!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
