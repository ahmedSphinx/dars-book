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
        BlocProvider(create: (_) => sl<StudentsBloc>()..add(const LoadStudents())),
        BlocProvider(create: (_) => sl<PricesBloc>()..add(const LoadPrices())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إنشاء حصة'),
        ),
        body: BlocConsumer<SessionsBloc, SessionsState>(
          listener: (context, state) {
            _handleSessionsState(context, state);
          },
          builder: (context, sessionState) {
            // _handleSessionsState(context, sessionState);
            return _buildSessionContent(context, sessionState);
          },
        ),
      ),
    );
  }

  /// Handle SessionsState changes with comprehensive state management
  void _handleSessionsState(BuildContext context, SessionsState state) {
    if (state is SessionOperationSuccess) {
      EasyLoading.showSuccess(state.message);
      if (context.mounted) {
        if (mounted) {
          // Reset form state
          _resetForm();
          // Navigate back after a short delay
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {}
          });
        }
        Navigator.pop(context, true);
      }
    } else if (state is SessionsError) {
      EasyLoading.showError(state.message);
      // Reset loading state and show error details
      setState(() {});
      _showErrorDialog(context, state.message);
    } else if (state is SessionsLoading) {
      // Show loading indicator with specific message
      EasyLoading.show(
        status: 'جاري معالجة البيانات...',
        maskType: EasyLoadingMaskType.black,
      );
    }
  }

  /// Reset form to initial state
  void _resetForm() {
    _currentStep = 0;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _hasBooklet = false;
    _selectedStudentIds.clear();
    _attendance.clear();
    _lessonPrices.clear();
    _bookletPrices.clear();
    _noteController.clear();
  }

  /// Show error dialog with retry option
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ في إنشاء الحصة'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Retry the operation
              _saveSession();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  /// Build the main content based on SessionsState
  Widget _buildSessionContent(BuildContext context, SessionsState sessionState) {
    // Handle different session states
    if (sessionState is SessionsError) {
      return _buildErrorState(sessionState);
    }

    final isLoading = sessionState is SessionsLoading;

    return Stepper(
      currentStep: _currentStep,
      onStepContinue: isLoading ? null : _onStepContinue,
      onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
      controlsBuilder: (context, details) {
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              if (_currentStep < 2)
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('التالي'),
                ),
              if (_currentStep == 2)
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _saveSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(isLoading ? 'جاري الحفظ...' : 'حفظ الحصة'),
                ),
              const SizedBox(width: 12),
              if (details.onStepCancel != null)
                OutlinedButton(
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
                // Date Selection
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('تاريخ الحصة'),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _pickDate,
                ),
                const Divider(),

                // Time Selection
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('وقت الحصة'),
                  subtitle: Text(_selectedTime.format(context)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: _pickTime,
                ),
                const Divider(),

                // Booklet Checkbox
                CheckboxListTile(
                  title: const Text('يوجد كتيب'),
                  subtitle: const Text('تحقق إذا كان هناك كتيب للحصة'),
                  value: _hasBooklet,
                  onChanged: (value) {
                    setState(() {
                      _hasBooklet = value ?? false;
                    });
                  },
                ),
                const Divider(),

                // Note Field
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    hintText: 'أضف أي ملاحظات حول الحصة',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          isActive: _currentStep >= 0,
        ),

        // Step 2: Select Students
        Step(
          title: const Text('اختيار الطلاب'),
          content: BlocBuilder<StudentsBloc, StudentsState>(
            builder: (context, state) {
              if (state is StudentsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is StudentsLoaded) {
                _availableStudents = state.students.where((s) => s.isActive).toList();

                if (_availableStudents.isEmpty) {
                  return const Center(child: Text('لا يوجد طلاب نشطين'));
                }

                return Column(
                  children: [
                    // Select All / Deselect All
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedStudentIds = _availableStudents.map((s) => s.id).toSet();
                            });
                          },
                          icon: const Icon(Icons.select_all),
                          label: const Text('تحديد الكل'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedStudentIds.clear();
                            });
                          },
                          icon: const Icon(Icons.deselect),
                          label: const Text('إلغاء التحديد'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Students List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _availableStudents.length,
                      itemBuilder: (context, index) {
                        final student = _availableStudents[index];
                        final isSelected = _selectedStudentIds.contains(student.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            title: Text(student.name),
                            subtitle: Text('السنة: ${student.year}'),
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
                          ),
                        );
                      },
                    ),
                  ],
                );
              } else if (state is StudentsError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('خطأ في تحميل الطلاب: ${state.message}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<StudentsBloc>().add(const LoadStudents());
                        },
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
          isActive: _currentStep >= 1,
        ),

        // Step 3: Take Attendance
        Step(
          title: const Text('تسجيل الحضور'),
          content: _buildAttendanceStep(),
          isActive: _currentStep >= 2,
        ),
      ],
    );
  }

  /// Build error state UI
  Widget _buildErrorState(SessionsError errorState) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorState.message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Retry by dispatching a new event
                    context.read<SessionsBloc>().add(const LoadSessions());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('العودة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceStep() {
    if (_selectedStudentIds.isEmpty) {
      return const Center(child: Text('لم يتم تحديد طلاب'));
    }

    final selectedStudents = _availableStudents.where((s) => _selectedStudentIds.contains(s.id)).toList();

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
                final total = isPresent ? lessonPrice + (_hasBooklet ? bookletPrice : 0) : 0;

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
                      isPresent ? '$lessonPrice ج.م${_hasBooklet ? ' + $bookletPrice ج.م = $total ج.م' : ''}' : 'غائب',
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
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    } else if (_currentStep == 1) {
      if (_selectedStudentIds.isNotEmpty) {
        setState(() {
          _currentStep = 2;
        });
      }
    }
  }

  /// Save session with enhanced state handling and validation
  void _saveSession() {
    // Validate form before saving
    if (!_validateSessionData()) {
      return;
    }

    try {
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

      // Dispatch the create session event
      context.read<SessionsBloc>().add(CreateSession(session));
    } catch (e) {
      // Handle any errors during session creation
      EasyLoading.showError('خطأ في إنشاء الحصة: ${e.toString()}');
    }
  }

  /// Validate session data before saving
  bool _validateSessionData() {
    // Check if students are selected
    if (_selectedStudentIds.isEmpty) {
      EasyLoading.showError('يرجى تحديد طلاب للحصة');
      return false;
    }

    // Check if at least one student is present
    final hasPresentStudents = _selectedStudentIds.any((id) => _attendance[id] == true);
    if (!hasPresentStudents) {
      EasyLoading.showError('يجب أن يكون هناك طالب واحد على الأقل حاضر');
      return false;
    }

    // Check if session date is not in the past (except for today)
    final now = DateTime.now();
    final sessionDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (sessionDateTime.isBefore(now.subtract(const Duration(hours: 1)))) {
      EasyLoading.showError('لا يمكن إنشاء حصة في الماضي');
      return false;
    }

    // Check if session date is not too far in the future
    if (sessionDateTime.isAfter(now.add(const Duration(days: 365)))) {
      EasyLoading.showError('لا يمكن إنشاء حصة بعد أكثر من سنة');
      return false;
    }

    return true;
  }
}
