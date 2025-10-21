import 'package:flutter/material.dart';
import '../../domain/entities/student.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  const StudentCard({
    super.key,
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final hasOverdue = student.aggregates.remaining > 0;
    final isInactive = !student.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and status
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isInactive
                        ? Colors.grey.shade300
                        : hasOverdue
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                    child: Text(
                      student.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isInactive
                            ? Colors.grey.shade700
                            : hasOverdue
                                ? Colors.red.shade700
                                : Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and Year
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isInactive ? Colors.grey : null,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          student.year,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  if (isInactive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'غير نشط',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Financial Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    context,
                    'عدد الحصص',
                    student.aggregates.sessionsCount.toString(),
                    Icons.event,
                  ),
                  _buildInfoItem(
                    context,
                    'إجمالي المبلغ',
                    '${student.aggregates.totalCharges.toStringAsFixed(0)} جنيه',
                    Icons.attach_money,
                  ),
                  _buildInfoItem(
                    context,
                    'المبلغ المتبقي',
                    '${student.aggregates.remaining.toStringAsFixed(0)} جنيه',
                    Icons.payment,
                    color: hasOverdue ? Colors.red : Colors.green,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text('تعديل'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onToggleActive,
                      icon: Icon(
                        isInactive ? Icons.check_circle : Icons.pause_circle,
                        size: 18,
                      ),
                      label: Text(isInactive ? 'تفعيل' : 'إيقاف'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color ?? Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

