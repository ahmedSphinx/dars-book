import 'package:flutter/material.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/entities/session_template.dart';
import '../../../students/domain/entities/student.dart';

class TemplateDetailScreen extends StatelessWidget {
  final SessionTemplate template;
  final List<Student>? students;

  const TemplateDetailScreen({
    super.key,
    required this.template,
    this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(template.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(
                context,
                Routes.templateForm,
                arguments: template,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Template Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.event_repeat,
                            color: Theme.of(context).primaryColor,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                template.name,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${template.durationMin} دقيقة',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    
                    // Details
                    _buildDetailRow(
                      context,
                      icon: Icons.access_time,
                      label: 'الوقت الافتراضي',
                      value: template.timeOfDay,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: template.hasBookletDefault ? Icons.book : Icons.event_note,
                      label: 'الملزمة',
                      value: template.hasBookletDefault ? 'يوجد ملزمة' : 'بدون ملزمة',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      icon: Icons.people,
                      label: 'عدد الطلاب',
                      value: '${template.studentIds.length} طالب',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Recurring Days
            if (template.weekdays.isNotEmpty) ...[
              Text(
                'الأيام المتكررة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: template.weekdays.map((day) {
                      return Chip(
                        label: Text(_getDayName(day)),
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Students List
            Text(
              'الطلاب المحددين',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: template.studentIds.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final studentId = template.studentIds[index];
                  // In a real app, you'd fetch student details
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text('طالب $studentId'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            
            // Quick Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    Routes.createSession,
                    arguments: {'template': template},
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('بدء حصة من هذا القالب'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _getDayName(int day) {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return days[day % 7];
  }
}

