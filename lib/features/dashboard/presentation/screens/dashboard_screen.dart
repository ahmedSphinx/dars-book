import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../reports/presentation/bloc/reports_bloc.dart';
import '../../../subscriptions/presentation/bloc/subscription_bloc.dart';
import '../../../security/presentation/bloc/app_lock_bloc.dart';
import '../../../security/presentation/widgets/session_timeout_warning.dart';
import '../../../security/presentation/widgets/session_expired_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboard();
    _checkAppLock();
  }

  void _checkAppLock() {
    context.read<AppLockBloc>().add(CheckLockStatusEvent());
  }

  void _loadDashboard() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    context.read<ReportsBloc>().add(
          LoadDashboardSummary(
            startDate: startOfMonth,
            endDate: endOfMonth,
          ),
        );
  }

  void _startSession() {
    // Only start session if user is already unlocked
    final currentState = context.read<AppLockBloc>().state;
    if (currentState is AppUnlocked) {
      context.read<AppLockBloc>().add(StartSessionEvent());
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsBloc>(),
      child: BlocListener<AppLockBloc, AppLockState>(
        listener: (context, state) {
          if (state is AppLocked) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.appLock,
              (route) => false,
            );
          } else if (state is AppUnlocked) {
            // Start session when user becomes unlocked (after successful authentication)
            _startSession();
          } else if (state is SessionExpired) {
            // Show session expired dialog and navigate to app lock
            SessionExpiredDialog.show(context);
          }
        },
        child: SessionTimeoutWarning(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('لوحة التحكم'),
            actions: [
              IconButton(
                icon: const Icon(Icons.security),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.sessionTest);
                },
                tooltip: 'Session Test',
              ),
              IconButton(
                icon: const Icon(Icons.palette),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.themeTest);
                },
                tooltip: 'Theme Test',
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.settings);
                },
              ),
            ],
            ),
            drawer: _buildDrawer(context),
            body: RefreshIndicator(
            onRefresh: () async {
              _loadDashboard();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subscription Banner
                  BlocBuilder<SubscriptionBloc, SubscriptionState>(
                    builder: (context, state) {
                      if (state is SubscriptionLoaded &&
                          state.subscription != null) {
                        final subscription = state.subscription!;
                        if (subscription.remainingDays <= 7) {
                          return Card(
                            color: Colors.orange.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber,
                                      color: Colors.orange.shade700),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'تبقى ${subscription.remainingDays} يومًا على انتهاء الاشتراك',
                                      style: TextStyle(
                                          color: Colors.orange.shade900),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, Routes.subscription);
                                    },
                                    child: const Text('تجديد الاشتراك'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 16),

                  // Dashboard Summary
                  BlocBuilder<ReportsBloc, ReportsState>(
                    builder: (context, state) {
                      if (state is ReportsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is DashboardSummaryLoaded) {
                        final summary = state.summary;
                        return Column(
                          children: [
                            // Stats Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    title: 'عدد الطلاب',
                                    value: summary.studentsCount.toString(),
                                    icon: Icons.people,
                                    color: Theme.of(context).colorScheme.primary,
                                  ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    title: 'حصص هذا الشهر',
                                    value: summary.sessionsCount.toString(),
                                    icon: Icons.event,
                                    color: Theme.of(context).colorScheme.tertiary,
                                  ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.2, end: 0),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Revenue Card
                            _StatCard(
                              title: 'إجمالي الإيرادات',
                              value:
                                  '${summary.totalRevenue.toStringAsFixed(0)} ج.م',
                              icon: Icons.attach_money,
                              color: Theme.of(context).colorScheme.secondary,
                              isLarge: true,
                            ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 24),

                            // Students Lists
                            if (summary.overdueStudentsCount > 0) ...[
                              _SectionHeader(
                                title: 'طلاب متأخرون',
                                count: summary.overdueStudentsCount,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 8),
                              // TODO: Add overdue students list
                              const SizedBox(height: 16),
                            ],

                            if (summary.onTimeStudentsCount > 0) ...[
                              _SectionHeader(
                                title: 'طلاب منتظمون',
                                count: summary.onTimeStudentsCount,
                                color: Colors.green,
                              ),
                              const SizedBox(height: 8),
                              // TODO: Add on-time students list
                            ],
                          ],
                        );
                      } else if (state is ReportsError) {
                        return Center(child: Text(state.message));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, Routes.createSession);
            },
            icon: const Icon(Icons.add),
            label: const Text('إنشاء حصة'),
          ).animate().scale(duration: 300.ms, delay: 600.ms).fadeIn(),
        ),
      ),
    ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  'DarsBook',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'إدارة الطلاب والحصص',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('لوحة التحكم'),
            selected: true,
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('الطلاب'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.students);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('الحصص'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.sessions);
            },
          ),
          ListTile(
            leading: const Icon(Icons.monetization_on),
            title: const Text('الأسعار'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.pricing);
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('التحصيلات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.collections);
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_repeat),
            title: const Text('القوالب'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.templates);
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('التقارير'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.reports);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.card_membership),
            title: const Text('الاشتراك'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.subscription);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, Routes.settings);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              'تسجيل الخروج',
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.phoneAuth,
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLarge;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isLarge ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isLarge ? 32 : 24),
                const Spacer(),
                if (!isLarge)
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            if (isLarge) ...[
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text('عرض الكل'),
        ),
      ],
    );
  }
}
