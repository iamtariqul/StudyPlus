import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AssignmentCardWidget extends StatelessWidget {
  final Map<String, dynamic> assignment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(bool) onToggleComplete;

  const AssignmentCardWidget({
    super.key,
    required this.assignment,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final dueDate = DateTime.parse(assignment['due_date']);
    final isCompleted = assignment['status'] == 'completed';
    final isOverdue = assignment['status'] == 'overdue';
    final subject = assignment['study_subjects'] as Map<String, dynamic>?;
    final completionPercentage = assignment['completion_percentage'] ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onEdit,
        onLongPress: () => _showContextMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: isCompleted,
                    onChanged: (value) => onToggleComplete(value ?? false),
                    activeColor: Colors.green,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment['title'] ?? 'Untitled Assignment',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color:
                                isCompleted ? Colors.grey[600] : Colors.black,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        if (subject != null) ...[
                          Row(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(
                                    subject['color_code']
                                            ?.replaceAll('#', '0xFF') ??
                                        '0xFF2196F3',
                                  )),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                subject['name'] ?? 'Unknown Subject',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                        ],
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: isOverdue ? Colors.red : Colors.grey[600],
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _formatDueDate(dueDate),
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color:
                                    isOverdue ? Colors.red : Colors.grey[600],
                                fontWeight: isOverdue
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color:
                                    _getPriorityColor(assignment['priority']),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                (assignment['priority'] ?? 'medium')
                                    .toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(assignment['status']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStatusText(assignment['status']),
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (assignment['description'] != null &&
                  assignment['description'].isNotEmpty) ...[
                SizedBox(height: 12.h),
                Text(
                  assignment['description'],
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (completionPercentage > 0 && !isCompleted) ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Text(
                      'Progress: ${completionPercentage}%',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: completionPercentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(int.parse(
                            subject?['color_code']?.replaceAll('#', '0xFF') ??
                                '0xFF2196F3',
                          )),
                        ),
                        minHeight: 4.h,
                      ),
                    ),
                  ],
                ),
              ],
              if (assignment['grade_received'] != null ||
                  assignment['points_earned'] != null) ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    if (assignment['grade_received'] != null) ...[
                      Icon(Icons.star, size: 16, color: Colors.orange),
                      SizedBox(width: 4.w),
                      Text(
                        'Grade: ${assignment['grade_received']}',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (assignment['points_earned'] != null &&
                        assignment['points_possible'] != null) ...[
                      if (assignment['grade_received'] != null)
                        SizedBox(width: 16.w),
                      Icon(Icons.score, size: 16, color: Colors.blue),
                      SizedBox(width: 4.w),
                      Text(
                        'Points: ${assignment['points_earned']}/${assignment['points_possible']}',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final assignmentDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (assignmentDate == today) {
      return 'Due today at ${_formatTime(dueDate)}';
    } else if (assignmentDate == tomorrow) {
      return 'Due tomorrow at ${_formatTime(dueDate)}';
    } else if (assignmentDate.isBefore(today)) {
      final difference = today.difference(assignmentDate).inDays;
      return 'Overdue by $difference day${difference == 1 ? '' : 's'}';
    } else {
      final difference = assignmentDate.difference(today).inDays;
      return 'Due in $difference day${difference == 1 ? '' : 's'}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${hour12}:${minute.toString().padLeft(2, '0')} $period';
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

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return 'COMPLETED';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'overdue':
        return 'OVERDUE';
      default:
        return 'PENDING';
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: Text('Edit Assignment', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: Icon(
                assignment['status'] == 'completed' ? Icons.undo : Icons.check,
                color: assignment['status'] == 'completed'
                    ? Colors.orange
                    : Colors.green,
              ),
              title: Text(
                assignment['status'] == 'completed'
                    ? 'Mark as Incomplete'
                    : 'Mark as Complete',
                style: GoogleFonts.inter(),
              ),
              onTap: () {
                Navigator.pop(context);
                onToggleComplete(assignment['status'] != 'completed');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Assignment', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
