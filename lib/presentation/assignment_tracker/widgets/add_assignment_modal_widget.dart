import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../services/assignment_service.dart';
import '../../../services/auth_service.dart';

class AddAssignmentModalWidget extends StatefulWidget {
  final List<Map<String, dynamic>> subjects;
  final Map<String, dynamic>? assignment;

  const AddAssignmentModalWidget({
    super.key,
    required this.subjects,
    this.assignment,
  });

  @override
  State<AddAssignmentModalWidget> createState() =>
      _AddAssignmentModalWidgetState();
}

class _AddAssignmentModalWidgetState extends State<AddAssignmentModalWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _pointsPossibleController = TextEditingController();
  final _pointsEarnedController = TextEditingController();
  final _gradeReceivedController = TextEditingController();
  final _submissionUrlController = TextEditingController();

  final AssignmentService _assignmentService = AssignmentService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _selectedSubjectId;
  String _selectedPriority = 'medium';
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedDueTime = TimeOfDay.now();
  int _completionPercentage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.assignment != null) {
      _initializeFormWithExistingData();
    }
  }

  void _initializeFormWithExistingData() {
    final assignment = widget.assignment!;
    _titleController.text = assignment['title'] ?? '';
    _descriptionController.text = assignment['description'] ?? '';
    _notesController.text = assignment['notes'] ?? '';
    _pointsPossibleController.text =
        assignment['points_possible']?.toString() ?? '';
    _pointsEarnedController.text =
        assignment['points_earned']?.toString() ?? '';
    _gradeReceivedController.text = assignment['grade_received'] ?? '';
    _submissionUrlController.text = assignment['submission_url'] ?? '';
    _selectedSubjectId = assignment['subject_id'];
    _selectedPriority = assignment['priority'] ?? 'medium';
    _completionPercentage = assignment['completion_percentage'] ?? 0;

    final dueDate = DateTime.parse(assignment['due_date']);
    _selectedDueDate = dueDate;
    _selectedDueTime = TimeOfDay(hour: dueDate.hour, minute: dueDate.minute);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _pointsPossibleController.dispose();
    _pointsEarnedController.dispose();
    _gradeReceivedController.dispose();
    _submissionUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _selectDueTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime,
    );

    if (picked != null) {
      setState(() => _selectedDueTime = picked);
    }
  }

  Future<void> _saveAssignment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSubjectId == null) {
      _showErrorToast('Please select a subject');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = await _authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final dueDateTime = DateTime(
        _selectedDueDate.year,
        _selectedDueDate.month,
        _selectedDueDate.day,
        _selectedDueTime.hour,
        _selectedDueTime.minute,
      );

      final assignmentData = {
        'user_id': currentUser.id,
        'subject_id': _selectedSubjectId,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'due_date': dueDateTime.toIso8601String(),
        'priority': _selectedPriority,
        'completion_percentage': _completionPercentage,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'points_possible': _pointsPossibleController.text.trim().isEmpty
            ? null
            : int.tryParse(_pointsPossibleController.text.trim()),
        'points_earned': _pointsEarnedController.text.trim().isEmpty
            ? null
            : int.tryParse(_pointsEarnedController.text.trim()),
        'grade_received': _gradeReceivedController.text.trim().isEmpty
            ? null
            : _gradeReceivedController.text.trim(),
        'submission_url': _submissionUrlController.text.trim().isEmpty
            ? null
            : _submissionUrlController.text.trim(),
      };

      if (widget.assignment != null) {
        await _assignmentService.updateAssignment(
            widget.assignment!['id'], assignmentData);
        _showSuccessToast('Assignment updated successfully');
      } else {
        await _assignmentService.createAssignment(assignmentData);
        _showSuccessToast('Assignment created successfully');
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      _showErrorToast('Failed to save assignment: $error');
    } finally {
      setState(() => _isLoading = false);
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    widget.assignment != null
                        ? 'Edit Assignment'
                        : 'Add New Assignment',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 48.w),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _titleController,
                      label: 'Assignment Title',
                      hint: 'e.g., Math Problem Set 5, Essay on Literature',
                      required: true,
                    ),
                    SizedBox(height: 16.h),
                    _buildSubjectSelector(),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Brief description of the assignment',
                      required: false,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(child: _buildDateSelector()),
                        SizedBox(width: 16.w),
                        Expanded(child: _buildTimeSelector()),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildPrioritySelector(),
                    SizedBox(height: 16.h),
                    _buildCompletionSlider(),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _pointsPossibleController,
                            label: 'Points Possible',
                            hint: 'Total points',
                            required: false,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _pointsEarnedController,
                            label: 'Points Earned',
                            hint: 'Points received',
                            required: false,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _gradeReceivedController,
                      label: 'Grade Received',
                      hint: 'e.g., A, B+, 85%',
                      required: false,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _submissionUrlController,
                      label: 'Submission URL',
                      hint: 'Link to submission or resources',
                      required: false,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _notesController,
                      label: 'Notes',
                      hint: 'Additional notes or comments',
                      required: false,
                      maxLines: 3,
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveAssignment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                widget.assignment != null
                                    ? 'Update Assignment'
                                    : 'Add Assignment',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool required,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (required ? ' *' : ''),
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          style: GoogleFonts.inter(),
          validator: required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '$label is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject *',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _selectedSubjectId,
          decoration: InputDecoration(
            hintText: 'Select a subject',
            hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          items: widget.subjects.map((subject) {
            return DropdownMenuItem<String>(
              value: subject['id'],
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Color(int.parse(
                        subject['color_code']?.replaceAll('#', '0xFF') ??
                            '0xFF2196F3',
                      )),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(subject['name'], style: GoogleFonts.inter()),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedSubjectId = value);
          },
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date *',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: _selectDueDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}',
                  style: GoogleFonts.inter(),
                ),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Time *',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: _selectDueTime,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDueTime.format(context),
                  style: GoogleFonts.inter(),
                ),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: ['low', 'medium', 'high', 'urgent'].map((priority) {
            final isSelected = _selectedPriority == priority;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: priority != 'urgent' ? 8.w : 0),
                child: InkWell(
                  onTap: () => setState(() => _selectedPriority = priority),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getPriorityColor(priority)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? _getPriorityColor(priority)
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCompletionSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completion Progress: ${_completionPercentage}%',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Slider(
          value: _completionPercentage.toDouble(),
          min: 0,
          max: 100,
          divisions: 10,
          activeColor: Colors.blue,
          inactiveColor: Colors.grey[300],
          onChanged: (value) {
            setState(() => _completionPercentage = value.round());
          },
        ),
      ],
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
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
}