import 'package:flutter/material.dart';
import '../../../../core/routing/routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  int currentPage = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topLeft,
              child: TextButton(
                onPressed: () => _navigateToAuth(),
                child: const Text('تخطي'),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView(
                controller: controller,
                onPageChanged: (index) => setState(() => currentPage = index),
                children: [
                  _buildPage(
                    context,
                    icon: Icons.school,
                    title: 'مرحبا بك في DarsBook',
                    description: 'التطبيق الأمثل لإدارة طلابك وحصصك بكل سهولة',
                    color: Colors.blue,
                  ),
                  _buildPage(
                    context,
                    icon: Icons.event_note,
                    title: 'تنظيم الحصص والدفعات',
                    description: 'سجل الحصص، تتبع الحضور، وأدر المدفوعات بكفاءة',
                    color: Colors.green,
                  ),
                  _buildPage(
                    context,
                    icon: Icons.analytics,
                    title: 'تقارير مفصلة',
                    description: 'احصل على تقارير شاملة عن إيراداتك وطلابك',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastPage) {
                      _navigateToAuth();
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    isLastPage ? 'ابدأ الآن' : 'التالي',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 120,
              color: color,
            ),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }

  void _navigateToAuth() {
    Navigator.pushReplacementNamed(context, Routes.phoneAuth);
  }
}


