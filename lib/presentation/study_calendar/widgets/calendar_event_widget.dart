import 'package:flutter/material.dart';
import '../../../models/calendar_event.dart';
import '../../../theme/app_theme.dart';

class CalendarEventWidget extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback onTap;
  final VoidCallback onToggleCompletion;

  const CalendarEventWidget({
    super.key,
    required this.event,
    required this.onTap,
    required this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Event color indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(
                        int.parse(event.colorCode.substring(1), radix: 16) +
                            0xFF000000),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                // Event content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and completion status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: event.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ),
                          _buildEventTypeChip(context, event.eventType),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Time and duration
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')} - ${event.endDateTime.hour.toString().padLeft(2, '0')}:${event.endDateTime.minute.toString().padLeft(2, '0')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '(${event.duration.inMinutes} min)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Priority and status
                      Row(
                        children: [
                          _buildPriorityChip(context, event.priority),
                          const SizedBox(width: 8),
                          if (event.isOverdue && !event.isCompleted)
                            _buildStatusChip(
                              context,
                              'Overdue',
                              AppTheme.getErrorColor(isLight),
                              Icons.warning,
                            )
                          else if (event.isCompleted)
                            _buildStatusChip(
                              context,
                              'Completed',
                              AppTheme.getSuccessColor(isLight),
                              Icons.check_circle,
                            )
                          else if (event.isToday)
                            _buildStatusChip(
                              context,
                              'Today',
                              AppTheme.getWarningColor(isLight),
                              Icons.today,
                            )
                          else if (event.isUpcoming)
                            _buildStatusChip(
                              context,
                              'Upcoming',
                              colorScheme.primary,
                              Icons.upcoming,
                            ),
                        ],
                      ),
                      if (event.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text(
                          event.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Completion toggle button
                IconButton(
                  icon: Icon(
                    event.isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: event.isCompleted
                        ? AppTheme.getSuccessColor(isLight)
                        : colorScheme.onSurfaceVariant,
                  ),
                  onPressed: onToggleCompletion,
                  tooltip: event.isCompleted
                      ? 'Mark as incomplete'
                      : 'Mark as complete',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventTypeChip(
      BuildContext context, CalendarEventType eventType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color chipColor;
    IconData chipIcon;

    switch (eventType) {
      case CalendarEventType.studySession:
        chipColor = colorScheme.primary;
        chipIcon = Icons.school;
        break;
      case CalendarEventType.assignment:
        chipColor =
            AppTheme.getWarningColor(theme.brightness == Brightness.light);
        chipIcon = Icons.assignment;
        break;
      case CalendarEventType.exam:
        chipColor =
            AppTheme.getErrorColor(theme.brightness == Brightness.light);
        chipIcon = Icons.quiz;
        break;
      case CalendarEventType.break_:
        chipColor =
            AppTheme.getSuccessColor(theme.brightness == Brightness.light);
        chipIcon = Icons.coffee;
        break;
      case CalendarEventType.reminder:
        chipColor = colorScheme.secondary;
        chipIcon = Icons.notifications;
        break;
      case CalendarEventType.deadline:
        chipColor =
            AppTheme.getErrorColor(theme.brightness == Brightness.light);
        chipIcon = Icons.alarm;
        break;
      default:
        chipColor = colorScheme.onSurfaceVariant;
        chipIcon = Icons.event;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chipIcon,
            size: 12,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            eventType.name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context, EventPriority priority) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    Color chipColor;
    IconData chipIcon;

    switch (priority) {
      case EventPriority.urgent:
        chipColor = AppTheme.getErrorColor(isLight);
        chipIcon = Icons.priority_high;
        break;
      case EventPriority.high:
        chipColor = AppTheme.getWarningColor(isLight);
        chipIcon = Icons.arrow_upward;
        break;
      case EventPriority.medium:
        chipColor = theme.colorScheme.primary;
        chipIcon = Icons.remove;
        break;
      case EventPriority.low:
        chipColor = AppTheme.getSuccessColor(isLight);
        chipIcon = Icons.arrow_downward;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            chipIcon,
            size: 10,
            color: chipColor,
          ),
          const SizedBox(width: 2),
          Text(
            priority.name,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
