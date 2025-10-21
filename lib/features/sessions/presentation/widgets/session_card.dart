import 'package:flutter/material.dart';
import '../../domain/entities/session.dart';

class SessionCard extends StatelessWidget {
  final Session session;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.session,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final presentCount = session.attendances.where((a) => a.present).length;
    final totalCount = session.attendances.length;
    final totalRevenue = session.attendances
        .where((a) => a.present)
        .fold<double>(
          0,
          (sum, a) => sum + a.sessionCharge + a.bookletCharge,
        );

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
              // Header: Time and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        session.dateTime.toString().split(' ')[1].substring(0, 5),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  if (session.hasBooklet)
                    Chip(
                      avatar: const Icon(Icons.book, size: 16),
                      label: const Text('ملزمة'),
                      backgroundColor: Colors.orange.shade50,
                      labelStyle: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Attendance Info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      icon: Icons.people,
                      label: 'الحضور',
                      value: '$presentCount / $totalCount',
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      context,
                      icon: Icons.monetization_on,
                      label: 'الإيرادات',
                      value: '$totalRevenue ج.م',
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              // Note (if exists)
              if (session.note != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.notes, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          session.note!,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Student Names Preview
              if (session.attendances.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: session.attendances
                      .take(3)
                      .map((a) => Chip(
                            avatar: CircleAvatar(
                              backgroundColor: a.present
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              radius: 10,
                              child: Icon(
                                a.present ? Icons.check : Icons.close,
                                size: 12,
                                color: a.present ? Colors.green : Colors.red,
                              ),
                            ),
                            label: Text(a.studentName),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ))
                      .toList()
                    ..addAll(
                      session.attendances.length > 3
                          ? [
                              Chip(
                                label: Text('+${session.attendances.length - 3}'),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Colors.grey.shade200,
                              )
                            ]
                          : [],
                    ),
                ),
              ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
}

