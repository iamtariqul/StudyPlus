import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TermsCheckboxWidget extends StatelessWidget {
  final bool termsAccepted;
  final bool privacyAccepted;
  final bool coppaCompliant;
  final Function(bool) onTermsChanged;
  final Function(bool) onPrivacyChanged;
  final Function(bool) onCoppaChanged;

  const TermsCheckboxWidget({
    super.key,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.coppaCompliant,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    required this.onCoppaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'gavel',
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Legal Agreements',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildCheckboxItem(
            value: termsAccepted,
            onChanged: onTermsChanged,
            title: 'Terms of Service',
            description:
                'I agree to the Terms of Service and understand my rights and responsibilities.',
            onLinkTap: () => _showTermsDialog(context),
          ),
          SizedBox(height: 2.h),
          _buildCheckboxItem(
            value: privacyAccepted,
            onChanged: onPrivacyChanged,
            title: 'Privacy Policy',
            description:
                'I agree to the Privacy Policy and understand how my data will be used.',
            onLinkTap: () => _showPrivacyDialog(context),
          ),
          SizedBox(height: 2.h),
          _buildCheckboxItem(
            value: coppaCompliant,
            onChanged: onCoppaChanged,
            title: 'Age Verification',
            description:
                'I confirm that I am 13 years of age or older, or have parental consent.',
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem({
    required bool value,
    required Function(bool) onChanged,
    required String title,
    required String description,
    VoidCallback? onLinkTap,
    bool isRequired = false,
  }) {
    return Builder(
      builder: (context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 20,
              height: 20,
              margin: EdgeInsets.only(top: 0.5.h),
              decoration: BoxDecoration(
                color: value
                    ? AppTheme.lightTheme.colorScheme.primary
                    : Colors.transparent,
                border: Border.all(
                  color: value
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: value
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onLinkTap,
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: onLinkTap != null
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                                decoration: onLinkTap != null
                                    ? TextDecoration.underline
                                    : null,
                              ),
                        ),
                      ),
                    ),
                    if (isRequired)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.getErrorColor(true)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Required',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.getErrorColor(true),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'gavel',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Terms of Service'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 50.h,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StudyPlus Terms of Service',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '1. Acceptance of Terms\n\nBy creating an account with StudyPlus, you agree to be bound by these Terms of Service and all applicable laws and regulations.\n\n2. Educational Use\n\nStudyPlus is designed for educational purposes. Users must use the platform responsibly and in accordance with their educational institution\'s policies.\n\n3. Account Responsibility\n\nYou are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.\n\n4. Data Usage\n\nWe collect and use your data to provide and improve our educational services. Your study data helps us create better learning experiences.\n\n5. Prohibited Activities\n\nUsers may not use StudyPlus for any unlawful purposes or in any way that could damage, disable, or impair the service.\n\n6. Termination\n\nWe reserve the right to terminate accounts that violate these terms or engage in harmful activities.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'privacy_tip',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Privacy Policy'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 50.h,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'StudyPlus Privacy Policy',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Information We Collect\n\nWe collect information you provide directly to us, such as when you create an account, use our services, or contact us for support.\n\nHow We Use Your Information\n\n• To provide and maintain our educational services\n• To improve and personalize your learning experience\n• To communicate with you about your account and our services\n• To analyze usage patterns and improve our platform\n\nData Security\n\nWe implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.\n\nData Sharing\n\nWe do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.\n\nYour Rights\n\nYou have the right to access, update, or delete your personal information. You can do this through your account settings or by contacting us.\n\nContact Us\n\nIf you have questions about this Privacy Policy, please contact us at privacy@studyplus.edu.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
