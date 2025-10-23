import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/routes.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../reports/presentation/bloc/reports_bloc.dart';
import '../../../subscriptions/presentation/bloc/subscription_bloc.dart';
import '../../../security/presentation/bloc/app_lock_bloc.dart';
import '../../../security/presentation/widgets/session_timeout_warning.dart';
import '../../../students/domain/entities/student.dart';
import '../../../students/presentation/bloc/students_bloc.dart';
import '../../../students/presentation/bloc/students_event.dart';
import '../../../students/presentation/bloc/students_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  AnimationController? _fabAnimationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDashboard();
    // _checkAppLock();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutCubic,
    ));

    _animationController!.forward();
    _fabAnimationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _fabAnimationController?.dispose();
    super.dispose();
  }

  void _checkAppLock() {
    // Only check if we're not already in a locked state
    final currentState = context.read<AppLockBloc>().state;
    if (currentState is! AppLocked && currentState is! AppLockInitial) {
      // Add a small delay to prevent rapid state changes
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          final updatedState = context.read<AppLockBloc>().state;
          if (updatedState is! AppLocked) {
            context.read<AppLockBloc>().add(CheckLockStatusEvent());
          }
        }
      });
    }
  }

  void _loadDashboard() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Load dashboard data
    context.read<ReportsBloc>().add(
          LoadDashboardSummary(
            startDate: startOfMonth,
            endDate: endOfMonth,
          ),
        );

    // Load students for lists
    context.read<StudentsBloc>().add(LoadStudents());
  }

  void _startSession() {
    // Always try to start session - let the BLoC handle state validation
    context.read<AppLockBloc>().add(StartSessionEvent());
  }

  Future<void> _refreshDashboard() async {
    _loadDashboard();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Cleanup resources when transitioning to locked state
  void _cleanupResources() {
    // Stop animations to prevent memory leaks
    _animationController?.stop();
    _fabAnimationController?.stop();

    // Clear any pending operations
    // Note: BLoC subscriptions are automatically managed by Flutter
  }

  /// Navigate to lock screen with proper error handling
  void _navigateToLockScreen(BuildContext context) {
    try {
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.appLock,
        (route) => false,
      );
    } catch (e) {
      // Fallback navigation if named route fails
      debugPrint('Failed to navigate to lock screen: $e');
      // Could implement fallback navigation here if needed
    }
  }

  bool get _areAnimationsReady =>
      _animationController != null &&
      _fabAnimationController != null &&
      _fadeAnimation != null &&
      _slideAnimation != null;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ReportsBloc>()),
        BlocProvider(create: (_) => sl<StudentsBloc>()),
      ],
      child: BlocListener<AppLockBloc, AppLockState>(
        listener: (context, state) {
          if (state is AppLocked) {
            // Cleanup resources before navigation
            _cleanupResources();

            // Navigate to lock screen with proper error handling
            _navigateToLockScreen(context);
          } else if (state is AppUnlocked) {
            _startSession();
          } else if (state is SessionExpired) {
            //  SessionExpiredDialog.show(context);
          } else if (state is AppLockError) {
            // Handle AppLock errors gracefully
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في الأمان: ${state.message}'),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'إعادة المحاولة',
                  onPressed: _checkAppLock,
                ),
              ),
            );
          } else if (state is BiometricErrorState) {
            // Handle biometric errors
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('خطأ في البصمة: ${state.error.userFriendlyMessage}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        child: SessionTimeoutWarning(
          child: Scaffold(
            appBar: _buildAppBar(context),
            drawer: _buildDrawer(context),
            body: RefreshIndicator(
              onRefresh: _refreshDashboard,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.all(16.w),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Subscription Banner
                        _buildSubscriptionBanner(context),
                        SizedBox(height: 16.h),

                        // Dashboard Summary
                        _buildDashboardSummary(context),
                        SizedBox(height: 24.h),

                        // Quick Actions
                        _buildQuickActions(context),
                        SizedBox(height: 24.h),

                        // Students Lists
                        _buildStudentsLists(context),
                        SizedBox(height: 100.h), // Space for FAB
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: _buildFloatingActionButton(context),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),
        ),
      ),
    );
  }

  // App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(
        'لوحة التحكم',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: [
        // Session Status Indicator
        BlocBuilder<AppLockBloc, AppLockState>(
          builder: (context, state) {
            if (state is SessionActive) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${state.remainingSeconds}s',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is AppLocked) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      size: 16,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'مقفل',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        IconButton(
          icon: const Icon(Icons.security),
          onPressed: () => Navigator.pushNamed(context, Routes.sessionTest),
          tooltip: 'Session Test',
        ),
        IconButton(
          icon: const Icon(Icons.palette),
          onPressed: () => Navigator.pushNamed(context, Routes.themeTest),
          tooltip: 'Theme Test',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, Routes.settings),
        ),
      ],
      elevation: 0,
      scrolledUnderElevation: 1,
    );
  }

  // Drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildDrawerHeader(context),
          _buildDrawerItems(context),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            child: Icon(
              Icons.school,
              size: 32.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'DarsBook',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            'إدارة الطلاب والحصص',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onPrimary
                      .withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItems(BuildContext context) {
    final drawerItems = [
      _DrawerItem(Icons.dashboard, 'لوحة التحكم', Routes.dashboard, true),
      _DrawerItem(Icons.people, 'الطلاب', Routes.students, false),
      _DrawerItem(Icons.event, 'الحصص', Routes.sessions, false),
      _DrawerItem(Icons.monetization_on, 'الأسعار', Routes.pricing, false),
      _DrawerItem(Icons.payments, 'التحصيلات', Routes.collections, false),
      _DrawerItem(Icons.event_repeat, 'القوالب', Routes.templates, false),
      _DrawerItem(Icons.analytics, 'التقارير', Routes.reports, false),
    ];

    return Column(
      children: [
        ...drawerItems.map((item) => _buildDrawerTile(context, item)),
        const Divider(),
        _buildDrawerTile(
          context,
          _DrawerItem(
              Icons.card_membership, 'الاشتراك', Routes.subscription, false),
        ),
        _buildDrawerTile(
          context,
          _DrawerItem(Icons.settings, 'الإعدادات', Routes.settings, false),
        ),
        const Divider(),
        _buildDrawerTile(
          context,
          _DrawerItem(Icons.logout, 'تسجيل الخروج', '', false, isLogout: true),
        ),
      ],
    );
  }

  Widget _buildDrawerTile(BuildContext context, _DrawerItem item) {
    return ListTile(
      leading: Icon(
        item.icon,
        color: item.isLogout ? Colors.red : null,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: item.isLogout ? Colors.red : null,
        ),
      ),
      selected: item.isSelected,
      onTap: () {
        Navigator.pop(context);
        if (item.isLogout) {
          _showLogoutDialog(context);
        } else if (item.route.isNotEmpty) {
          Navigator.pushNamed(context, item.route);
        }
      },
    );
  }

  // Subscription Banner
  Widget _buildSubscriptionBanner(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoaded && state.subscription != null) {
          final subscription = state.subscription!;
          if (subscription.remainingDays <= 7) {
            return _areAnimationsReady
                ? FadeTransition(
                    opacity: _fadeAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: Card(
                        elevation: 2,
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.orange.shade700,
                                size: 24.sp,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'تبقى ${subscription.remainingDays} يومًا على انتهاء الاشتراك',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, Routes.subscription),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.orange.shade700,
                                ),
                                child: const Text('تجديد الاشتراك'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Card(
                    elevation: 2,
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Colors.orange.shade700,
                            size: 24.sp,
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'تبقى ${subscription.remainingDays} يومًا على انتهاء الاشتراك',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pushNamed(
                                context, Routes.subscription),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                            ),
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
    );
  }

  // Dashboard Summary
  Widget _buildDashboardSummary(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return _buildLoadingSkeleton();
        } else if (state is DashboardSummaryLoaded) {
          final summary = state.summary;
          return _areAnimationsReady
              ? FadeTransition(
                  opacity: _fadeAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: Column(
                      children: [
                        // Stats Cards Grid
                        _buildStatsGrid(context, summary),
                        SizedBox(height: 16.h),

                        // Revenue Card
                        _buildRevenueCard(context, summary),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Stats Cards Grid
                    _buildStatsGrid(context, summary),
                    SizedBox(height: 16.h),

                    // Revenue Card
                    _buildRevenueCard(context, summary),
                  ],
                );
        } else if (state is ReportsError) {
          return _buildErrorState(context, state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsGrid(BuildContext context, dynamic summary) {
    return Row(
      children: [
        Expanded(
          child: _ModernStatCard(
            title: 'عدد الطلاب',
            value: summary.studentsCount.toString(),
            icon: Icons.people,
            color: Theme.of(context).colorScheme.primary,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _ModernStatCard(
            title: 'حصص هذا الشهر',
            value: summary.sessionsCount.toString(),
            icon: Icons.event,
            color: Theme.of(context).colorScheme.tertiary,
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                Theme.of(context)
                    .colorScheme
                    .tertiaryContainer
                    .withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCard(BuildContext context, dynamic summary) {
    return _ModernStatCard(
      title: 'إجمالي الإيرادات',
      value: '${summary.totalRevenue.toStringAsFixed(0)} ج.م',
      icon: Icons.attach_money,
      color: Theme.of(context).colorScheme.secondary,
      isLarge: true,
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          Theme.of(context)
              .colorScheme
              .secondaryContainer
              .withValues(alpha: 0.1),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSkeletonCard(height: 120.h)),
            SizedBox(width: 12.w),
            Expanded(child: _buildSkeletonCard(height: 120.h)),
          ],
        ),
        SizedBox(height: 16.h),
        _buildSkeletonCard(height: 100.h),
      ],
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Card(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            FilledButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Actions
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.add_circle,
        title: 'حصة جديدة',
        subtitle: 'إنشاء حصة جديدة',
        color: Theme.of(context).colorScheme.primary,
        onTap: () => Navigator.pushNamed(context, Routes.createSession),
      ),
      _QuickAction(
        icon: Icons.people_alt,
        title: 'إضافة طالب',
        subtitle: 'تسجيل طالب جديد',
        color: Theme.of(context).colorScheme.tertiary,
        onTap: () => Navigator.pushNamed(context, Routes.students),
      ),
      _QuickAction(
        icon: Icons.analytics,
        title: 'التقارير',
        subtitle: 'عرض التقارير',
        color: Theme.of(context).colorScheme.secondary,
        onTap: () => Navigator.pushNamed(context, Routes.reports),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: _buildQuickActionCard(context, actions[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, _QuickAction action) {
    return SizedBox(
      width: 140.w,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: action.onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 24.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  action.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  action.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Students Lists
  Widget _buildStudentsLists(BuildContext context) {
    return BlocBuilder<StudentsBloc, StudentsState>(
      builder: (context, state) {
        if (state is StudentsLoaded) {
          final students = state.students;
          final overdueStudents =
              students.where((s) => _isStudentOverdue(s)).toList();
          final onTimeStudents =
              students.where((s) => !_isStudentOverdue(s)).toList();

          return Column(
            children: [
              if (overdueStudents.isNotEmpty) ...[
                _buildStudentSection(
                  context,
                  'طلاب متأخرون',
                  overdueStudents,
                  Colors.red,
                  Routes.students,
                ),
                SizedBox(height: 16.h),
              ],
              if (onTimeStudents.isNotEmpty) ...[
                _buildStudentSection(
                  context,
                  'طلاب منتظمون',
                  onTimeStudents,
                  Colors.green,
                  Routes.students,
                ),
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStudentSection(
    BuildContext context,
    String title,
    List<Student> students,
    Color color,
    String route,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ModernSectionHeader(
          title: title,
          count: students.length,
          color: color,
          onViewAll: () => Navigator.pushNamed(context, route),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: students.length > 5 ? 5 : students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: _buildStudentCard(context, student, color),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStudentCard(BuildContext context, Student student, Color color) {
    return SizedBox(
      width: 100.w,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, Routes.students),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Text(
                    student.name.isNotEmpty
                        ? student.name[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  student.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${student.aggregates.sessionsCount} حصة',
                    style: TextStyle(
                      color: color,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Floating Action Button
  Widget _buildFloatingActionButton(BuildContext context) {
    return _areAnimationsReady
        ? FadeTransition(
            opacity: _fadeAnimation!,
            child: ScaleTransition(
              scale: _fadeAnimation!,
              child: FloatingActionButton.extended(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.createSession),
                icon: const Icon(Icons.add),
                label: const Text('إنشاء حصة'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          )
        : FloatingActionButton.extended(
            onPressed: () => Navigator.pushNamed(context, Routes.createSession),
            icon: const Icon(Icons.add),
            label: const Text('إنشاء حصة'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          );
  }

  // Helper Methods
  bool _isStudentOverdue(Student student) {
    // Simple logic to determine if student is overdue
    // This should be replaced with actual business logic
    return student.aggregates.remaining > 0;
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
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(SignOutRequested());
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.phoneAuth,
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

// Helper Classes
class _DrawerItem {
  final IconData icon;
  final String title;
  final String route;
  final bool isSelected;
  final bool isLogout;

  const _DrawerItem(
    this.icon,
    this.title,
    this.route,
    this.isSelected, {
    this.isLogout = false,
  });
}

class _QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

// Modern Stat Card
class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLarge;
  final Gradient? gradient;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLarge = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: gradient,
        ),
        child: Padding(
          padding: EdgeInsets.all(isLarge ? 20.w : 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: isLarge ? 28.sp : 24.sp,
                    ),
                  ),
                  const Spacer(),
                  if (!isLarge)
                    Text(
                      value,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
              ),
              if (isLarge) ...[
                SizedBox(height: 8.h),
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
      ),
    );
  }
}

// Modern Section Header
class _ModernSectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final VoidCallback? onViewAll;

  const _ModernSectionHeader({
    required this.title,
    required this.count,
    required this.color,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ),
        const Spacer(),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text('عرض الكل'),
          ),
      ],
    );
  }
}
