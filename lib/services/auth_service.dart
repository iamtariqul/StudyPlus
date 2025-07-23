import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  late final SupabaseClient _client;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<void> initialize() async {
    _client = await SupabaseService().client;
  }

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get current session
  Session? get currentSession => _client.auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? gradeLevel,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'grade_level': gradeLevel ?? 'high_school',
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Update user password
  Future<UserResponse> updatePassword({required String newPassword}) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (error) {
      throw Exception('Password update failed: $error');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    String? fullName,
    String? gradeLevel,
    String? bio,
    String? profileImageUrl,
    List<String>? studyGoals,
    String? timezone,
  }) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (gradeLevel != null) updateData['grade_level'] = gradeLevel;
      if (bio != null) updateData['bio'] = bio;
      if (profileImageUrl != null)
        updateData['profile_image_url'] = profileImageUrl;
      if (studyGoals != null) updateData['study_goals'] = studyGoals;
      if (timezone != null) updateData['timezone'] = timezone;

      final response = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('id', currentUser!.id)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  // Update last login timestamp
  Future<void> updateLastLogin() async {
    try {
      if (!isAuthenticated) return;

      await _client.from('user_profiles').update({
        'last_login': DateTime.now().toIso8601String(),
      }).eq('id', currentUser!.id);
    } catch (error) {
      // Silent fail for last login update
      print('Failed to update last login: $error');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Check if email is verified
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  // Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }

      await _client.auth.resend(
        type: OtpType.signup,
        email: currentUser!.email!,
      );
    } catch (error) {
      throw Exception('Failed to resend verification email: $error');
    }
  }
}
