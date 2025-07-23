import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calendar_event.dart';
import '../services/supabase_service.dart';

class CalendarService {
  static final CalendarService _instance = CalendarService._internal();
  factory CalendarService() => _instance;
  CalendarService._internal();

  Future<SupabaseClient> get _client async => await SupabaseService().client;

  // Calendar Events CRUD Operations
  Future<List<CalendarEvent>> getCalendarEvents({
    DateTime? startDate,
    DateTime? endDate,
    List<CalendarEventType>? eventTypes,
    String? subjectId,
  }) async {
    try {
      final client = await _client;

      var query = client.from('calendar_events').select('''
            *,
            study_subjects!calendar_events_subject_id_fkey(
              id, name, color_code
            )
          ''').eq('user_id', client.auth.currentUser!.id);

      if (startDate != null) {
        query = query.gte('start_datetime', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('end_datetime', endDate.toIso8601String());
      }

      if (eventTypes != null && eventTypes.isNotEmpty) {
        final typeNames = eventTypes.map((e) => e.name).toList();
        query = query.inFilter('event_type', typeNames);
      }

      if (subjectId != null) {
        query = query.eq('subject_id', subjectId);
      }

      final response = await query.order('start_datetime', ascending: true);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch calendar events: $error');
    }
  }

  Future<CalendarEvent> createCalendarEvent(CalendarEvent event) async {
    try {
      final client = await _client;

      final eventData = event.toJson();
      eventData['user_id'] = client.auth.currentUser!.id;
      eventData.remove('id');
      eventData.remove('created_at');
      eventData.remove('updated_at');

      final response = await client
          .from('calendar_events')
          .insert(eventData)
          .select()
          .single();

      return CalendarEvent.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create calendar event: $error');
    }
  }

  Future<CalendarEvent> updateCalendarEvent(CalendarEvent event) async {
    try {
      final client = await _client;

      final eventData = event.toJson();
      eventData.remove('id');
      eventData.remove('user_id');
      eventData.remove('created_at');
      eventData['updated_at'] = DateTime.now().toIso8601String();

      final response = await client
          .from('calendar_events')
          .update(eventData)
          .eq('id', event.id)
          .select()
          .single();

      return CalendarEvent.fromJson(response);
    } catch (error) {
      throw Exception('Failed to update calendar event: $error');
    }
  }

  Future<void> deleteCalendarEvent(String eventId) async {
    try {
      final client = await _client;

      await client.from('calendar_events').delete().eq('id', eventId);
    } catch (error) {
      throw Exception('Failed to delete calendar event: $error');
    }
  }

  Future<void> toggleEventCompletion(String eventId, bool isCompleted) async {
    try {
      final client = await _client;

      await client.from('calendar_events').update({
        'is_completed': isCompleted,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', eventId);
    } catch (error) {
      throw Exception('Failed to toggle event completion: $error');
    }
  }

  // Assignment Calendar Operations
  Future<List<AssignmentCalendar>> getAssignments({
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    String? subjectId,
  }) async {
    try {
      final client = await _client;

      var query = client.from('assignment_calendar').select('''
            *,
            study_subjects!assignment_calendar_subject_id_fkey(
              id, name, color_code
            )
          ''').eq('user_id', client.auth.currentUser!.id);

      if (startDate != null) {
        query = query.gte('due_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('due_date', endDate.toIso8601String());
      }

      if (isCompleted != null) {
        query = query.eq('is_completed', isCompleted);
      }

      if (subjectId != null) {
        query = query.eq('subject_id', subjectId);
      }

      final response = await query.order('due_date', ascending: true);

      return response.map((json) => AssignmentCalendar.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch assignments: $error');
    }
  }

  Future<AssignmentCalendar> createAssignment(
      AssignmentCalendar assignment) async {
    try {
      final client = await _client;

      final assignmentData = assignment.toJson();
      assignmentData['user_id'] = client.auth.currentUser!.id;
      assignmentData.remove('id');
      assignmentData.remove('created_at');
      assignmentData.remove('updated_at');

      final response = await client
          .from('assignment_calendar')
          .insert(assignmentData)
          .select()
          .single();

      return AssignmentCalendar.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create assignment: $error');
    }
  }

  Future<void> completeAssignment(String assignmentId) async {
    try {
      final client = await _client;

      await client.from('assignment_calendar').update({
        'is_completed': true,
        'completion_date': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', assignmentId);
    } catch (error) {
      throw Exception('Failed to complete assignment: $error');
    }
  }

  // Calendar Statistics
  Future<Map<String, int>> getCalendarStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final client = await _client;

      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now().add(const Duration(days: 30));

      final response = await client.rpc('get_calendar_stats', params: {
        'user_uuid': client.auth.currentUser!.id,
        'start_date': start.toIso8601String().split('T')[0],
        'end_date': end.toIso8601String().split('T')[0],
      });

      if (response.isNotEmpty) {
        final stats = response[0];
        return {
          'total_events': stats['total_events'] ?? 0,
          'completed_events': stats['completed_events'] ?? 0,
          'pending_events': stats['pending_events'] ?? 0,
          'study_sessions': stats['study_sessions'] ?? 0,
          'assignments': stats['assignments'] ?? 0,
          'exams': stats['exams'] ?? 0,
        };
      }

      return {
        'total_events': 0,
        'completed_events': 0,
        'pending_events': 0,
        'study_sessions': 0,
        'assignments': 0,
        'exams': 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch calendar statistics: $error');
    }
  }

  // Get events for a specific date
  Future<List<CalendarEvent>> getEventsForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await getCalendarEvents(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  // Get upcoming events
  Future<List<CalendarEvent>> getUpcomingEvents({int limit = 10}) async {
    try {
      final client = await _client;

      final response = await client
          .from('calendar_events')
          .select('''
            *,
            study_subjects!calendar_events_subject_id_fkey(
              id, name, color_code
            )
          ''')
          .eq('user_id', client.auth.currentUser!.id)
          .eq('is_completed', false)
          .gte('start_datetime', DateTime.now().toIso8601String())
          .order('start_datetime', ascending: true)
          .limit(limit);

      return response.map((json) => CalendarEvent.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch upcoming events: $error');
    }
  }

  // Get overdue assignments
  Future<List<AssignmentCalendar>> getOverdueAssignments() async {
    try {
      final client = await _client;

      final response = await client
          .from('assignment_calendar')
          .select('''
            *,
            study_subjects!assignment_calendar_subject_id_fkey(
              id, name, color_code
            )
          ''')
          .eq('user_id', client.auth.currentUser!.id)
          .eq('is_completed', false)
          .lt('due_date', DateTime.now().toIso8601String())
          .order('due_date', ascending: true);

      return response.map((json) => AssignmentCalendar.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch overdue assignments: $error');
    }
  }

  // Real-time subscription for calendar events
  RealtimeChannel subscribeToCalendarEvents(
      Function(List<CalendarEvent>) onEventsUpdate) {
    return SupabaseService()
        .syncClient
        .channel('calendar_events_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'calendar_events',
          callback: (payload) async {
            // Refresh calendar events when changes occur
            try {
              final events = await getCalendarEvents();
              onEventsUpdate(events);
            } catch (error) {
              print('Error refreshing calendar events: $error');
            }
          },
        );
  }
}
