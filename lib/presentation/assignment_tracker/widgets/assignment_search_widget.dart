import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AssignmentSearchWidget extends StatefulWidget {
  final Function(String) onSearchChanged;

  const AssignmentSearchWidget({
    super.key,
    required this.onSearchChanged,
  });

  @override
  State<AssignmentSearchWidget> createState() => _AssignmentSearchWidgetState();
}

class _AssignmentSearchWidgetState extends State<AssignmentSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search assignments or subjects...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[500],
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
        ),
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          color: Colors.black,
        ),
      ),
    );
  }
}
