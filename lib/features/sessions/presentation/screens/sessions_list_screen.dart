import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/sessions_bloc.dart';
import '../widgets/session_card.dart';
import 'create_session_screen.dart';

class SessionsListScreen extends StatelessWidget {
  const SessionsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SessionsBloc>()..add(const LoadSessions()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الحصص'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<SessionsBloc, SessionsState>(
          builder: (context, state) {
            if (state is SessionsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SessionsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<SessionsBloc>().add(const LoadSessions());
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            } else if (state is SessionsLoaded) {
              if (state.sessions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد حصص بعد',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'ابدأ بإنشاء أول حصة لك',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Group sessions by date
              final groupedSessions = <String, List>{};
              for (var session in state.sessions) {
                final dateKey = session.dateTime.toString().split(' ')[0];
                groupedSessions.putIfAbsent(dateKey, () => []).add(session);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedSessions.length,
                itemBuilder: (context, index) {
                  final dateKey = groupedSessions.keys.elementAt(index);
                  final sessions = groupedSessions[dateKey]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateKey,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Spacer(),
                            Chip(
                              label: Text('${sessions.length}'),
                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            ),
                          ],
                        ),
                      ),
                      
                      // Sessions for this date
                      ...sessions.map((session) => SessionCard(
                            session: session,
                            onTap: () {
                              // Navigate to session detail
                            },
                          )),
                      
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateSessionScreen(),
              ),
            ).then((_) {
              // Reload sessions
              if (context.mounted) {
                context.read<SessionsBloc>().add(const LoadSessions());
              }
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('حصة جديدة'),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تصفية الحصص'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('اليوم'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<SessionsBloc>().add(LoadSessionsByDateRange(
                      startDate: DateTime.now().subtract(const Duration(days: 1)),
                      endDate: DateTime.now(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('هذا الأسبوع'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<SessionsBloc>().add(LoadSessionsByDateRange(
                      startDate: DateTime.now().subtract(const Duration(days: 7)),
                      endDate: DateTime.now(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('هذا الشهر'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<SessionsBloc>().add(LoadSessionsByDateRange(
                      startDate: DateTime.now().subtract(const Duration(days: 30)),
                      endDate: DateTime.now(),
                    ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('الكل'),
              onTap: () {
                Navigator.pop(dialogContext);
                context.read<SessionsBloc>().add(const LoadSessions());
              },
            ),
          ],
        ),
      ),
    );
  }
}

