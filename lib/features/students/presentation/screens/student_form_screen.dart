import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../bloc/students_state.dart';
import '../../domain/entities/student.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student; // null for add, Student for edit

  const StudentFormScreen({super.key, this.student});

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _lessonPriceController = TextEditingController();
  final _bookletPriceController = TextEditingController();

  String _selectedYear = 'الصف الأول الثانوي';
  bool _isActive = true;
  bool _hasCustomPricing = false;
  String _countryCode = '+20';

  bool get isEditMode => widget.student != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadStudentData();
    }
  }

  void _loadStudentData() {
    final student = widget.student!;
    _nameController.text = student.name;
    _phoneController.text = student.phone?.replaceFirst(_countryCode, '') ?? '';
    _selectedYear = student.year;
    _notesController.text = student.notes ?? '';
    _isActive = student.isActive;

    if (student.customLessonPrice != null ||
        student.customBookletPrice != null) {
      _hasCustomPricing = true;
      _lessonPriceController.text = student.customLessonPrice?.toString() ?? '';
      _bookletPriceController.text =
          student.customBookletPrice?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _lessonPriceController.dispose();
    _bookletPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StudentsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode
              ? 'تعديل طالب'
              : 'إضافة طالب'),
        ),
        body: BlocConsumer<StudentsBloc, StudentsState>(
          listener: (context, state) {
            if (state is StudentOperationSuccess) {
              EasyLoading.showSuccess(state.message);
              if (context.mounted) {
                Navigator.pop(context);
              }
            } else if (state is StudentsError) {
              EasyLoading.showError(state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is StudentsLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: ' اسم الطالب',
                        prefixIcon: const Icon(Icons.person),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'اجباري إدخال اسم الطالب';
                        }
                        if (value.length < 2) {
                          return 'الاسم يجب أن يكون حرفين على الأقل';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _countryCode,
                              items: const [
                                  DropdownMenuItem(
                                      value: '+20', child: Text('+20')),
                                  DropdownMenuItem(
                                      value: '+966', child: Text('+966')),
                                  DropdownMenuItem(
                                      value: '+971', child: Text('+971')),
                                ],
                                onChanged: (value) {
                                  setState(() => _countryCode = value!);
                                },
                              
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText:
                                    '${'رقم الهاتف'} ( اختياري )',
                                prefixIcon: const Icon(Icons.phone),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    value.length < 9) {
                                  return 'رقم هاتف غير صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Academic Year Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        labelText: 'السنة الدراسية',
                        prefixIcon: const Icon(Icons.school),
                        border: const OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'الصف الأول الثانوي',
                          child: Text('الصف الأول الثانوي'),
                        ),
                        DropdownMenuItem(
                          value: 'الصف الثاني الثانوي',
                          child: Text('الصف الثاني الثانوي'),
                        ),
                        DropdownMenuItem(
                          value: 'الصف الثالث الثانوي',
                          child: Text('الصف الثالث الثانوي'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedYear = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes Field
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText:
                            '${'ملاحظات'} ( اختياري )',
                        prefixIcon: const Icon(Icons.note),
                        border: const OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Active Status
                    SwitchListTile(
                      title: Text('نشط'),
                      subtitle: Text(_isActive ? 'الطالب نشط' : 'الطالب موقوف'),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Custom Pricing Toggle
                    SwitchListTile(
                      title: Text('تسعير مخصص'),
                      subtitle: Text('تخصيص سعر مختلف لهذا الطالب'),
                      value: _hasCustomPricing,
                      onChanged: (value) {
                        setState(() => _hasCustomPricing = value);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),

                    // Custom Pricing Fields
                    if (_hasCustomPricing) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _lessonPriceController,
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: 'سعر الحصة',
                                prefixIcon: const Icon(Icons.attach_money),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _bookletPriceController,
                              keyboardType: TextInputType.number,
                              textDirection: TextDirection.ltr,
                              decoration: InputDecoration(
                                labelText: 'سعر الملزة',
                                prefixIcon: const Icon(Icons.book),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: isLoading ? null : _saveStudent,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'حفظ الطالب',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),

                    // Delete Button (Edit Mode Only)ذ
                    if (isEditMode) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _deleteStudent,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: Text(
                          'حذف الطالب',
                          style: const TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _saveStudent() {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.isNotEmpty
        ? '$_countryCode${_phoneController.text}'
        : null;

    final student = Student(
      id: isEditMode ? widget.student!.id : '',
      name: _nameController.text.trim(),
      phone: phone,
      year: _selectedYear,
      notes: _notesController.text.isNotEmpty
          ? _notesController.text.trim()
          : null,
      isActive: _isActive,
      customLessonPrice:
          _hasCustomPricing && _lessonPriceController.text.isNotEmpty
              ? double.tryParse(_lessonPriceController.text)
              : null,
      customBookletPrice:
          _hasCustomPricing && _bookletPriceController.text.isNotEmpty
              ? double.tryParse(_bookletPriceController.text)
              : null,
      aggregates:
          isEditMode ? widget.student!.aggregates : const StudentAggregates(),
    );

    if (isEditMode) {
      context.read<StudentsBloc>().add(UpdateStudent(student));
    } else {
      context.read<StudentsBloc>().add(AddStudent(student));
    }
  }

  void _deleteStudent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف طالب'),
        content: Text('هل أنت متأكد من حذف هذا الطالب؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text( 'الإلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<StudentsBloc>().add(
                    DeleteStudent(widget.student!.id),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('حذفذ'),
          ),
        ],
      ),
    );
  }
}
