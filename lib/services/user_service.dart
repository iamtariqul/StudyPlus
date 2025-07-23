import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  late final SupabaseClient _client;

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  Future<void> initialize() async {
    _client = await SupabaseService().client;
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch current user profile: $error');
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  // Get all users (admin only)
  Future<List<Map<String, dynamic>>> getAllUsers({
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _client
          .from('user_profiles')
          .select()
          .order('created_at', ascending: false);

      if (limit != null) {
        if (offset != null) {
          query = query.range(offset, offset + limit - 1);
        } else {
          query = query.limit(limit);
        }
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch users: $error');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? fullName,
    String? gradeLevel,
    String? bio,
    String? profileImageUrl,
    List<String>? studyGoals,
    String? timezone,
    String? accountStatus,
  }) async {
    try {
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
      if (accountStatus != null) updateData['account_status'] = accountStatus;

      final response = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  // Delete user profile (admin only)
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _client.from('user_profiles').delete().eq('id', userId);
    } catch (error) {
      throw Exception('Failed to delete user profile: $error');
    }
  }

  // Search users by name or email
  Future<List<Map<String, dynamic>>> searchUsers({
    required String query,
    int? limit,
  }) async {
    try {
      var searchQuery = _client
          .from('user_profiles')
          .select()
          .or('full_name.ilike.%$query%,email.ilike.%$query%')
          .order('full_name', ascending: true);

      if (limit != null) {
        searchQuery = searchQuery.limit(limit);
      }

      final response = await searchQuery;
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search users: $error');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final results = await Future.wait([
        // Total study sessions
        _client.from('study_sessions').select('*').eq('user_id', userId),

        // Completed study sessions
        _client
            .from('study_sessions')
            .select('*')
            .eq('user_id', userId)
            .eq('is_completed', true),

        // Total study subjects
        _client
            .from('study_subjects')
            .select('*')
            .eq('user_id', userId)
            .eq('is_active', true),
      ]);

      final totalSessions = results[0].length;
      final completedSessions = results[1].length;
      final totalSubjects = results[2].length;

      return {
        'total_sessions': totalSessions,
        'completed_sessions': completedSessions,
        'total_subjects': totalSubjects,
        'completion_rate': totalSessions > 0
            ? (completedSessions / totalSessions * 100).round()
            : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to fetch user statistics: $error');
    }
  }

  // Get recent study activity
  Future<List<Map<String, dynamic>>> getRecentActivity({
    String? userId,
    int limit = 10,
  }) async {
    try {
      final targetUserId = userId ?? AuthService().currentUser?.id;
      if (targetUserId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _client
          .from('study_sessions')
          .select()
          .eq('user_id', targetUserId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch recent activity: $error');
    }
  }

  // Update user's email verification status
  Future<void> updateEmailVerificationStatus({
    required String userId,
    required bool isVerified,
  }) async {
    try {
      await _client.from('user_profiles').update({
        'email_verified': isVerified,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (error) {
      throw Exception('Failed to update email verification status: $error');
    }
  }
}
