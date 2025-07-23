import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AssignmentService {
  static final AssignmentService _instance = AssignmentService._internal();
  factory AssignmentService() => _instance;
  AssignmentService._internal();

  Future<SupabaseClient> get _client async => await SupabaseService().client;

  // Get all assignments for current user
  Future<List<Map<String, dynamic>>> getAssignments() async {
    try {
      final client = await _client;
      final response = await client.from('assignments').select('''
            *,
            study_subjects(
              name,
              color_code,
              instructor
            )
          ''').order('due_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch assignments: $error');
    }
  }

  // Get assignments by status
  Future<List<Map<String, dynamic>>> getAssignmentsByStatus(
      String status) async {
    try {
      final client = await _client;
      final response = await client.from('assignments').select('''
            *,
            study_subjects(
              name,
              color_code,
              instructor
            )
          ''').eq('status', status).order('due_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch assignments by status: $error');
    }
  }

  // Get assignments by subject
  Future<List<Map<String, dynamic>>> getAssignmentsBySubject(
      String subjectId) async {
    try {
      final client = await _client;
      final response = await client.from('assignments').select('''
            *,
            study_subjects(
              name,
              color_code,
              instructor
            )
          ''').eq('subject_id', subjectId).order('due_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch assignments by subject: $error');
    }
  }

  // Get upcoming assignments
  Future<List<Map<String, dynamic>>> getUpcomingAssignments(
      {int daysAhead = 7}) async {
    try {
      final client = await _client;
      final response = await client
          .rpc('get_upcoming_assignments', params: {'days_ahead': daysAhead});
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch upcoming assignments: $error');
    }
  }

  // Get assignment by ID
  Future<Map<String, dynamic>?> getAssignmentById(String assignmentId) async {
    try {
      final client = await _client;
      final response = await client.from('assignments').select('''
            *,
            study_subjects(
              name,
              color_code,
              instructor
            ),
            assignment_attachments(
              id,
              file_name,
              file_url,
              file_type,
              file_size,
              uploaded_at
            )
          ''').eq('id', assignmentId).single();
      return response;
    } catch (error) {
      throw Exception('Failed to fetch assignment: $error');
    }
  }

  // Create new assignment
  Future<Map<String, dynamic>> createAssignment(
      Map<String, dynamic> assignmentData) async {
    try {
      final client = await _client;
      final response = await client
          .from('assignments')
          .insert(assignmentData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create assignment: $error');
    }
  }

  // Update assignment
  Future<Map<String, dynamic>> updateAssignment(
      String assignmentId, Map<String, dynamic> updates) async {
    try {
      final client = await _client;
      final response = await client
          .from('assignments')
          .update(updates)
          .eq('id', assignmentId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update assignment: $error');
    }
  }

  // Delete assignment
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      final client = await _client;
      await client.from('assignments').delete().eq('id', assignmentId);
    } catch (error) {
      throw Exception('Failed to delete assignment: $error');
    }
  }

  // Mark assignment as completed
  Future<Map<String, dynamic>> markAssignmentCompleted(
      String assignmentId) async {
    try {
      final client = await _client;
      final response = await client
          .from('assignments')
          .update({
            'status': 'completed',
            'completion_percentage': 100,
            'completed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', assignmentId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to mark assignment as completed: $error');
    }
  }

  // Update assignment progress
  Future<Map<String, dynamic>> updateAssignmentProgress(
      String assignmentId, int percentage) async {
    try {
      final client = await _client;
      final response = await client
          .from('assignments')
          .update({
            'completion_percentage': percentage,
            'status': percentage == 100 ? 'completed' : 'in_progress',
            'completed_at':
                percentage == 100 ? DateTime.now().toIso8601String() : null,
          })
          .eq('id', assignmentId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update assignment progress: $error');
    }
  }

  // Search assignments
  Future<List<Map<String, dynamic>>> searchAssignments(String query) async {
    try {
      final client = await _client;
      final response = await client.from('assignments').select('''
            *,
            study_subjects(
              name,
              color_code,
              instructor
            )
          ''').ilike('title', '%$query%').order('due_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search assignments: $error');
    }
  }

  // Get overdue assignments
  Future<List<Map<String, dynamic>>> getOverdueAssignments() async {
    try {
      final client = await _client;
      final response = await client.from('assignments').select('''
            *,
            study_subjects(
              name,
              color_code,
              instructor
            )
          ''').eq('status', 'overdue').order('due_date', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch overdue assignments: $error');
    }
  }

  // Add attachment to assignment
  Future<Map<String, dynamic>> addAttachment(
      String assignmentId, Map<String, dynamic> attachmentData) async {
    try {
      final client = await _client;
      final response = await client
          .from('assignment_attachments')
          .insert({
            'assignment_id': assignmentId,
            ...attachmentData,
          })
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to add attachment: $error');
    }
  }

  // Remove attachment from assignment
  Future<void> removeAttachment(String attachmentId) async {
    try {
      final client = await _client;
      await client
          .from('assignment_attachments')
          .delete()
          .eq('id', attachmentId);
    } catch (error) {
      throw Exception('Failed to remove attachment: $error');
    }
  }

  // Get assignment statistics
  Future<Map<String, dynamic>> getAssignmentStatistics() async {
    try {
      final client = await _client;
      final response = await client
          .from('assignments')
          .select('status, priority, completion_percentage');

      final stats = {
        'total': response.length,
        'completed': response.where((a) => a['status'] == 'completed').length,
        'pending': response.where((a) => a['status'] == 'pending').length,
        'in_progress':
            response.where((a) => a['status'] == 'in_progress').length,
        'overdue': response.where((a) => a['status'] == 'overdue').length,
        'high_priority': response
            .where((a) => a['priority'] == 'high' || a['priority'] == 'urgent')
            .length,
        'average_completion': response.isEmpty
            ? 0.0
            : response
                    .map((a) => a['completion_percentage'] as int)
                    .reduce((a, b) => a + b) /
                response.length,
      };

      return stats;
    } catch (error) {
      throw Exception('Failed to fetch assignment statistics: $error');
    }
  }
}
