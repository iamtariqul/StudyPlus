import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AssignmentCalendarWidget extends StatefulWidget {
  final List<Map<String, dynamic>> assignments;
  final Function(Map<String, dynamic>) onAssignmentTap;
  final Function(DateTime) onDateTap;

  const AssignmentCalendarWidget({
    super.key,
    required this.assignments,
    required this.onAssignmentTap,
    required this.onDateTap,
  });

  @override
  State<AssignmentCalendarWidget> createState() =>
      _AssignmentCalendarWidgetState();
}

class _AssignmentCalendarWidgetState extends State<AssignmentCalendarWidget> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCalendarHeader(),
        _buildCalendarGrid(),
        Expanded(
          child: _buildAssignmentsList(),
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDate =
                    DateTime(_focusedDate.year, _focusedDate.month - 1);
              });
            },
          ),
          Text(
            '${_getMonthName(_focusedDate.month)} ${_focusedDate.year}',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDate =
                    DateTime(_focusedDate.year, _focusedDate.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _buildWeekdaysHeader(),
          SizedBox(height: 8.h),
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildWeekdaysHeader() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: weekdays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedDate.year, _focusedDate.month + 1, 0);
    final startDate =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));

    final days = <Widget>[];
    for (int i = 0; i < 42; i++) {
      final date = startDate.add(Duration(days: i));
      final isCurrentMonth = date.month == _focusedDate.month;
      final isToday = _isSameDay(date, DateTime.now());
      final isSelected = _isSameDay(date, _selectedDate);
      final dayAssignments = _getAssignmentsForDate(date);

      days.add(
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              widget.onDateTap(date);
            },
            child: Container(
              height: 40.h,
              margin: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.blue
                    : isToday
                        ? Colors.blue.withAlpha(26)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday && !isSelected
                    ? Border.all(color: Colors.blue, width: 1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : isCurrentMonth
                              ? Colors.black
                              : Colors.grey[400],
                    ),
                  ),
                  if (dayAssignments.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dayAssignments.take(3).map((assignment) {
                        return Container(
                          width: 4.w,
                          height: 4.h,
                          margin: EdgeInsets.only(right: 2.w),
                          decoration: BoxDecoration(
                            color: _getStatusColor(assignment['status']),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    final weeks = <Widget>[];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(Row(children: days.sublist(i, i + 7)));
    }

    return Column(children: weeks);
  }

  Widget _buildAssignmentsList() {
    final selectedDayAssignments = _getAssignmentsForDate(_selectedDate);

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assignments for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: selectedDayAssignments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No assignments for this day',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: selectedDayAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = selectedDayAssignments[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8.h),
                        child: ListTile(
                          leading: Container(
                            width: 4.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Color(int.parse(
                                assignment['study_subjects']?['color_code']
                                        ?.replaceAll('#', '0xFF') ??
                                    '0xFF2196F3',
                              )),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          title: Text(
                            assignment['title'],
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            assignment['study_subjects']?['name'] ??
                                'Unknown Subject',
                            style: GoogleFonts.inter(
                                fontSize: 12.sp, color: Colors.grey[600]),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Chip(
                                label: Text(
                                  assignment['status']?.toUpperCase() ??
                                      'PENDING',
                                  style: GoogleFonts.inter(
                                      fontSize: 10.sp, color: Colors.white),
                                ),
                                backgroundColor:
                                    _getStatusColor(assignment['status']),
                              ),
                            ],
                          ),
                          onTap: () => widget.onAssignmentTap(assignment),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAssignmentsForDate(DateTime date) {
    return widget.assignments.where((assignment) {
      final dueDate = DateTime.parse(assignment['due_date']);
      return _isSameDay(date, dueDate);
    }).toList();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
