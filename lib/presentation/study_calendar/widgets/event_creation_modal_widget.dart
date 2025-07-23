import 'package:flutter/material.dart';
import '../../../models/calendar_event.dart';
import '../../../services/calendar_service.dart';
import '../../../theme/app_theme.dart';

class EventCreationModalWidget extends StatefulWidget {
  final DateTime selectedDate;
  final Function(CalendarEvent) onEventCreated;
  final CalendarEvent? existingEvent;

  const EventCreationModalWidget({
    super.key,
    required this.selectedDate,
    required this.onEventCreated,
    this.existingEvent,
  });

  @override
  State<EventCreationModalWidget> createState() =>
      _EventCreationModalWidgetState();
}

class _EventCreationModalWidgetState extends State<EventCreationModalWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final CalendarService _calendarService = CalendarService();

  CalendarEventType _selectedEventType = CalendarEventType.studySession;
  EventPriority _selectedPriority = EventPriority.medium;
  RecurrenceType _selectedRecurrence = RecurrenceType.none;

  DateTime _startDateTime = DateTime.now();
  DateTime _endDateTime = DateTime.now().add(const Duration(hours: 1));
  bool _isAllDay = false;
  String _colorCode = '#2196F3';
  int _reminderMinutes = 30;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeDateTime();
    _loadExistingEvent();
  }

  void _initializeDateTime() {
    final selectedDate = widget.selectedDate;
    final now = DateTime.now();

    _startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
    );

    _endDateTime = _startDateTime.add(const Duration(hours: 1));
  }

  void _loadExistingEvent() {
    if (widget.existingEvent != null) {
      final event = widget.existingEvent!;
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _locationController.text = event.location ?? '';
      _selectedEventType = event.eventType;
      _selectedPriority = event.priority;
      _selectedRecurrence = event.recurrenceType;
      _startDateTime = event.startDateTime;
      _endDateTime = event.endDateTime;
      _isAllDay = event.isAllDay;
      _colorCode = event.colorCode;
      _reminderMinutes = event.reminderMinutes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        widget.existingEvent != null
                            ? 'Edit Event'
                            : 'Create Event',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Form content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildTitleField(),
                        const SizedBox(height: 16),
                        _buildEventTypeSelector(),
                        const SizedBox(height: 16),
                        _buildDateTimeSection(),
                        const SizedBox(height: 16),
                        _buildPrioritySelector(),
                        const SizedBox(height: 16),
                        _buildColorSelector(),
                        const SizedBox(height: 16),
                        _buildDescriptionField(),
                        const SizedBox(height: 16),
                        _buildLocationField(),
                        const SizedBox(height: 16),
                        _buildReminderSection(),
                        const SizedBox(height: 16),
                        _buildRecurrenceSection(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Event Title',
        hintText: 'Enter event title',
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter an event title';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildEventTypeSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Type',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CalendarEventType.values.map((type) {
            final isSelected = _selectedEventType == type;
            return _buildEventTypeChip(type, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEventTypeChip(CalendarEventType type, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEventType = type;
          _updateColorBasedOnType(type);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? null
              : Border.all(color: colorScheme.outline.withAlpha(128)),
        ),
        child: Text(
          type.name,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('All Day'),
          value: _isAllDay,
          onChanged: (value) {
            setState(() {
              _isAllDay = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeField(
                'Start',
                _startDateTime,
                (dateTime) {
                  setState(() {
                    _startDateTime = dateTime;
                    if (_endDateTime.isBefore(_startDateTime)) {
                      _endDateTime =
                          _startDateTime.add(const Duration(hours: 1));
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateTimeField(
                'End',
                _endDateTime,
                (dateTime) {
                  setState(() {
                    _endDateTime = dateTime;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeField(
    String label,
    DateTime dateTime,
    Function(DateTime) onChanged,
  ) {
    return InkWell(
      onTap: () => _selectDateTime(dateTime, onChanged),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          _isAllDay
              ? '${dateTime.day}/${dateTime.month}/${dateTime.year}'
              : '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: EventPriority.values.map((priority) {
            final isSelected = _selectedPriority == priority;
            return _buildPriorityChip(priority, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(EventPriority priority, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;

    Color chipColor;
    switch (priority) {
      case EventPriority.urgent:
        chipColor = AppTheme.getErrorColor(isLight);
        break;
      case EventPriority.high:
        chipColor = AppTheme.getWarningColor(isLight);
        break;
      case EventPriority.medium:
        chipColor = colorScheme.primary;
        break;
      case EventPriority.low:
        chipColor = AppTheme.getSuccessColor(isLight);
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : chipColor.withAlpha(26),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          priority.name,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : chipColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    final theme = Theme.of(context);

    final colors = [
      '#2196F3',
      '#4CAF50',
      '#FF9800',
      '#F44336',
      '#9C27B0',
      '#00BCD4',
      '#FF5722',
      '#795548',
      '#607D8B',
      '#3F51B5'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: colors.map((color) {
            final isSelected = _colorCode == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _colorCode = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(
                      int.parse(color.substring(1), radix: 16) + 0xFF000000),
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(51),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Enter event description',
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      decoration: const InputDecoration(
        labelText: 'Location (Optional)',
        hintText: 'Enter event location',
        prefixIcon: Icon(Icons.location_on),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildReminderSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _reminderMinutes,
          decoration: const InputDecoration(
            labelText: 'Remind me',
            prefixIcon: Icon(Icons.notifications),
          ),
          items: const [
            DropdownMenuItem(value: 0, child: Text('No reminder')),
            DropdownMenuItem(value: 15, child: Text('15 minutes before')),
            DropdownMenuItem(value: 30, child: Text('30 minutes before')),
            DropdownMenuItem(value: 60, child: Text('1 hour before')),
            DropdownMenuItem(value: 120, child: Text('2 hours before')),
            DropdownMenuItem(value: 1440, child: Text('1 day before')),
          ],
          onChanged: (value) {
            setState(() {
              _reminderMinutes = value ?? 30;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRecurrenceSection() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecurrenceType>(
          value: _selectedRecurrence,
          decoration: const InputDecoration(
            labelText: 'Repeat',
            prefixIcon: Icon(Icons.repeat),
          ),
          items: RecurrenceType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRecurrence = value ?? RecurrenceType.none;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveEvent,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.existingEvent != null ? 'Update' : 'Create'),
          ),
        ),
      ],
    );
  }

  void _updateColorBasedOnType(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.studySession:
        _colorCode = '#2196F3';
        break;
      case CalendarEventType.assignment:
        _colorCode = '#FF9800';
        break;
      case CalendarEventType.exam:
        _colorCode = '#F44336';
        break;
      case CalendarEventType.break_:
        _colorCode = '#4CAF50';
        break;
      case CalendarEventType.reminder:
        _colorCode = '#9C27B0';
        break;
      case CalendarEventType.deadline:
        _colorCode = '#FF5722';
        break;
      default:
        _colorCode = '#2196F3';
    }
  }

  Future<void> _selectDateTime(
      DateTime current, Function(DateTime) onChanged) async {
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      if (_isAllDay) {
        onChanged(date);
      } else {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(current),
        );

        if (time != null) {
          onChanged(DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          ));
        }
      }
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endDateTime.isBefore(_startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final event = CalendarEvent(
        id: widget.existingEvent?.id ?? '',
        userId: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        eventType: _selectedEventType,
        startDateTime: _startDateTime,
        endDateTime: _endDateTime,
        isAllDay: _isAllDay,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        priority: _selectedPriority,
        colorCode: _colorCode,
        recurrenceType: _selectedRecurrence,
        reminderMinutes: _reminderMinutes,
        createdAt: widget.existingEvent?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final savedEvent = widget.existingEvent != null
          ? await _calendarService
              .updateCalendarEvent(event.copyWith(id: widget.existingEvent!.id))
          : await _calendarService.createCalendarEvent(event);

      widget.onEventCreated(savedEvent);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save event: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
