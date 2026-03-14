import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/hiring_service.dart';

class AddPositionDialogWidget extends StatefulWidget {
  final VoidCallback onPositionAdded;

  const AddPositionDialogWidget({
    Key? key,
    required this.onPositionAdded,
  }) : super(key: key);

  @override
  State<AddPositionDialogWidget> createState() =>
      _AddPositionDialogWidgetState();
}

class _AddPositionDialogWidgetState extends State<AddPositionDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  final HiringService _hiringService = HiringService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();

  String _selectedEmploymentType = 'full_time';
  String _selectedExperienceLevel = 'mid';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final positionData = {
        'title': _titleController.text.trim(),
        'department': _departmentController.text.trim(),
        'employment_type': _selectedEmploymentType,
        'experience_level': _selectedExperienceLevel,
        'location': _locationController.text.trim(),
        'salary_range': _salaryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'requirements': _requirementsController.text.trim(),
        'is_active': true,
      };

      await _hiringService.createJobPosition(positionData);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onPositionAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job position created successfully')),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating position: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Position',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedEmploymentType,
                        decoration: const InputDecoration(
                          labelText: 'Employment Type',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'full_time', child: Text('Full Time')),
                          DropdownMenuItem(
                              value: 'part_time', child: Text('Part Time')),
                          DropdownMenuItem(
                              value: 'contract', child: Text('Contract')),
                          DropdownMenuItem(
                              value: 'internship', child: Text('Internship')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedEmploymentType = value!);
                        },
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedExperienceLevel,
                        decoration: const InputDecoration(
                          labelText: 'Experience Level',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'entry', child: Text('Entry')),
                          DropdownMenuItem(value: 'mid', child: Text('Mid')),
                          DropdownMenuItem(
                              value: 'senior', child: Text('Senior')),
                          DropdownMenuItem(value: 'lead', child: Text('Lead')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedExperienceLevel = value!);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _salaryController,
                  decoration: const InputDecoration(
                    labelText: 'Salary Range',
                    hintText: 'e.g., \$80,000 - \$120,000',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Job Description *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _requirementsController,
                  decoration: const InputDecoration(
                    labelText: 'Requirements *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 12.h),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              height: 16.h,
                              width: 16.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Create Position'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
