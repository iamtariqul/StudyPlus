import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AssignmentFilterWidget extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;
  final String selectedStatus;
  final String selectedSubject;
  final Function(String) onStatusChanged;
  final Function(String) onSubjectChanged;

  const AssignmentFilterWidget({
    super.key,
    required this.subjects,
    required this.selectedStatus,
    required this.selectedSubject,
    required this.onStatusChanged,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterDropdown(
            label: 'Status',
            value: selectedStatus,
            items: const [
              'All',
              'Pending',
              'In Progress',
              'Completed',
              'Overdue'
            ],
            onChanged: onStatusChanged,
            icon: Icons.filter_alt,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildSubjectFilterDropdown(),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.black,
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: GoogleFonts.inter(fontSize: 12.sp),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilterDropdown() {
    final subjectItems = [
      {'id': 'All', 'name': 'All Subjects', 'color_code': '#666666'},
      ...subjects,
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.school, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8.w),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSubject,
                isExpanded: true,
                hint: Text(
                  'Subject',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: Colors.black,
                ),
                items: subjectItems.map((subject) {
                  return DropdownMenuItem<String>(
                    value: subject['id'],
                    child: Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                              subject['color_code']?.replaceAll('#', '0xFF') ??
                                  '0xFF666666',
                            )),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            subject['name'],
                            style: GoogleFonts.inter(fontSize: 12.sp),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onSubjectChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
