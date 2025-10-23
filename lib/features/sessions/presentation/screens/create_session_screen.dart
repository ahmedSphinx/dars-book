import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../core/di/injection_container.dart';
import '../../../pricing/domain/entities/price.dart';
import '../bloc/sessions_bloc.dart';
import '../../../students/domain/entities/student.dart';
import '../../../students/presentation/bloc/students_bloc.dart';
import '../../../students/presentation/bloc/students_event.dart';
import '../../../students/presentation/bloc/students_state.dart';
import '../../../pricing/presentation/bloc/prices_bloc.dart';
import '../../domain/entities/session.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _hasBooklet = false;

  List<Student> _availableStudents = [];
  Set<String> _selectedStudentIds = {};
  final Map<String, bool> _attendance = {}; // studentId -> present
  final Map<String, double> _lessonPrices = {}; // studentId -> price
  final Map<String, double> _bookletPrices = {}; // studentId -> price

  int _currentStep = 0;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SessionsBloc>()),
        BlocProvider(
            create: (_) => sl<StudentsBloc>()..add(const LoadStudents())),
        BlocProvider(create: (_) => sl<PricesBloc>()..add(const LoadPrices())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء حصة'),
        ),
        body: BlocConsumer<SessionsBloc, SessionsState>(
          listener: (context, state) {
            if (state is SessionOperationSuccess) {
              EasyLoading.showSuccess(state.message);
              if (context.mounted) {
                Navigator.pop(context);
                EasyLoading.dismiss();
              }
            } else if (state is SessionsError) {
              EasyLoading.showError(state.message);
            }
          },
          builder: (context, sessionState) {
            final isLoading = sessionState is SessionsLoading;

            return Stepper(
              currentStep: _currentStep,
              onStepContinue: isLoading ? null : _onStepContinue,
              onStepCancel: _currentStep > 0
                  ? () => setState(() => _currentStep--)
                  : null,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      if (_currentStep < 2)
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: Text('التالي'),
                        ),
                      if (_currentStep == 2)
                        ElevatedButton(
                          onPressed: isLoading ? null : _saveSession,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('حفظ الحصة'),
                        ),
                      const SizedBox(width: 12),
                      if (details.onStepCancel != null)
                        OutlinedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                          ),
                          onPressed: details.onStepCancel,
                          child: const Text('السابق'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                // Step 1: Session Details
                Step(
                  title: const Text('تفاصيل الحصة'),
                  content: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Date Picker
                        ListTile(
                          title: const Text('اختر التاريخ'),
                          subtitle: Text(
                            _selectedDate.toString().split(' ')[0],
                          ),
                          leading: const Icon(Icons.calendar_today),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _pickDate,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Time Picker
                        ListTile(
                          title: const Text('اختر الوقت'),
                          subtitle: Text(_selectedTime.format(context)),
                          leading: const Icon(Icons.access_time),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _pickTime,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Has Booklet Toggle
                        SwitchListTile(
                          title: const Text('يحتوي على ملزمة'),
                          subtitle: Text(_hasBooklet
                              ? 'يوجد ملزمة للحصة'
                              : 'لا يوجد ملزمة'),
                          value: _hasBooklet,
                          onChanged: (value) =>
                              setState(() => _hasBooklet = value),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Note Field
                        TextFormField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'ملاحظات (${'اختياري'})',
                            border: const OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 0,
                  state:
                      _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),

                // Step 2: Select Students
                Step(
                  title: const Text('اختيار الطلاب'),
                  content: BlocBuilder<StudentsBloc, StudentsState>(
                    builder: (context, state) {
                      if (state is StudentsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is StudentsLoaded) {
                        _availableStudents =
                            state.students.where((s) => s.isActive).toList();

                        if (_availableStudents.isEmpty) {
                          return const Center(
                              child: Text('لا يوجد طلاب نشطين'));
                        }

                        return Column(
                          children: [
                            // Select All / Deselect All
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_selectedStudentIds.length} طالب محدد',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
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
                                        setState(
                                            () => _selectedStudentIds.clear());
                                      },
                                      child: const Text('إلغاء التحديد'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(),

                            // Students List
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _availableStudents.length,
                              itemBuilder: (context, index) {
                                final student = _availableStudents[index];
                                final isSelected =
                                    _selectedStudentIds.contains(student.id);

                                return CheckboxListTile(
                                  title: Text(student.name),
                                  subtitle: Text(student.year),
                                  value: isSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedStudentIds.add(student.id);
                                      } else {
                                        _selectedStudentIds.remove(student.id);
                                      }
                                    });
                                  },
                                );
                              },
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
                  isActive: _currentStep >= 1,
                  state:
                      _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),

                // Step 3: Take Attendance
                Step(
                  title: const Text('تسجيل الحضور'),
                  content: _buildAttendanceStep(),
                  isActive: _currentStep >= 2,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceStep() {
    if (_selectedStudentIds.isEmpty) {
      return const Center(child: Text('لم يتم تحديد طلاب'));
    }

    final selectedStudents = _availableStudents
        .where((s) => _selectedStudentIds.contains(s.id))
        .toList();

    return BlocBuilder<PricesBloc, PricesState>(
      builder: (context, priceState) {
        // Initialize attendance and prices
        for (var student in selectedStudents) {
          _attendance.putIfAbsent(student.id, () => true);

          // Get price for student
          if (priceState is PricesLoaded && priceState.prices.isNotEmpty) {
            final yearPrice = priceState.prices.cast<Price>().firstWhere(
                  (p) => p.year == student.year,
                  orElse: () => priceState.prices.first,
                );

            _lessonPrices.putIfAbsent(
              student.id,
              () => student.customLessonPrice ?? yearPrice.lessonPrice,
            );
            _bookletPrices.putIfAbsent(
              student.id,
              () => student.customBookletPrice ?? yearPrice.bookletPrice,
            );
          }
        }

        // Calculate total revenue
        double totalRevenue = 0;
        for (var student in selectedStudents) {
          if (_attendance[student.id] == true) {
            totalRevenue += _lessonPrices[student.id] ?? 0;
            if (_hasBooklet) {
              totalRevenue += _bookletPrices[student.id] ?? 0;
            }
          }
        }

        return Column(
          children: [
            // Bulk Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          for (var id in _selectedStudentIds) {
                            _attendance[id] = true;
                          }
                        });
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('تحديد الكل حاضر'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          for (var id in _selectedStudentIds) {
                            _attendance[id] = false;
                          }
                        });
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('تحديد الكل غائب'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Attendance List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: selectedStudents.length,
              itemBuilder: (context, index) {
                final student = selectedStudents[index];
                final isPresent = _attendance[student.id] ?? true;
                final lessonPrice = _lessonPrices[student.id] ?? 0;
                final bookletPrice = _bookletPrices[student.id] ?? 0;
                final total = isPresent
                    ? lessonPrice + (_hasBooklet ? bookletPrice : 0)
                    : 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPresent ? Colors.green : Colors.red,
                      child: Icon(
                        isPresent ? Icons.check : Icons.close,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(student.name),
                    subtitle: Text(
                      isPresent
                          ? '$lessonPrice ج.م${_hasBooklet ? ' + $bookletPrice ج.م = $total ج.م' : ''}'
                          : 'غائب',
                    ),
                    trailing: Switch(
                      value: isPresent,
                      onChanged: (value) {
                        setState(() => _attendance[student.id] = value);
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Total Revenue
            Card(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'إجمالي الإيرادات',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '$totalRevenue ج.م',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      // Validate step 1
      if (_formKey.currentState!.validate()) {
        setState(() => _currentStep = 1);
      }
    } else if (_currentStep == 1) {
      // Validate step 2
      if (_selectedStudentIds.isEmpty) {
        EasyLoading.showToast('يرجى تحديد طالب واحد على الأقل');
      } else {
        setState(() => _currentStep = 2);
      }
    }
  }

  void _saveSession() {
    EasyLoading.show(status: 'جاري حفظ الحصة...');
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final attendances = _selectedStudentIds.map((studentId) {
      final student = _availableStudents.firstWhere((s) => s.id == studentId);
      final isPresent = _attendance[studentId] ?? true;
      final lessonPrice = _lessonPrices[studentId] ?? 0;
      final bookletPrice = _bookletPrices[studentId] ?? 0;

      return Attendance(
        studentId: studentId,
        studentName: student.name,
        present: isPresent,
        lessonPriceSnap: lessonPrice,
        bookletPriceSnap: bookletPrice,
        sessionCharge: isPresent ? lessonPrice : 0,
        bookletCharge: isPresent && _hasBooklet ? bookletPrice : 0,
      );
    }).toList();

    final session = Session.createNew(
      dateTime: dateTime,
      hasBooklet: _hasBooklet,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      attendances: attendances,
    );

    context.read<SessionsBloc>().add(CreateSession(session));
  }
}
