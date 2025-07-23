import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../services/auth_service.dart';
import '../../services/subject_service.dart';
import './widgets/add_subject_modal_widget.dart';
import './widgets/subject_card_widget.dart';
import './widgets/subject_filter_widget.dart';
import './widgets/subject_search_widget.dart';

class SubjectManagement extends StatefulWidget {
  const SubjectManagement({super.key});

  @override
  State<SubjectManagement> createState() => _SubjectManagementState();
}

class _SubjectManagementState extends State<SubjectManagement>
    with SingleTickerProviderStateMixin {
  final SubjectService _subjectService = SubjectService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _subjects = [];
  List<Map<String, dynamic>> _filteredSubjects = [];
  List<String> _semesters = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSemester = 'All';
  String _selectedStatus = 'All';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  @override
  void dispose() {
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

      final subjects = await _subjectService.getSubjectsWithProgress();
      final semesters = await _subjectService.getSemesters();

      setState(() {
        _subjects = subjects;
        _filteredSubjects = subjects;
        _semesters = ['All', ...semesters];
        _isLoading = false;
      });

      _animationController.forward();
    } catch (error) {
      setState(() => _isLoading = false);
      _showErrorToast('Failed to load subjects: $error');
    }
  }

  void _filterSubjects() {
    setState(() {
      _filteredSubjects = _subjects.where((subject) {
        final matchesSearch = _searchQuery.isEmpty ||
            subject['name']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (subject['instructor'] ?? '')
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());

        final matchesSemester = _selectedSemester == 'All' ||
            subject['semester'] == _selectedSemester;

        final matchesStatus = _selectedStatus == 'All' ||
            subject['status'] == _selectedStatus.toLowerCase();

        return matchesSearch && matchesSemester && matchesStatus;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _filterSubjects();
  }

  void _onSemesterChanged(String semester) {
    setState(() => _selectedSemester = semester);
    _filterSubjects();
  }

  void _onStatusChanged(String status) {
    setState(() => _selectedStatus = status);
    _filterSubjects();
  }

  Future<void> _showAddSubjectModal() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddSubjectModalWidget(),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _editSubject(Map<String, dynamic> subject) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSubjectModalWidget(subject: subject),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _deleteSubject(String subjectId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Subject',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text(
            'Are you sure you want to delete this subject? This action cannot be undone.',
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
        await _subjectService.deleteSubject(subjectId);
        await _loadData();
        _showSuccessToast('Subject deleted successfully');
      } catch (error) {
        _showErrorToast('Failed to delete subject: $error');
      }
    }
  }

  Future<void> _archiveSubject(String subjectId) async {
    try {
      await _subjectService.archiveSubject(subjectId);
      await _loadData();
      _showSuccessToast('Subject archived successfully');
    } catch (error) {
      _showErrorToast('Failed to archive subject: $error');
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
          'My Subjects',
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
            icon: const Icon(Icons.add, size: 24),
            onPressed: _showAddSubjectModal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        SubjectSearchWidget(
                          onSearchChanged: _onSearchChanged,
                        ),
                        SizedBox(height: 12.h),
                        SubjectFilterWidget(
                          semesters: _semesters,
                          selectedSemester: _selectedSemester,
                          selectedStatus: _selectedStatus,
                          onSemesterChanged: _onSemesterChanged,
                          onStatusChanged: _onStatusChanged,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _filteredSubjects.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            child: ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: _filteredSubjects.length,
                              itemBuilder: (context, index) {
                                final subject = _filteredSubjects[index];
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 12.h),
                                  child: SubjectCardWidget(
                                    subject: subject,
                                    onEdit: () => _editSubject(subject),
                                    onDelete: () =>
                                        _deleteSubject(subject['id']),
                                    onArchive: () =>
                                        _archiveSubject(subject['id']),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedSemester != 'All' ||
                    _selectedStatus != 'All'
                ? 'No subjects match your filters'
                : 'No subjects yet',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedSemester != 'All' ||
                    _selectedStatus != 'All'
                ? 'Try adjusting your search or filter options'
                : 'Add your first subject to get started',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty &&
              _selectedSemester == 'All' &&
              _selectedStatus == 'All') ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _showAddSubjectModal,
              icon: const Icon(Icons.add),
              label: Text('Add Your First Subject', style: GoogleFonts.inter()),
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
}
