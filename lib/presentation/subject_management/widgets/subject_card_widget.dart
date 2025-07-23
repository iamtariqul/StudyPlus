import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SubjectCardWidget extends StatelessWidget {
  final Map<String, dynamic> subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onArchive;

  const SubjectCardWidget({
    super.key,
    required this.subject,
    required this.onEdit,
    required this.onDelete,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final progress = subject['subject_progress'] as List?;
    final progressData = progress?.isNotEmpty == true ? progress!.first : null;
    final completedAssignments = progressData?['completed_assignments'] ?? 0;
    final totalAssignments = progressData?['total_assignments'] ?? 0;
    final averageGrade = progressData?['average_grade'] ?? 0.0;
    final completionRate = totalAssignments > 0
        ? (completedAssignments / totalAssignments) * 100
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigate to subject details
        },
        onLongPress: () => _showContextMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      color: Color(int.parse(
                          subject['color_code']?.replaceAll('#', '0xFF') ??
                              '0xFF2196F3')),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject['name'] ?? 'Unknown Subject',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        if (subject['instructor'] != null) ...[
                          Text(
                            'Instructor: ${subject['instructor']}',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],
                        Row(
                          children: [
                            if (subject['current_grade'] != null) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color:
                                      _getGradeColor(subject['current_grade']),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Current: ${subject['current_grade']}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                            ],
                            if (subject['credit_hours'] != null) ...[
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${subject['credit_hours']} Credits',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.sp,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onPressed: () => _showContextMenu(context),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Assignments',
                      '$completedAssignments/$totalAssignments',
                      Icons.assignment,
                      Colors.blue,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      'Completion',
                      '${completionRate.toStringAsFixed(0)}%',
                      Icons.trending_up,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildStatCard(
                      'Avg Grade',
                      averageGrade > 0
                          ? '${averageGrade.toStringAsFixed(1)}%'
                          : 'N/A',
                      Icons.star,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
              if (completionRate > 0) ...[
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text(
                      'Progress',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: completionRate / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(int.parse(
                              subject['color_code']?.replaceAll('#', '0xFF') ??
                                  '0xFF2196F3')),
                        ),
                        minHeight: 6.h,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'A-':
      case 'B+':
        return Colors.lightGreen;
      case 'B':
      case 'B-':
        return Colors.orange;
      case 'C+':
      case 'C':
        return Colors.deepOrange;
      case 'C-':
      case 'D':
        return Colors.red;
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
              title: Text('Edit Subject', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.green),
              title: Text('View Details', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                // Navigate to subject details
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.orange),
              title: Text('Archive Subject', style: GoogleFonts.inter()),
              onTap: () {
                Navigator.pop(context);
                onArchive();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Subject', style: GoogleFonts.inter()),
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
