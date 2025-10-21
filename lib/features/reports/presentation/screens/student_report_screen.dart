import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../students/presentation/bloc/students_bloc.dart';
import '../../../students/presentation/bloc/students_event.dart';
import '../../../students/presentation/bloc/students_state.dart';
import '../bloc/reports_bloc.dart';

class StudentReportScreen extends StatefulWidget {
  const StudentReportScreen({super.key});

  @override
  State<StudentReportScreen> createState() => _StudentReportScreenState();
}

class _StudentReportScreenState extends State<StudentReportScreen> {
  String? _selectedStudentId;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load students via bloc if not loaded
    context.read<StudentsBloc>().add(const LoadStudents());
  }

  void _loadReport() {
    if (_selectedStudentId != null) {
      context.read<ReportsBloc>().add(
        LoadStudentReport(
          studentId: _selectedStudentId!,
          startDate: _startDate,
          endDate: _endDate,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقرير الطالب'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadReport();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Selection
              BlocBuilder<StudentsBloc, StudentsState>(
                builder: (context, studentsState) {
                  if (studentsState is StudentsLoading) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  } else if (studentsState is StudentsLoaded) {
                    final students = studentsState.students.where((s) => s.isActive).toList();
                    if (students.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('لا يوجد طلاب'),
                        ),
                      );
                    }
                    if (_selectedStudentId == null && students.isNotEmpty) {
                      _selectedStudentId = students.first.id;
                      WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('اختر الطالب', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedStudentId,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'الطالب',
                              ),
                              items: students.map((student) {
                                return DropdownMenuItem(
                                  value: student.id,
                                  child: Text(student.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedStudentId = value;
                                });
                                _loadReport();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 16),

              // Date Range Card
              Card(
                color: Theme.of(context).primaryColor.withAlpha(26),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('الفترة المحددة'),
                            Text(
                              '${_startDate.toString().split(' ')[0]} - ${_endDate.toString().split(' ')[0]}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _selectDateRange,
                        child: const Text('تغيير'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Report Data
              BlocBuilder<ReportsBloc, ReportsState>(
                builder: (context, state) {
                  if (state is ReportsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StudentReportLoaded) {
                    final report = state.report;
                    final percentage = report.totalCharges > 0 ? (report.totalPaid / report.totalCharges * 100) : 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student Name Header
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
                                  child: Text(report.studentName[0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    report.studentName,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Stats Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatCard(
                              context,
                              icon: Icons.event,
                              label: 'عدد الحصص',
                              value: '${report.sessionsCount}',
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              context,
                              icon: Icons.book,
                              label: 'عدد الكراسات',
                              value: '${report.bookletsCount}',
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              context,
                              icon: Icons.attach_money,
                              label: 'إجمالي الفواتير',
                              value: '${report.totalCharges.toStringAsFixed(0)} ج.م',
                              color: Colors.purple,
                            ),
                            _buildStatCard(
                              context,
                              icon: Icons.payment,
                              label: 'المسدد',
                              value: '${report.totalPaid.toStringAsFixed(0)} ج.م',
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Remaining and Progress
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('المتبقي للدفع'),
                                    Text(
                                      '${report.remaining.toStringAsFixed(0)} ج.م',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: report.remaining > 0 ? Colors.red : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('نسبة السداد'),
                                    Text('${percentage.toStringAsFixed(0)}%'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      percentage < 50 ? Colors.red : percentage < 80 ? Colors.orange : Colors.green,
                                    ),
                                    minHeight: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (state is ReportsError) {
                    return Center(
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadReport,
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('اختر طالب لعرض التقرير'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReport();
    }
  }
}
