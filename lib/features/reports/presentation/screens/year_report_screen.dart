import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../students/presentation/bloc/students_bloc.dart';
import '../../../students/presentation/bloc/students_event.dart';
import '../../../students/presentation/bloc/students_state.dart';
import '../bloc/reports_bloc.dart';

class YearReportScreen extends StatefulWidget {
  const YearReportScreen({super.key});

  @override
  State<YearReportScreen> createState() => _YearReportScreenState();
}

class _YearReportScreenState extends State<YearReportScreen> {
  String? _selectedYear;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load students to get available years
    context.read<StudentsBloc>().add(const LoadStudents());
  }

  void _loadReport() {
    if (_selectedYear != null) {
      context.read<ReportsBloc>().add(
        LoadYearReport(
          year: _selectedYear!,
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
        title: const Text('تقرير السنة الدراسية'),
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
              // Year Selection
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
                    final years = studentsState.students
                        .where((s) => s.isActive)
                        .map((s) => s.year)
                        .toSet()
                        .toList()
                      ..sort((a, b) => b.compareTo(a)); // Sort descending

                    if (years.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('لا توجد سنوات دراسية'),
                        ),
                      );
                    }
                    if (_selectedYear == null && years.isNotEmpty) {
                      _selectedYear = years.first;
                      WidgetsBinding.instance.addPostFrameCallback((_) => _loadReport());
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('اختر السنة الدراسية', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedYear,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'السنة الدراسية',
                              ),
                              items: years.map((year) {
                                return DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedYear = value;
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
                  } else if (state is YearReportLoaded) {
                    final report = state.report;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Year Header
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor.withAlpha(26),
                                  child: const Icon(Icons.school, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'السنة الدراسية ${report.year}',
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
                              icon: Icons.people,
                              label: 'عدد الطلاب',
                              value: '${report.studentsCount}',
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              context,
                              icon: Icons.event,
                              label: 'عدد الحصص',
                              value: '${report.sessionsCount}',
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              context,
                              icon: Icons.book,
                              label: 'عدد الكراسات',
                              value: '${report.bookletsCount}',
                              color: Colors.purple,
                            ),
                            _buildStatCard(
                              context,
                              icon: Icons.attach_money,
                              label: 'إجمالي الإيرادات',
                              value: '${report.totalRevenue.toStringAsFixed(0)} ج.م',
                              color: Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Revenue Breakdown
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('تفصيل الإيرادات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('إيرادات الحصص'),
                                          Text(
                                            '${report.lessonsRevenue.toStringAsFixed(0)} ج.م',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('إيرادات الكراسات'),
                                          Text(
                                            '${report.bookletsRevenue.toStringAsFixed(0)} ج.م',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
                  return const Center(child: Text('اختر سنة دراسية لعرض التقرير'));
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
