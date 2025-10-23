import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../core/di/injection_container.dart';
import '../../../students/presentation/bloc/students_event.dart';
import '../../../students/presentation/bloc/students_state.dart';
import '../bloc/templates_bloc.dart';
import '../../../students/presentation/bloc/students_bloc.dart';
import '../../../students/domain/entities/student.dart';
import '../../domain/entities/session_template.dart';

class TemplateFormScreen extends StatefulWidget {
  final SessionTemplate? template;

  const TemplateFormScreen({super.key, this.template});

  @override
  State<TemplateFormScreen> createState() => _TemplateFormScreenState();
}

class _TemplateFormScreenState extends State<TemplateFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  TimeOfDay? _selectedTime;
  bool _hasBooklet = false;
  Set<String> _selectedStudentIds = {};
  Set<int> _recurringDays = {};
  List<Student> _availableStudents = [];

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      // Parse time from string
      final timeParts = widget.template!.timeOfDay.split(':');
      if (timeParts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
      _hasBooklet = widget.template!.hasBookletDefault;
      _selectedStudentIds = widget.template!.studentIds.toSet();
      _recurringDays = widget.template!.weekdays.toSet();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<TemplatesBloc>()),
        BlocProvider(
            create: (_) => sl<StudentsBloc>()..add(const LoadStudents())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.template == null ? 'إنشاء قالب' : 'تعديل قالب'),
        ),
        body: BlocConsumer<TemplatesBloc, TemplatesState>(
          listener: (context, state) {
            if (state is TemplateOperationSuccess) {
              EasyLoading.showSuccess(state.message);
              if (context.mounted) {
                Navigator.pop(context, true);
              }
            } else if (state is TemplatesError) {
              EasyLoading.showError(state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is TemplatesLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Template Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم القالب',
                        hintText: 'مثال: حصص الأحد والثلاثاء',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.label),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Time
                    Text(
                      'الوقت الافتراضي',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      title: Text(_selectedTime != null
                          ? _selectedTime!.format(context)
                          : 'اختر الوقت'),
                      leading: const Icon(Icons.access_time),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _pickTime,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Has Booklet
                    SwitchListTile(
                      title: const Text('يحتوي على ملزمة'),
                      value: _hasBooklet,
                      onChanged: (value) => setState(() => _hasBooklet = value),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recurring Days
                    Text(
                      'الأيام المتكررة',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        final isSelected = _recurringDays.contains(index);
                        return FilterChip(
                          label: Text(_getDayName(index)),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _recurringDays.add(index);
                              } else {
                                _recurringDays.remove(index);
                              }
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Students Selection
                    Text(
                      'الطلاب',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    BlocBuilder<StudentsBloc, StudentsState>(
                      builder: (context, state) {
                        if (state is StudentsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is StudentsLoaded) {
                          _availableStudents =
                              state.students.where((s) => s.isActive).toList();

                          return Column(
                            children: [
                              // Select All / Deselect All
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${_selectedStudentIds.length} طالب محدد'),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _selectedStudentIds =
                                                _availableStudents
                                                    .map((s) => s.id)
                                                    .toSet();
                                          });
                                        },
                                        child: const Text('تحديد الكل'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() =>
                                              _selectedStudentIds.clear());
                                        },
                                        child: const Text('إلغاء التحديد'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Students List
                              Container(
                                constraints:
                                    const BoxConstraints(maxHeight: 300),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _availableStudents.length,
                                  itemBuilder: (context, index) {
                                    final student = _availableStudents[index];
                                    final isSelected = _selectedStudentIds
                                        .contains(student.id);

                                    return CheckboxListTile(
                                      title: Text(student.name),
                                      subtitle: Text(student.year),
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedStudentIds.add(student.id);
                                          } else {
                                            _selectedStudentIds
                                                .remove(student.id);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        } else if (state is StudentsError) {
                          return Center(
                            child: Text(state.message),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 16),

                    // Note
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _saveTemplate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                widget.template == null
                                    ? 'إنشاء القالب'
                                    : 'حفظ التغييرات',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  String _getDayName(int day) {
    const days = [
      'الأحد',
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت'
    ];
    return days[day % 7];
  }

  void _saveTemplate() {
    if (_formKey.currentState!.validate()) {
      if (_selectedStudentIds.isEmpty) {
        EasyLoading.showToast('يرجى تحديد طالب واحد على الأقل');
        return;
      }

      // Convert TimeOfDay to string
      final timeString = _selectedTime != null
          ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
          : '00:00';

      final template = SessionTemplate(
        id: widget.template?.id ?? '',
        name: _nameController.text,
        weekdays: _recurringDays.toList(),
        timeOfDay: timeString,
        durationMin: 60, // Default 60 minutes
        hasBookletDefault: _hasBooklet,
        studentIds: _selectedStudentIds.toList(),
      );

      if (widget.template == null) {
        context.read<TemplatesBloc>().add(CreateTemplate(template));
      } else {
        context.read<TemplatesBloc>().add(UpdateTemplate(template));
      }
    }
  }
}
