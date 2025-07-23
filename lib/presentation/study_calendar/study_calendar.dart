import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/calendar_event.dart';
import '../../services/calendar_service.dart';
import './widgets/calendar_event_widget.dart';
import './widgets/calendar_header_widget.dart';
import './widgets/day_view_widget.dart';
import './widgets/event_creation_modal_widget.dart';
import './widgets/week_view_widget.dart';

class StudyCalendar extends StatefulWidget {
  const StudyCalendar({super.key});

  @override
  State<StudyCalendar> createState() => _StudyCalendarState();
}

class _StudyCalendarState extends State<StudyCalendar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CalendarService _calendarService = CalendarService();

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  Map<DateTime, List<CalendarEvent>> _events = {};
  List<CalendarEvent> _selectedEvents = [];
  List<CalendarEvent> _todayEvents = [];
  List<AssignmentCalendar> _assignments = [];

  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCalendarData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCalendarData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final events = await _calendarService.getCalendarEvents(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      final assignments = await _calendarService.getAssignments(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      final todayEvents =
          await _calendarService.getEventsForDate(DateTime.now());

      setState(() {
        _events = _groupEventsByDate(events);
        _selectedEvents = _events[_selectedDay] ?? [];
        _todayEvents = todayEvents;
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Map<DateTime, List<CalendarEvent>> _groupEventsByDate(
      List<CalendarEvent> events) {
    final Map<DateTime, List<CalendarEvent>> grouped = {};

    for (final event in events) {
      final date = DateTime(
        event.startDateTime.year,
        event.startDateTime.month,
        event.startDateTime.day,
      );

      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(event);
    }

    return grouped;
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents = _getEventsForDay(selectedDay);
      });
    }
  }

  void _onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      setState(() {
        _calendarFormat = format;
      });
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    _loadCalendarData();
  }

  void _showEventCreationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventCreationModalWidget(
        selectedDate: _selectedDay,
        onEventCreated: (event) {
          _loadCalendarData();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _goToToday() {
    setState(() {
      _selectedDay = DateTime.now();
      _focusedDay = DateTime.now();
      _selectedEvents = _getEventsForDay(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Study Calendar',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: _goToToday,
            tooltip: 'Go to Today',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showEventCreationModal,
            tooltip: 'Add Event',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Month', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Week', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'Day', icon: Icon(Icons.calendar_today)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: colorScheme.error,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error loading calendar',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _error,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadCalendarData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMonthView(),
                    WeekViewWidget(
                      selectedDate: _selectedDay,
                      events: _events,
                      onDateSelected: _onDaySelected,
                      onEventTap: _onEventTap,
                    ),
                    DayViewWidget(
                      selectedDate: _selectedDay,
                      events: _selectedEvents,
                      assignments:
                          _assignments.where((a) => a.isDueToday).toList(),
                      onEventTap: _onEventTap,
                      onAssignmentTap: _onAssignmentTap,
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEventCreationModal,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthView() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          CalendarHeaderWidget(
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: _onFormatChanged,
            todayEvents: _todayEvents,
          ),
          Card(
            margin: const EdgeInsets.all(16),
            child: TableCalendar<CalendarEvent>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: _onDaySelected,
              onFormatChanged: _onFormatChanged,
              onPageChanged: _onPageChanged,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                weekendTextStyle:
                    TextStyle(color: colorScheme.onSurfaceVariant),
                holidayTextStyle: TextStyle(color: colorScheme.error),
                selectedDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(179),
                  shape: BoxShape.circle,
                ),
                defaultDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                weekendDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                markerSize: 8.0,
                markerMargin: const EdgeInsets.symmetric(horizontal: 1.0),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                formatButtonShowsNext: false,
                formatButtonDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                formatButtonTextStyle: TextStyle(
                  color: colorScheme.onPrimary,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: colorScheme.onSurface,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurface,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: colorScheme.onSurface),
                weekendStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          if (_selectedEvents.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events for ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._selectedEvents.map((event) => CalendarEventWidget(
                        event: event,
                        onTap: () => _onEventTap(event),
                        onToggleCompletion: () => _toggleEventCompletion(event),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _onEventTap(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => _buildEventDetailsDialog(event),
    );
  }

  void _onAssignmentTap(AssignmentCalendar assignment) {
    showDialog(
      context: context,
      builder: (context) => _buildAssignmentDetailsDialog(assignment),
    );
  }

  Widget _buildEventDetailsDialog(CalendarEvent event) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(event.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.description?.isNotEmpty == true) ...[
            Text(
              'Description',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(event.description!),
            const SizedBox(height: 12),
          ],
          Text(
            'Type',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(event.eventType.name),
          const SizedBox(height: 12),
          Text(
            'Time',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')} - ${event.endDateTime.hour.toString().padLeft(2, '0')}:${event.endDateTime.minute.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 12),
          Text(
            'Priority',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(event.priority.name),
          const SizedBox(height: 12),
          Text(
            'Status',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(event.isCompleted ? 'Completed' : 'Pending'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (!event.isCompleted)
          ElevatedButton(
            onPressed: () {
              _toggleEventCompletion(event);
              Navigator.pop(context);
            },
            child: const Text('Mark Complete'),
          ),
      ],
    );
  }

  Widget _buildAssignmentDetailsDialog(AssignmentCalendar assignment) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(assignment.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (assignment.notes?.isNotEmpty == true) ...[
            Text(
              'Notes',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(assignment.notes!),
            const SizedBox(height: 12),
          ],
          Text(
            'Due Date',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${assignment.dueDate.day}/${assignment.dueDate.month}/${assignment.dueDate.year} at ${assignment.dueDate.hour.toString().padLeft(2, '0')}:${assignment.dueDate.minute.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 12),
          Text(
            'Estimated Duration',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text('${assignment.estimatedDurationMinutes} minutes'),
          const SizedBox(height: 12),
          Text(
            'Priority',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(assignment.priority.name),
          const SizedBox(height: 12),
          Text(
            'Status',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(assignment.isCompleted ? 'Completed' : 'Pending'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (!assignment.isCompleted)
          ElevatedButton(
            onPressed: () {
              _completeAssignment(assignment);
              Navigator.pop(context);
            },
            child: const Text('Mark Complete'),
          ),
      ],
    );
  }

  Future<void> _toggleEventCompletion(CalendarEvent event) async {
    try {
      await _calendarService.toggleEventCompletion(
          event.id, !event.isCompleted);
      _loadCalendarData();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update event: $error')),
      );
    }
  }

  Future<void> _completeAssignment(AssignmentCalendar assignment) async {
    try {
      await _calendarService.completeAssignment(assignment.id);
      _loadCalendarData();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete assignment: $error')),
      );
    }
  }
}
