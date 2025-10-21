import 'package:flutter/material.dart';
import '../../domain/entities/session_template.dart';

class TemplateCard extends StatelessWidget {
  final SessionTemplate template;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onQuickStart;

  const TemplateCard({
    super.key,
    required this.template,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onQuickStart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          '${template.durationMin} دقيقة',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, size: 20, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('خذف', style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      icon: Icons.people,
                      label: 'الطلاب',
                      value: '${template.studentIds.length}',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      icon: Icons.access_time,
                      label: 'الوقت',
                      value: template.timeOfDay,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      icon: template.hasBookletDefault ? Icons.book : Icons.event_note,
                      label: template.hasBookletDefault ? 'ملزمة' : 'بدون ملزمة',
                      value: '',
                      color: template.hasBookletDefault ? Colors.orange : Colors.grey,
                    ),
                  ),
                ],
              ),
              
              // Recurring Days
              if (template.weekdays.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: template.weekdays.map((day) {
                    return Chip(
                      label: Text(_getDayName(day)),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  }).toList(),
                ),
              ],
              
              const SizedBox(height: 12),
              
              // Quick Start Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onQuickStart,
                  icon: const Icon(Icons.play_arrow),
                  label: Text('ابداء الان'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
        ],
      ),
    );
  }

  String _getDayName(int day) {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return days[day % 7];
  }
}

