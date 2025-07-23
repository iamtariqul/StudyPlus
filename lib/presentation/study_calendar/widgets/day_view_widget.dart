import 'package:flutter/material.dart';
import '../../../models/calendar_event.dart';
import '../../../theme/app_theme.dart';

class DayViewWidget extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEvent> events;
  final List<AssignmentCalendar> assignments;
  final Function(CalendarEvent) onEventTap;
  final Function(AssignmentCalendar) onAssignmentTap;

  const DayViewWidget({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.assignments,
    required this.onEventTap,
    required this.onAssignmentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Day header
          _buildDayHeader(context),
          const SizedBox(height: 16),
          // Hourly schedule
          _buildHourlySchedule(context),
          const SizedBox(height: 16),
          // Assignments due today
          if (assignments.isNotEmpty) ...[
            _buildAssignmentsSection(context),
            const SizedBox(height: 16),
          ],
          // Summary statistics
          _buildDaySummary(context),
        ],
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isToday = _isToday(selectedDate);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isToday
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            _formatDayHeader(selectedDate),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isToday
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                context,
                events.length.toString(),
                'Events',
                colorScheme.primary,
              ),
              _buildStatItem(
                context,
                events.where((e) => e.isCompleted).length.toString(),
                'Completed',
                AppTheme.getSuccessColor(theme.brightness == Brightness.light),
              ),
              _buildStatItem(
                context,
                assignments.length.toString(),
                'Assignments',
                AppTheme.getWarningColor(theme.brightness == Brightness.light),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String value, String label, Color color) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlySchedule(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 600,
            child: ListView.builder(
              itemCount: 24,
              itemBuilder: (context, index) {
                final hour = index;
                final hourEvents =
                    events.where((e) => e.startDateTime.hour == hour).toList();

                return _buildHourSlot(context, hour, hourEvents);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourSlot(
      BuildContext context, int hour, List<CalendarEvent> hourEvents) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 60,
      child: Row(
        children: [
          // Time label
          SizedBox(
            width: 60,
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Divider
          Container(
            width: 1,
            height: 60,
            color: colorScheme.outline.withAlpha(77),
          ),
          const SizedBox(width: 12),
          // Events
          Expanded(
            child: hourEvents.isEmpty
                ? Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outline.withAlpha(26),
                          width: 1,
                        ),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: hourEvents
                        .map((event) => _buildHourEvent(context, event))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourEvent(BuildContext context, CalendarEvent event) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => onEventTap(event),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(int.parse(event.colorCode.substring(1), radix: 16) +
                    0xFF000000)
                .withAlpha(26),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(int.parse(event.colorCode.substring(1), radix: 16) +
                  0xFF000000),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: Color(
                      int.parse(event.colorCode.substring(1), radix: 16) +
                          0xFF000000),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: event.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')} - ${event.endDateTime.hour.toString().padLeft(2, '0')}:${event.endDateTime.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                event.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: event.isCompleted
                    ? AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light)
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentsSection(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assignments Due Today',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...assignments
              .map((assignment) => _buildAssignmentItem(context, assignment)),
        ],
      ),
    );
  }

  Widget _buildAssignmentItem(
      BuildContext context, AssignmentCalendar assignment) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outline.withAlpha(26),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => onAssignmentTap(assignment),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(assignment.priority, isLight),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: assignment.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Due: ${assignment.dueDate.hour.toString().padLeft(2, '0')}:${assignment.dueDate.minute.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${assignment.estimatedDurationMinutes} min',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  assignment.isCompleted
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: assignment.isCompleted
                      ? AppTheme.getSuccessColor(isLight)
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySummary(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    final totalEvents = events.length;
    final completedEvents = events.where((e) => e.isCompleted).length;
    final totalStudyTime = events
        .where((e) => e.eventType == CalendarEventType.studySession)
        .fold(0, (sum, e) => sum + e.duration.inMinutes);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Day Summary',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryItem(
                context,
                'Total Events',
                totalEvents.toString(),
                colorScheme.primary,
              ),
              _buildSummaryItem(
                context,
                'Completed',
                completedEvents.toString(),
                AppTheme.getSuccessColor(isLight),
              ),
              _buildSummaryItem(
                context,
                'Study Time',
                '${totalStudyTime}m',
                AppTheme.getWarningColor(isLight),
              ),
            ],
          ),
          if (totalEvents > 0) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: completedEvents / totalEvents,
              backgroundColor: colorScheme.outline.withAlpha(51),
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.getSuccessColor(isLight),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${((completedEvents / totalEvents) * 100).toInt()}% completed',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
      BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _formatDayHeader(DateTime date) {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  Color _getPriorityColor(EventPriority priority, bool isLight) {
    switch (priority) {
      case EventPriority.urgent:
        return AppTheme.getErrorColor(isLight);
      case EventPriority.high:
        return AppTheme.getWarningColor(isLight);
      case EventPriority.medium:
        return Colors.blue;
      case EventPriority.low:
        return AppTheme.getSuccessColor(isLight);
    }
  }
}
