import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class SubjectFilterWidget extends StatelessWidget {
  final List<String> semesters;
  final String selectedSemester;
  final String selectedStatus;
  final Function(String) onSemesterChanged;
  final Function(String) onStatusChanged;

  const SubjectFilterWidget({
    super.key,
    required this.semesters,
    required this.selectedSemester,
    required this.selectedStatus,
    required this.onSemesterChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterDropdown(
            label: 'Semester',
            value: selectedSemester,
            items: semesters,
            onChanged: onSemesterChanged,
            icon: Icons.calendar_today,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildFilterDropdown(
            label: 'Status',
            value: selectedStatus,
            items: const ['All', 'Active', 'Archived', 'Completed'],
            onChanged: onStatusChanged,
            icon: Icons.filter_alt,
          ),
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
}
