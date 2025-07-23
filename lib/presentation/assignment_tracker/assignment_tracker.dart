import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../services/assignment_service.dart';
import '../../services/auth_service.dart';
import '../../services/subject_service.dart';
import './widgets/add_assignment_modal_widget.dart';
import './widgets/assignment_calendar_widget.dart';
import './widgets/assignment_card_widget.dart';
import './widgets/assignment_filter_widget.dart';
import './widgets/assignment_search_widget.dart';

class AssignmentTracker extends StatefulWidget {
  const AssignmentTracker({super.key});

  @override
  State<AssignmentTracker> createState() => _AssignmentTrackerState();
}

class _AssignmentTrackerState extends State<AssignmentTracker>
    with SingleTickerProviderStateMixin {
  final AssignmentService _assignmentService = AssignmentService();
  final SubjectService _subjectService = SubjectService();
  final AuthService _authService = AuthService();

  late TabController _tabController;

  List<Map<String, dynamic>> _assignments = [];
  List<Map<String, dynamic>> _filteredAssignments = [];
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;
  bool _isCalendarView = false;
  String _searchQuery = '';
  String _selectedStatus = 'All';
  String _selectedSubject = 'All';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final assignments = await _assignmentService.getAssignments();
      final subjects = await _subjectService.getSubjects();

      setState(() {
        _assignments = assignments;
        _filteredAssignments = assignments;
        _subjects = subjects;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorToast('Failed to load assignments: $error');
    }
  }

  void _filterAssignments() {
    setState(() {
      _filteredAssignments = _assignments.where((assignment) {
        final matchesSearch = _searchQuery.isEmpty ||
            assignment['title']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (assignment['study_subjects']?['name'] ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        final matchesStatus = _selectedStatus == 'All' ||
            assignment['status'] == _selectedStatus.toLowerCase();

        final matchesSubject = _selectedSubject == 'All' ||
            assignment['subject_id'] == _selectedSubject;

        return matchesSearch && matchesStatus && matchesSubject;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _filterAssignments();
  }

  void _onStatusChanged(String status) {
    setState(() => _selectedStatus = status);
    _filterAssignments();
  }

  void _onSubjectChanged(String subjectId) {
    setState(() => _selectedSubject = subjectId);
    _filterAssignments();
  }

  Future<void> _showAddAssignmentModal() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAssignmentModalWidget(subjects: _subjects),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _editAssignment(Map<String, dynamic> assignment) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAssignmentModalWidget(
        subjects: _subjects,
        assignment: assignment,
      ),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _deleteAssignment(String assignmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Assignment',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text(
            'Are you sure you want to delete this assignment? This action cannot be undone.',
            style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _assignmentService.deleteAssignment(assignmentId);
        await _loadData();
        _showSuccessToast('Assignment deleted successfully');
      } catch (error) {
        _showErrorToast('Failed to delete assignment: $error');
      }
    }
  }

  Future<void> _toggleAssignmentComplete(
      String assignmentId, bool isCompleted) async {
    try {
      if (isCompleted) {
        await _assignmentService.markAssignmentCompleted(assignmentId);
        _showSuccessToast('Assignment marked as completed');
      } else {
        await _assignmentService.updateAssignmentProgress(assignmentId, 0);
        _showSuccessToast('Assignment marked as incomplete');
      }
      await _loadData();
    } catch (error) {
      _showErrorToast('Failed to update assignment: $error');
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Assignments',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(
              _isCalendarView ? Icons.list : Icons.calendar_today,
              size: 24,
            ),
            onPressed: () {
              setState(() => _isCalendarView = !_isCalendarView);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 24),
            onPressed: _showAddAssignmentModal,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(
              child: Text('All Assignments',
                  style: GoogleFonts.inter(fontSize: 14.sp)),
            ),
            Tab(
              child: Text('Calendar View',
                  style: GoogleFonts.inter(fontSize: 14.sp)),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildListView(),
                  _buildCalendarView(),
                ],
              ),
            ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              AssignmentSearchWidget(
                onSearchChanged: _onSearchChanged,
              ),
              SizedBox(height: 12.h),
              AssignmentFilterWidget(
                subjects: _subjects,
                selectedStatus: _selectedStatus,
                selectedSubject: _selectedSubject,
                onStatusChanged: _onStatusChanged,
                onSubjectChanged: _onSubjectChanged,
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredAssignments.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: _filteredAssignments.length,
                    itemBuilder: (context, index) {
                      final assignment = _filteredAssignments[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: AssignmentCardWidget(
                          assignment: assignment,
                          onEdit: () => _editAssignment(assignment),
                          onDelete: () => _deleteAssignment(assignment['id']),
                          onToggleComplete: (isCompleted) =>
                              _toggleAssignmentComplete(
                            assignment['id'],
                            isCompleted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCalendarView() {
    return Container(
      color: Colors.white,
      child: AssignmentCalendarWidget(
        assignments: _assignments,
        onAssignmentTap: (assignment) => _editAssignment(assignment),
        onDateTap: (date) {
          // Filter assignments for selected date
          final dayAssignments = _assignments.where((assignment) {
            final dueDate = DateTime.parse(assignment['due_date']);
            return dueDate.year == date.year &&
                dueDate.month == date.month &&
                dueDate.day == date.day;
          }).toList();

          if (dayAssignments.isNotEmpty) {
            _showDayAssignments(date, dayAssignments);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedStatus != 'All' ||
                    _selectedSubject != 'All'
                ? 'No assignments match your filters'
                : 'No assignments yet',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedStatus != 'All' ||
                    _selectedSubject != 'All'
                ? 'Try adjusting your search or filter options'
                : 'Add your first assignment to get started',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty &&
              _selectedStatus == 'All' &&
              _selectedSubject == 'All') ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _showAddAssignmentModal,
              icon: const Icon(Icons.add),
              label:
                  Text('Add Your First Assignment', style: GoogleFonts.inter()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDayAssignments(
      DateTime date, List<Map<String, dynamic>> assignments) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignments for ${date.day}/${date.month}/${date.year}',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16.h),
            ...assignments.map((assignment) => ListTile(
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
                  title: Text(assignment['title'],
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                  subtitle: Text(
                    assignment['study_subjects']?['name'] ?? 'Unknown Subject',
                    style: GoogleFonts.inter(
                        fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                  trailing: Chip(
                    label: Text(
                      assignment['status']?.toUpperCase() ?? 'PENDING',
                      style: GoogleFonts.inter(
                          fontSize: 10.sp, color: Colors.white),
                    ),
                    backgroundColor: _getStatusColor(assignment['status']),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _editAssignment(assignment);
                  },
                )),
          ],
        ),
      ),
    );
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
