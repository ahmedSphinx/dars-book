import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/routes.dart';
import '../bloc/reports_bloc.dart';

class ReportsDashboardScreen extends StatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    context.read<ReportsBloc>().add(
          LoadDashboardSummary(
            startDate: _startDate,
            endDate: _endDate,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('التقارير'),
          actions: [
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: _selectDateRange,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async => _loadReport(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Range Card
                Card(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
                
                // Summary Stats
                BlocBuilder<ReportsBloc, ReportsState>(
                  builder: (context, state) {
                    if (state is ReportsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DashboardSummaryLoaded) {
                      final summary = state.summary;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Revenue Card (Big)
                          Card(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade400,
                                    Colors.green.shade600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.attach_money, color: Colors.white, size: 32),
                                      const SizedBox(width: 8),
                                      Text(
                                        'إجمالي الإيرادات',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${summary.totalRevenue.toStringAsFixed(0)} ج.م',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Other Stats Grid
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
                                value: '${summary.sessionsCount}',
                                color: Colors.blue,
                              ),
                              _buildStatCard(
                                context,
                                icon: Icons.people,
                                label: 'عدد الطلاب',
                                value: '${summary.studentsCount}',
                                color: Colors.purple,
                              ),
                              _buildStatCard(
                                context,
                                icon: Icons.warning_amber,
                                label: 'طلاب متأخرين',
                                value: '${summary.overdueStudentsCount}',
                                color: Colors.orange,
                              ),
                              _buildStatCard(
                                context,
                                icon: Icons.check_circle,
                                label: 'طلاب منتظمين',
                                value: '${summary.onTimeStudentsCount}',
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      );
                    } else if (state is ReportsError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: 24),
                
                // Quick Links
                Text(
                  'تقارير تفصيلية',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildReportLink(
                  context,
                  icon: Icons.person,
                  title: 'تقرير الطالب',
                  subtitle: 'عرض تفاصيل طالب معين',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.studentReport);
                  },
                ),
                _buildReportLink(
                  context,
                  icon: Icons.school,
                  title: 'تقرير السنة الدراسية',
                  subtitle: 'مقارنة بين السنوات الدراسية',
                  onTap: () {
                    Navigator.pushNamed(context, Routes.yearReport);
                  },
                ),
                _buildReportLink(
                  context,
                  icon: Icons.picture_as_pdf,
                  title: 'تصدير PDF',
                  subtitle: 'تحميل تقرير بصيغة PDF',
                  onTap: () {
                    EasyLoading.showToast('سيتم إضافة هذه الميزة قريبًا');
                  },
                ),
                _buildReportLink(
                  context,
                  icon: Icons.table_chart,
                  title: 'تصدير Excel',
                  subtitle: 'تحميل البيانات بصيغة CSV',
                  onTap: () {
                    EasyLoading.showToast('سيتم إضافة هذه الميزة قريبًا');
                  },
                ),
              ],
            ),
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
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportLink(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
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

