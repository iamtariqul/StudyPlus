import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/calendar_event.dart';
import '../../../theme/app_theme.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final Function(CalendarFormat) onFormatChanged;
  final List<CalendarEvent> todayEvents;

  const CalendarHeaderWidget({
    super.key,
    required this.focusedDay,
    required this.calendarFormat,
    required this.onFormatChanged,
    required this.todayEvents,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withAlpha(26),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calendar format selector
          Row(
            children: [
              Text(
                'View:',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              _buildFormatButton(
                context,
                'Month',
                CalendarFormat.month,
                calendarFormat == CalendarFormat.month,
              ),
              const SizedBox(width: 8),
              _buildFormatButton(
                context,
                'Week',
                CalendarFormat.twoWeeks,
                calendarFormat == CalendarFormat.twoWeeks,
              ),
              const Spacer(),
              _buildQuickStatsWidget(context),
            ],
          ),
          const SizedBox(height: 16),
          // Today's events preview
          if (todayEvents.isNotEmpty) ...[
            Text(
              'Today\'s Events',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: todayEvents.length,
                itemBuilder: (context, index) {
                  final event = todayEvents[index];
                  return _buildTodayEventCard(context, event);
                },
              ),
            ),
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: AppTheme.getSuccessColor(isLight),
                ),
                const SizedBox(width: 8),
                Text(
                  'No events today',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.getSuccessColor(isLight),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormatButton(
    BuildContext context,
    String label,
    CalendarFormat format,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => onFormatChanged(format),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(color: colorScheme.outline.withAlpha(128)),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsWidget(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final completedCount = todayEvents.where((e) => e.isCompleted).length;
    final pendingCount = todayEvents.where((e) => !e.isCompleted).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatItem(
            context,
            completedCount.toString(),
            'Done',
            AppTheme.getSuccessColor(theme.brightness == Brightness.light),
          ),
          const SizedBox(width: 12),
          Container(
            width: 1,
            height: 20,
            color: colorScheme.outline.withAlpha(77),
          ),
          const SizedBox(width: 12),
          _buildStatItem(
            context,
            pendingCount.toString(),
            'Pending',
            AppTheme.getWarningColor(theme.brightness == Brightness.light),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String count,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: theme.textTheme.labelLarge?.copyWith(
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

  Widget _buildTodayEventCard(BuildContext context, CalendarEvent event) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Color(int.parse(event.colorCode.substring(1), radix: 16) +
                0xFF000000),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(
                          int.parse(event.colorCode.substring(1), radix: 16) +
                              0xFF000000),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      event.title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    event.isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 12,
                    color: event.isCompleted
                        ? AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light)
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    event.isCompleted ? 'Done' : 'Pending',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: event.isCompleted
                          ? AppTheme.getSuccessColor(
                              theme.brightness == Brightness.light)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
