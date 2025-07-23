import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../services/subject_service.dart';
import '../../../services/auth_service.dart';

class AddSubjectModalWidget extends StatefulWidget {
  final Map<String, dynamic>? subject;

  const AddSubjectModalWidget({super.key, this.subject});

  @override
  State<AddSubjectModalWidget> createState() => _AddSubjectModalWidgetState();
}

class _AddSubjectModalWidgetState extends State<AddSubjectModalWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _instructorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _semesterController = TextEditingController();
  final _currentGradeController = TextEditingController();
  final _gradeGoalController = TextEditingController();

  final SubjectService _subjectService = SubjectService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _selectedColor = '#2196F3';
  int _creditHours = 3;

  final List<String> _predefinedColors = [
    '#2196F3',
    '#4CAF50',
    '#FF9800',
    '#F44336',
    '#9C27B0',
    '#009688',
    '#FF5722',
    '#795548',
    '#607D8B',
    '#E91E63',
    '#3F51B5',
    '#8BC34A',
    '#FFC107',
    '#FF5722',
    '#673AB7',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      _initializeFormWithExistingData();
    }
  }

  void _initializeFormWithExistingData() {
    final subject = widget.subject!;
    _nameController.text = subject['name'] ?? '';
    _instructorController.text = subject['instructor'] ?? '';
    _descriptionController.text = subject['description'] ?? '';
    _semesterController.text = subject['semester'] ?? '';
    _currentGradeController.text = subject['current_grade'] ?? '';
    _gradeGoalController.text = subject['grade_goal'] ?? '';
    _selectedColor = subject['color_code'] ?? '#2196F3';
    _creditHours = subject['credit_hours'] ?? 3;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    _descriptionController.dispose();
    _semesterController.dispose();
    _currentGradeController.dispose();
    _gradeGoalController.dispose();
    super.dispose();
  }

  Future<void> _saveSubject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = await _authService.getUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final subjectData = {
        'user_id': currentUser.id,
        'name': _nameController.text.trim(),
        'instructor': _instructorController.text.trim().isEmpty
            ? null
            : _instructorController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'semester': _semesterController.text.trim().isEmpty
            ? null
            : _semesterController.text.trim(),
        'current_grade': _currentGradeController.text.trim().isEmpty
            ? null
            : _currentGradeController.text.trim(),
        'grade_goal': _gradeGoalController.text.trim().isEmpty
            ? null
            : _gradeGoalController.text.trim(),
        'color_code': _selectedColor,
        'credit_hours': _creditHours,
        'is_active': true,
      };

      if (widget.subject != null) {
        await _subjectService.updateSubject(widget.subject!['id'], subjectData);
        _showSuccessToast('Subject updated successfully');
      } else {
        await _subjectService.createSubject(subjectData);
        _showSuccessToast('Subject created successfully');
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      _showErrorToast('Failed to save subject: $error');
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
      height: MediaQuery.of(context).size.height * 0.9,
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
                    widget.subject != null ? 'Edit Subject' : 'Add New Subject',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: 48.w), // Balance the close button
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
                      controller: _nameController,
                      label: 'Subject Name',
                      hint: 'e.g., Mathematics, Physics, Literature',
                      required: true,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _instructorController,
                      label: 'Instructor',
                      hint: 'e.g., Dr. Smith, Prof. Johnson',
                      required: false,
                    ),
                    SizedBox(height: 16.h),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Brief description of the subject',
                      required: false,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _semesterController,
                            label: 'Semester',
                            hint: 'e.g., Fall 2024, Spring 2025',
                            required: false,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildCreditHoursSelector(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _currentGradeController,
                            label: 'Current Grade',
                            hint: 'e.g., A, B+, 85%',
                            required: false,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildTextField(
                            controller: _gradeGoalController,
                            label: 'Grade Goal',
                            hint: 'e.g., A+, 95%',
                            required: false,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    _buildColorPicker(),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveSubject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(int.parse(
                              _selectedColor.replaceAll('#', '0xFF'))),
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
                                widget.subject != null
                                    ? 'Update Subject'
                                    : 'Add Subject',
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color:
                      Color(int.parse(_selectedColor.replaceAll('#', '0xFF')))),
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

  Widget _buildCreditHoursSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credit Hours',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<int>(
          value: _creditHours,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color:
                      Color(int.parse(_selectedColor.replaceAll('#', '0xFF')))),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          ),
          items: List.generate(8, (index) => index + 1)
              .map((hours) => DropdownMenuItem(
                    value: hours,
                    child: Text('$hours Credit${hours > 1 ? 's' : ''}',
                        style: GoogleFonts.inter()),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() => _creditHours = value ?? 3);
          },
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject Color',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: _predefinedColors.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.replaceAll('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}