import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class SubjectService {
  static final SubjectService _instance = SubjectService._internal();
  factory SubjectService() => _instance;
  SubjectService._internal();

  Future<SupabaseClient> get _client async => await SupabaseService().client;

  // Get all subjects for current user
  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final client = await _client;
      final response = await client
          .from('study_subjects')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch subjects: $error');
    }
  }

  // Get subject by ID with statistics
  Future<Map<String, dynamic>?> getSubjectById(String subjectId) async {
    try {
      final client = await _client;
      final response = await client
          .from('study_subjects')
          .select('*')
          .eq('id', subjectId)
          .single();

      // Get subject statistics
      final stats = await getSubjectStats(subjectId);
      response['stats'] = stats;

      return response;
    } catch (error) {
      throw Exception('Failed to fetch subject: $error');
    }
  }

  // Get subject statistics
  Future<Map<String, dynamic>> getSubjectStats(String subjectId) async {
    try {
      final client = await _client;
      final response = await client
          .rpc('get_subject_stats', params: {'subject_uuid': subjectId});

      if (response.isNotEmpty) {
        return Map<String, dynamic>.from(response.first);
      }
      return {
        'total_assignments': 0,
        'completed_assignments': 0,
        'pending_assignments': 0,
        'overdue_assignments': 0,
        'completion_rate': 0.0,
        'average_grade': 0.0,
      };
    } catch (error) {
      throw Exception('Failed to fetch subject stats: $error');
    }
  }

  // Create new subject
  Future<Map<String, dynamic>> createSubject(
      Map<String, dynamic> subjectData) async {
    try {
      final client = await _client;
      final response = await client
          .from('study_subjects')
          .insert(subjectData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create subject: $error');
    }
  }

  // Update subject
  Future<Map<String, dynamic>> updateSubject(
      String subjectId, Map<String, dynamic> updates) async {
    try {
      final client = await _client;
      final response = await client
          .from('study_subjects')
          .update(updates)
          .eq('id', subjectId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update subject: $error');
    }
  }

  // Archive subject (soft delete)
  Future<void> archiveSubject(String subjectId) async {
    try {
      final client = await _client;
      await client
          .from('study_subjects')
          .update({'status': 'archived'}).eq('id', subjectId);
    } catch (error) {
      throw Exception('Failed to archive subject: $error');
    }
  }

  // Delete subject permanently
  Future<void> deleteSubject(String subjectId) async {
    try {
      final client = await _client;
      await client.from('study_subjects').delete().eq('id', subjectId);
    } catch (error) {
      throw Exception('Failed to delete subject: $error');
    }
  }

  // Get subjects with progress
  Future<List<Map<String, dynamic>>> getSubjectsWithProgress() async {
    try {
      final client = await _client;
      final response = await client.from('study_subjects').select('''
            *,
            subject_progress(
              total_assignments,
              completed_assignments,
              average_grade,
              total_study_time_minutes,
              last_activity
            )
          ''').eq('is_active', true).order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch subjects with progress: $error');
    }
  }

  // Search subjects
  Future<List<Map<String, dynamic>>> searchSubjects(String query) async {
    try {
      final client = await _client;
      final response = await client
          .from('study_subjects')
          .select('*')
          .ilike('name', '%$query%')
          .eq('is_active', true)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search subjects: $error');
    }
  }

  // Get subjects by semester
  Future<List<Map<String, dynamic>>> getSubjectsBySemester(
      String semester) async {
    try {
      final client = await _client;
      final response = await client
          .from('study_subjects')
          .select('*')
          .eq('semester', semester)
          .eq('is_active', true)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch subjects by semester: $error');
    }
  }

  // Get all unique semesters
  Future<List<String>> getSemesters() async {
    try {
      final client = await _client;
      final response = await client
          .from('study_subjects')
          .select('semester')
          .not('semester', 'is', null)
          .eq('is_active', true);

      final semesters =
          response.map((item) => item['semester'] as String).toSet().toList();
      semesters.sort();
      return semesters;
    } catch (error) {
      throw Exception('Failed to fetch semesters: $error');
    }
  }
}
