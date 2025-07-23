import 'package:flutter/material.dart';
import '../../../models/calendar_event.dart';
import '../../../theme/app_theme.dart';

class WeekViewWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Map<DateTime, List<CalendarEvent>> events;
  final Function(DateTime, DateTime) onDateSelected;
  final Function(CalendarEvent) onEventTap;

  const WeekViewWidget({
    super.key,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.onEventTap,
  });

  @override
  State<WeekViewWidget> createState() => _WeekViewWidgetState();
}

class _WeekViewWidgetState extends State<WeekViewWidget> {
  late DateTime _currentWeekStart;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getWeekStart(widget.selectedDate);
    _scrollController = ScrollController();

    // Scroll to current time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  void _scrollToCurrentTime() {
    final now = DateTime.now();
    final currentHour = now.hour;
    final targetOffset = currentHour * 60.0; // 60 pixels per hour

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekHeader(),
        Expanded(
          child: _buildWeekGrid(),
        ),
      ],
    );
  }

  Widget _buildWeekHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
        children: [
          // Week navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() {
                    _currentWeekStart =
                        _currentWeekStart.subtract(const Duration(days: 7));
                  });
                },
              ),
              Text(
                _formatWeekRange(_currentWeekStart),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() {
                    _currentWeekStart =
                        _currentWeekStart.add(const Duration(days: 7));
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Day headers
          Row(
            children: [
              // Time column header
              SizedBox(
                width: 60,
                child: Text(
                  'Time',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Day headers
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: _buildDayHeader(i),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(int dayOffset) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final date = _currentWeekStart.add(Duration(days: dayOffset));
    final isToday = _isToday(date);
    final isSelected = _isSameDay(date, widget.selectedDate);

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GestureDetector(
      onTap: () => widget.onDateSelected(date, date),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withAlpha(26)
              : isToday
                  ? colorScheme.primaryContainer.withAlpha(128)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              weekdays[dayOffset],
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected || isToday
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : isToday
                        ? colorScheme.primary.withAlpha(179)
                        : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${date.day}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected || isToday
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekGrid() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            for (int hour = 0; hour < 24; hour++) _buildHourRow(hour),
          ],
        ),
      ),
    );
  }

  Widget _buildHourRow(int hour) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCurrentHour = DateTime.now().hour == hour;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: isCurrentHour
            ? colorScheme.primary.withAlpha(13)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withAlpha(26),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Time label
          SizedBox(
            width: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.topRight,
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isCurrentHour
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isCurrentHour ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
          // Day columns
          for (int day = 0; day < 7; day++)
            Expanded(
              child: _buildDayColumn(hour, day),
            ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(int hour, int dayOffset) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final date = _currentWeekStart.add(Duration(days: dayOffset));
    final dayEvents =
        widget.events[DateTime(date.year, date.month, date.day)] ?? [];
    final hourEvents =
        dayEvents.where((e) => e.startDateTime.hour == hour).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withAlpha(26),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: hourEvents.map((event) => _buildEventBlock(event)).toList(),
      ),
    );
  }

  Widget _buildEventBlock(CalendarEvent event) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final eventColor =
        Color(int.parse(event.colorCode.substring(1), radix: 16) + 0xFF000000);

    return GestureDetector(
      onTap: () => widget.onEventTap(event),
      child: Container(
        width: double.infinity,
        height: 56,
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: eventColor.withAlpha(26),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: eventColor,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              event.title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: eventColor,
                decoration:
                    event.isCompleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${event.startDateTime.hour.toString().padLeft(2, '0')}:${event.startDateTime.minute.toString().padLeft(2, '0')}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: eventColor,
                fontSize: 10,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildEventTypeIcon(event.eventType),
                if (event.isCompleted)
                  Icon(
                    Icons.check_circle,
                    size: 12,
                    color: AppTheme.getSuccessColor(
                        theme.brightness == Brightness.light),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTypeIcon(CalendarEventType eventType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    IconData icon;
    switch (eventType) {
      case CalendarEventType.studySession:
        icon = Icons.school;
        break;
      case CalendarEventType.assignment:
        icon = Icons.assignment;
        break;
      case CalendarEventType.exam:
        icon = Icons.quiz;
        break;
      case CalendarEventType.break_:
        icon = Icons.coffee;
        break;
      case CalendarEventType.reminder:
        icon = Icons.notifications;
        break;
      case CalendarEventType.deadline:
        icon = Icons.alarm;
        break;
      default:
        icon = Icons.event;
    }

    return Icon(
      icon,
      size: 12,
      color: colorScheme.onSurfaceVariant,
    );
  }

  String _formatWeekRange(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 6));
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

    if (weekStart.month == weekEnd.month) {
      return '${months[weekStart.month - 1]} ${weekStart.day} - ${weekEnd.day}, ${weekStart.year}';
    } else {
      return '${months[weekStart.month - 1]} ${weekStart.day} - ${months[weekEnd.month - 1]} ${weekEnd.day}, ${weekStart.year}';
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
