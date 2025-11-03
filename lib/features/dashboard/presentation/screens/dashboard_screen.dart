import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/services/app_logging_services.dart';
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

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  AnimationController? _animationController;
  AnimationController? _fabAnimationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Load dashboard data after a short delay to ensure BLoCs are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
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

    AppLogging.logInfo('🔄 Loading dashboard data...');
    AppLogging.logInfo('📅 Date range: ${startOfMonth.toIso8601String()} to ${endOfMonth.toIso8601String()}');

    try {
      // Check if BLoCs are available
      final reportsBloc = context.read<ReportsBloc>();
      final studentsBloc = context.read<StudentsBloc>();
      final subscriptionBloc = context.read<SubscriptionBloc>();

      AppLogging.logInfo('📊 BLoCs available: ReportsBloc=${reportsBloc.runtimeType}, StudentsBloc=${studentsBloc.runtimeType}, SubscriptionBloc=${subscriptionBloc.runtimeType}');

      // Load dashboard data
      reportsBloc.add(LoadDashboardSummary(startDate: startOfMonth, endDate: endOfMonth));
      AppLogging.logInfo('📊 Dispatched LoadDashboardSummary event');

      // Load students for lists
      studentsBloc.add(const LoadStudents());
      AppLogging.logInfo('👥 Dispatched LoadStudents event');

      // Load subscription data
      subscriptionBloc.add(const LoadSubscription());
      AppLogging.logInfo('💳 Dispatched LoadSubscription event');
    } catch (e) {
      AppLogging.logError('❌ Error loading dashboard data: $e');
      // Retry after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          AppLogging.logInfo('🔄 Retrying dashboard data load...');
          _loadDashboard();
        }
      });
    }
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
      AppLogging.logError('Failed to navigate to lock screen: $e');
      // Could implement fallback navigation here if needed
    }
  }

  bool get _areAnimationsReady => _animationController != null && _fabAnimationController != null && _fadeAnimation != null && _slideAnimation != null;

  /// Handle AppLock state changes
  void _handleAppLockState(BuildContext context, AppLockState state) {
    if (state is AppLocked) {
      // Cleanup resources before navigation
      _cleanupResources();
      // Navigate to lock screen with proper error handling
      _navigateToLockScreen(context);
    } else if (state is AppUnlocked) {
      _startSession();
    } else if (state is SessionExpired) {
      // SessionExpiredDialog.show(context); // Handled in app.dart
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
          content: Text('خطأ في البصمة: ${state.error.userFriendlyMessage}'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Handle Subscription state changes
  void _handleSubscriptionState(BuildContext context, SubscriptionState state) {
    AppLogging.logInfo('💳 SubscriptionState: ${state.runtimeType}');

    if (state is SubscriptionError) {
      AppLogging.logError('❌ SubscriptionError: ${state.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الاشتراك: ${state.message}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            onPressed: () {
              context.read<SubscriptionBloc>().add(LoadSubscription());
            },
          ),
        ),
      );
    } else if (state is SubscriptionRedeemed) {
      AppLogging.logInfo('✅ SubscriptionRedeemed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم استرداد الاشتراك بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state is SubscriptionLoaded) {
      AppLogging.logInfo('✅ SubscriptionLoaded: ${state.subscription != null ? 'Active' : 'No subscription'}');
    } else if (state is SubscriptionLoading) {
      AppLogging.logInfo('⏳ SubscriptionLoading...');
    }
  }

  /// Handle Students state changes
  void _handleStudentsState(BuildContext context, StudentsState state) {
    AppLogging.logInfo('👥 StudentsState: ${state.runtimeType}');

    if (state is StudentsError) {
      AppLogging.logError('❌ StudentsError: ${state.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل الطلاب: ${state.message}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            onPressed: () {
              context.read<StudentsBloc>().add(const LoadStudents());
            },
          ),
        ),
      );
    } else if (state is StudentsLoaded) {
      AppLogging.logInfo('✅ StudentsLoaded: ${state.students.length} students');
    } else if (state is StudentsLoading) {
      AppLogging.logInfo('⏳ StudentsLoading...');
    }
  }

  /// Handle Reports state changes
  void _handleReportsState(BuildContext context, ReportsState state) {
    AppLogging.logInfo('📊 ReportsState: ${state.runtimeType}');

    if (state is ReportsError) {
      AppLogging.logError('❌ ReportsError: ${state.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحميل التقارير: ${state.message}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            onPressed: () {
              _loadDashboard();
            },
          ),
        ),
      );
    } else if (state is DashboardSummaryLoaded) {
      AppLogging.logInfo('✅ DashboardSummaryLoaded: ${state.summary}');
    } else if (state is ReportsLoading) {
      AppLogging.logInfo('⏳ ReportsLoading...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ReportsBloc>()),
        BlocProvider(create: (_) => sl<StudentsBloc>()),
        BlocProvider(create: (_) => sl<SubscriptionBloc>()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AppLockBloc, AppLockState>(
            listener: (context, state) {
              _handleAppLockState(context, state);
            },
          ),
          BlocListener<SubscriptionBloc, SubscriptionState>(
            listener: (context, state) {
              _handleSubscriptionState(context, state);
            },
          ),
          BlocListener<StudentsBloc, StudentsState>(
            listener: (context, state) {
              _handleStudentsState(context, state);
            },
          ),
          BlocListener<ReportsBloc, ReportsState>(
            listener: (context, state) {
              _handleReportsState(context, state);
            },
          ),
        ],
        child: SessionTimeoutWarning(
          child: Scaffold(
            appBar: _buildModernAppBar(context),
            drawer: _buildModernDrawer(context),
            body: _buildModernBody(context),
            floatingActionButton: _buildModernFloatingActionButton(context),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: _buildBottomNavigationBar(context),
          ),
        ),
      ),
    );
  }

  /// Build modern app bar with enhanced UX
  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.dashboard_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'لوحة التحكم',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Text(
                'مرحباً بك',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 2,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      actions: [
        _buildSessionStatusIndicator(context),
        _buildNotificationButton(context),
        _buildSettingsButton(context),
        SizedBox(width: 8.w),
      ],
    );
  }

  /// Build session status indicator with enhanced animations
  Widget _buildSessionStatusIndicator(BuildContext context) {
    return BlocBuilder<AppLockBloc, AppLockState>(
      builder: (context, state) {
        if (state is SessionActive) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.shade400,
                  Colors.green.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_rounded,
                  size: 16.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${state.remainingSeconds}s',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        } else if (state is AppLocked) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: 8.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.shade400,
                  Colors.red.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 16.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 4.w),
                Text(
                  'مقفل',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Build notification button with badge
  Widget _buildNotificationButton(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            size: 24.sp,
          ),
          onPressed: () {
            // TODO: Implement notifications
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('قريباً: نظام الإشعارات')),
            );
          },
          tooltip: 'الإشعارات',
        ),
        Positioned(
          right: 8.w,
          top: 8.h,
          child: Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
      ],
    );
  }

  /// Build settings button with haptic feedback
  Widget _buildSettingsButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.settings_outlined,
        size: 24.sp,
      ),
      onPressed: () {
        // Add haptic feedback
        // HapticFeedback.lightImpact();
        Navigator.pushNamed(context, Routes.settings);
      },
      tooltip: 'الإعدادات',
    );
  }

  /// Build modern body with enhanced scroll behavior
  Widget _buildModernBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Hero section with gradient background
          SliverToBoxAdapter(
            child: _buildHeroSection(context),
          ),

          // Main content with proper spacing
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Debug/Refresh Button (temporary)
                _buildDebugSection(context),
                SizedBox(height: 16.h),

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
    );
  }

  /// Build debug section for testing data loading
  Widget _buildDebugSection(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              'Debug Section',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    AppLogging.logInfo('🔄 Manual refresh triggered');
                    _loadDashboard();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    AppLogging.logInfo('📊 Testing ReportsBloc state');
                    final reportsBloc = context.read<ReportsBloc>();
                    AppLogging.logInfo('ReportsBloc current state: ${reportsBloc.state}');
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text('Check State'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build hero section with welcome message
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      height: 120.h,
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
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'مرحباً بك في DarsBook',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 4.h),
              Text(
                'إدارة طلابك وحصصك بسهولة',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build modern drawer with enhanced design
  Widget _buildModernDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildModernDrawerHeader(context),
          Expanded(
            child: _buildModernDrawerItems(context),
          ),
          _buildModernDrawerFooter(context),
        ],
      ),
    );
  }

  /// Build modern drawer header
  Widget _buildModernDrawerHeader(BuildContext context) {
    return Container(
      height: 200.h,
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
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                child: Icon(
                  Icons.school_rounded,
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
                      color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build modern drawer items
  Widget _buildModernDrawerItems(BuildContext context) {
    final drawerItems = [
      _ModernDrawerItem(
        icon: Icons.dashboard_rounded,
        title: 'لوحة التحكم',
        route: Routes.dashboard,
        isSelected: true,
      ),
      _ModernDrawerItem(
        icon: Icons.people_rounded,
        title: 'الطلاب',
        route: Routes.students,
        isSelected: false,
      ),
      _ModernDrawerItem(
        icon: Icons.event_rounded,
        title: 'الحصص',
        route: Routes.sessions,
        isSelected: false,
      ),
      _ModernDrawerItem(
        icon: Icons.monetization_on_rounded,
        title: 'الأسعار',
        route: Routes.pricing,
        isSelected: false,
      ),
      _ModernDrawerItem(
        icon: Icons.payments_rounded,
        title: 'التحصيلات',
        route: Routes.collections,
        isSelected: false,
      ),
      _ModernDrawerItem(
        icon: Icons.event_repeat_rounded,
        title: 'القوالب',
        route: Routes.templates,
        isSelected: false,
      ),
      _ModernDrawerItem(
        icon: Icons.analytics_rounded,
        title: 'التقارير',
        route: Routes.reports,
        isSelected: false,
      ),
    ];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ...drawerItems.map((item) => _buildModernDrawerTile(context, item)),
        const Divider(),
        _buildModernDrawerTile(
          context,
          _ModernDrawerItem(
            icon: Icons.card_membership_rounded,
            title: 'الاشتراك',
            route: Routes.subscription,
            isSelected: false,
          ),
        ),
        _buildModernDrawerTile(
          context,
          _ModernDrawerItem(
            icon: Icons.settings_rounded,
            title: 'الإعدادات',
            route: Routes.settings,
            isSelected: false,
          ),
        ),
      ],
    );
  }

  /// Build modern drawer tile
  Widget _buildModernDrawerTile(BuildContext context, _ModernDrawerItem item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: item.isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1) : null,
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: item.isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            item.icon,
            color: item.isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
            size: 20.sp,
          ),
        ),
        title: Text(
          item.title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: item.isSelected ? FontWeight.bold : FontWeight.normal,
                color: item.isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (item.route.isNotEmpty) {
            Navigator.pushNamed(context, item.route);
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  /// Build modern drawer footer
  Widget _buildModernDrawerFooter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade600,
                size: 20.sp,
              ),
            ),
            title: Text(
              'تسجيل الخروج',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ],
      ),
    );
  }

  /// Build modern floating action button with accessibility
  Widget _buildModernFloatingActionButton(BuildContext context) {
    return Semantics(
      label: 'إنشاء حصة جديدة',
      hint: 'اضغط لإنشاء حصة جديدة',
      button: true,
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, Routes.createSession),
        icon: Icon(
          Icons.add_rounded,
          size: 24.sp,
        ),
        label: Text(
          'حصة جديدة',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                context,
                icon: Icons.dashboard_rounded,
                label: 'الرئيسية',
                isSelected: true,
                onTap: () {},
              ),
              _buildBottomNavItem(
                context,
                icon: Icons.people_rounded,
                label: 'الطلاب',
                isSelected: false,
                onTap: () => Navigator.pushNamed(context, Routes.students),
              ),
              _buildBottomNavItem(
                context,
                icon: Icons.event_rounded,
                label: 'الحصص',
                isSelected: false,
                onTap: () => Navigator.pushNamed(context, Routes.sessions),
              ),
              _buildBottomNavItem(
                context,
                icon: Icons.analytics_rounded,
                label: 'التقارير',
                isSelected: false,
                onTap: () => Navigator.pushNamed(context, Routes.reports),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build bottom navigation item
  Widget _buildBottomNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20.sp,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Subscription Banner
  Widget _buildSubscriptionBanner(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        AppLogging.logInfo('💳 SubscriptionBanner UI State: ${state.runtimeType}');

        if (state is SubscriptionLoading) {
          return _buildSubscriptionLoadingBanner();
        } else if (state is SubscriptionError) {
          return _buildSubscriptionErrorBanner(context, state.message);
        } else if (state is SubscriptionLoaded && state.subscription != null) {
          final subscription = state.subscription!;
          return _buildSubscriptionContent(context, subscription);
        } else if (state is SubscriptionLoaded && state.subscription == null) {
          return _buildNoSubscriptionBanner(context);
        } else if (state is SubscriptionInitial) {
          return const SizedBox.shrink();
        } else {
          return const Text('Unknown subscription state');
        }
      },
    );
  }

  /// Build subscription loading banner
  Widget _buildSubscriptionLoadingBanner() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12.w),
            Text(
              'جاري تحميل بيانات الاشتراك...',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  /// Build subscription error banner
  Widget _buildSubscriptionErrorBanner(BuildContext context, String errorMessage) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'خطأ في تحميل الاشتراك: $errorMessage',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<SubscriptionBloc>().add(const LoadSubscription());
              },
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build no subscription banner
  Widget _buildNoSubscriptionBanner(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue.shade700,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'لا يوجد اشتراك نشط',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, Routes.subscription),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
              ),
              child: const Text('اشتراك جديد'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build subscription content based on status
  Widget _buildSubscriptionContent(BuildContext context, dynamic subscription) {
    if (subscription.remainingDays <= 0) {
      return _buildExpiredSubscriptionBanner(context, subscription);
    } else if (subscription.remainingDays <= 7) {
      return _buildExpiringSubscriptionBanner(context, subscription);
    } else {
      return _buildActiveSubscriptionBanner(context, subscription);
    }
  }

  /// Build expired subscription banner
  Widget _buildExpiredSubscriptionBanner(BuildContext context, dynamic subscription) {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(
              Icons.cancel,
              color: Colors.red.shade700,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'انتهت صلاحية الاشتراك',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, Routes.subscription),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('تجديد الاشتراك'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build expiring subscription banner
  Widget _buildExpiringSubscriptionBanner(BuildContext context, dynamic subscription) {
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
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pushNamed(context, Routes.subscription),
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
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pushNamed(context, Routes.subscription),
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

  /// Build active subscription banner
  Widget _buildActiveSubscriptionBanner(BuildContext context, dynamic subscription) {
    return Card(
      elevation: 2,
      color: Colors.green.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green.shade700,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'اشتراك نشط - يتبقى ${subscription.remainingDays} يومًا',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, Routes.subscription),
              child: const Text('عرض التفاصيل'),
            ),
          ],
        ),
      ),
    );
  }

  // Dashboard Summary
  Widget _buildDashboardSummary(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        AppLogging.logInfo('📊 DashboardSummary UI State: ${state.runtimeType}');

        if (state is ReportsLoading) {
          return _buildDashboardLoadingState();
        } else if (state is DashboardSummaryLoaded) {
          return _buildDashboardContent(context, state.summary);
        } else if (state is ReportsError) {
          return _buildDashboardErrorState(context, state.message);
        } else if (state is ReportsInitial) {
          return _buildDashboardInitialState(context);
        }
        return _buildDashboardUnknownState(context);
      },
    );
  }

  /// Build dashboard loading state with enhanced skeleton
  Widget _buildDashboardLoadingState() {
    return Column(
      children: [
        // Stats Grid Skeleton
        Row(
          children: [
            Expanded(child: _buildEnhancedSkeletonCard(height: 120.h)),
            SizedBox(width: 12.w),
            Expanded(child: _buildEnhancedSkeletonCard(height: 120.h)),
          ],
        ),
        SizedBox(height: 16.h),
        // Revenue Card Skeleton
        _buildEnhancedSkeletonCard(height: 100.h),
        SizedBox(height: 16.h),
        // Additional Info Skeleton
        _buildEnhancedSkeletonCard(height: 80.h),
      ],
    );
  }

  /// Build dashboard content with animations
  Widget _buildDashboardContent(BuildContext context, dynamic summary) {
    final content = Column(
      children: [
        // Stats Cards Grid
        _buildStatsGrid(context, summary),
        SizedBox(height: 16.h),

        // Revenue Card
        _buildRevenueCard(context, summary),
        SizedBox(height: 16.h),

        // Additional Metrics
        _buildAdditionalMetrics(context, summary),
      ],
    );

    return _areAnimationsReady
        ? FadeTransition(
            opacity: _fadeAnimation!,
            child: SlideTransition(
              position: _slideAnimation!,
              child: content,
            ),
          )
        : content;
  }

  /// Build dashboard error state with enhanced error handling
  Widget _buildDashboardErrorState(BuildContext context, String message) {
    return Card(
      elevation: 2,
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
              'خطأ في تحميل بيانات لوحة التحكم',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadDashboard,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
                SizedBox(width: 12.w),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, Routes.reports),
                  icon: const Icon(Icons.analytics),
                  label: const Text('عرض التقارير'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build dashboard initial state
  Widget _buildDashboardInitialState(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Icon(
              Icons.dashboard,
              size: 48.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'مرحباً بك في لوحة التحكم',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ابدأ بإضافة طلابك وإنشاء حصصك الأولى',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            FilledButton.icon(
              onPressed: () {
                AppLogging.logInfo('🔄 Manual dashboard load triggered from initial state');
                _loadDashboard();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('تحميل البيانات'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build unknown state fallback
  Widget _buildDashboardUnknownState(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Icon(
              Icons.help_outline,
              size: 48.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'حالة غير معروفة',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'يرجى إعادة تحميل الصفحة',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            FilledButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة التحميل'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build additional metrics section
  Widget _buildAdditionalMetrics(BuildContext context, dynamic summary) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مؤشرات إضافية',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'متوسط الحصص/طالب',
                    '${(summary.sessionsCount / (summary.studentsCount > 0 ? summary.studentsCount : 1)).toStringAsFixed(1)}',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'متوسط الإيراد/حصة',
                    '${(summary.totalRevenue / (summary.sessionsCount > 0 ? summary.sessionsCount : 1)).toStringAsFixed(0)} ج.م',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build metric item
  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  /// Build enhanced skeleton card with shimmer effect
  Widget _buildEnhancedSkeletonCard({required double height}) {
    return Card(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade300,
              Colors.grey.shade200,
              Colors.grey.shade300,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                height: 16.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 80.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      ),
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
                Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
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
                Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.1),
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
          Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.1),
        ],
      ),
    );
  }

  // Quick Actions
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _EnhancedQuickAction(
        icon: Icons.add_circle_rounded,
        title: 'حصة جديدة',
        subtitle: 'إنشاء حصة جديدة',
        color: Theme.of(context).colorScheme.primary,
        onTap: () => Navigator.pushNamed(context, Routes.createSession),
        badge: 'جديد',
      ),
      _EnhancedQuickAction(
        icon: Icons.people_alt_rounded,
        title: 'إضافة طالب',
        subtitle: 'تسجيل طالب جديد',
        color: Theme.of(context).colorScheme.tertiary,
        onTap: () => Navigator.pushNamed(context, Routes.students),
      ),
      _EnhancedQuickAction(
        icon: Icons.analytics_rounded,
        title: 'التقارير',
        subtitle: 'عرض التقارير',
        color: Theme.of(context).colorScheme.secondary,
        onTap: () => Navigator.pushNamed(context, Routes.reports),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 24.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'إجراءات سريعة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Show all quick actions
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('قريباً: المزيد من الإجراءات')),
                );
              },
              child: const Text('المزيد'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildEnhancedQuickActionsGrid(context, actions),
      ],
    );
  }

  /// Build enhanced quick actions grid
  Widget _buildEnhancedQuickActionsGrid(BuildContext context, List<_EnhancedQuickAction> actions) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.8,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildEnhancedQuickActionCard(context, action);
      },
    );
  }

  /// Build enhanced quick action card
  Widget _buildEnhancedQuickActionCard(BuildContext context, _EnhancedQuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              action.color.withValues(alpha: 0.1),
              action.color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: action.color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
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
                  if (action.badge != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          action.badge!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                action.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: action.color,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                action.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Students Lists
  Widget _buildStudentsLists(BuildContext context) {
    return BlocBuilder<StudentsBloc, StudentsState>(
      builder: (context, state) {
        AppLogging.logInfo('👥 StudentsLists UI State: ${state.runtimeType}');

        if (state is StudentsLoading) {
          return _buildStudentsLoadingState();
        } else if (state is StudentsError) {
          return _buildStudentsErrorState(context, state.message);
        } else if (state is StudentsLoaded) {
          final students = state.students;
          AppLogging.logInfo('👥 StudentsLoaded: ${students.length} students');

          if (students.isEmpty) {
            return _buildNoStudentsState(context);
          }

          final overdueStudents = students.where((s) => _isStudentOverdue(s)).toList();
          final onTimeStudents = students.where((s) => !_isStudentOverdue(s)).toList();

          AppLogging.logInfo('👥 Overdue students: ${overdueStudents.length}, On-time students: ${onTimeStudents.length}');

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
        return _buildStudentsInitialState(context);
      },
    );
  }

  /// Build students loading state
  Widget _buildStudentsLoadingState() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            SizedBox(height: 16.h),
            Text(
              'جاري تحميل الطلاب...',
              style: TextStyle(fontSize: 16.sp),
            ),
          ],
        ),
      ),
    );
  }

  /// Build students error state
  Widget _buildStudentsErrorState(BuildContext context, String errorMessage) {
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
              'خطأ في تحميل الطلاب',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<StudentsBloc>().add(const LoadStudents());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
                SizedBox(width: 12.w),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, Routes.students),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة طالب'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build no students state
  Widget _buildNoStudentsState(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا يوجد طلاب',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ابدأ بإضافة طلابك الأول',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, Routes.students),
              icon: const Icon(Icons.add),
              label: const Text('إضافة طالب جديد'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build students initial state
  Widget _buildStudentsInitialState(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Icon(
              Icons.school,
              size: 48.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'إدارة الطلاب',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 8.h),
            Text(
              'ابدأ بإضافة طلابك وإدارة حصصهم',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            FilledButton.icon(
              onPressed: () {
                AppLogging.logInfo('👥 Navigating to students screen from initial state');
                Navigator.pushNamed(context, Routes.students);
              },
              icon: const Icon(Icons.people),
              label: const Text('عرض الطلاب'),
            ),
          ],
        ),
      ),
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
                    student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

// Modern Drawer Item
class _ModernDrawerItem {
  final IconData icon;
  final String title;
  final String route;
  final bool isSelected;

  const _ModernDrawerItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.isSelected,
  });
}

// Enhanced Quick Action
class _EnhancedQuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _EnhancedQuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });
}
