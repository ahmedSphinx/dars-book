import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import '../../../subscriptions/presentation/bloc/subscription_bloc.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الاشتراك'),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubscriptionError) {
            return _buildErrorState(context, state.message);
          }

          if (state is SubscriptionLoaded) {
            final subscription = state.subscription;
            final isActive = subscription != null && subscription.isActive;

            if (isActive) {
              return _buildActiveSubscription(context, subscription);
            } else {
              return _buildInactiveSubscription(context);
            }
          }

          if (state is SubscriptionRedeemed) {
            return _buildActiveSubscription(context, state.subscription);
          }

          return _buildInactiveSubscription(context);
        },
      ),
    );
  }

  Widget _buildActiveSubscription(BuildContext context, subscription) {
    final daysRemaining = subscription.expiresAt.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysRemaining <= 7;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isExpiringSoon ? [Colors.orange.shade400, Colors.orange.shade600] : [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isExpiringSoon ? Colors.orange : Colors.green).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  isExpiringSoon ? Icons.warning_amber_rounded : Icons.check_circle,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  isExpiringSoon ? 'سينتهي قريبًا' : 'نشط',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subscription.tier.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    icon: Icons.calendar_today,
                    label: 'نوع الاشتراك',
                    value: subscription.tier.toUpperCase(),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    icon: Icons.event,
                    label: 'تاريخ الانتهاء',
                    value: DateFormat.yMMMd('ar').format(subscription.expiresAt),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    icon: Icons.timer,
                    label: 'الأيام المتبقية',
                    value: '$daysRemaining يوم',
                    valueColor: isExpiringSoon ? Colors.orange : Colors.green,
                  ),
                  const Divider(height: 24),
                  _buildDetailRow(
                    context,
                    icon: Icons.security,
                    label: 'الحالة',
                    value: subscription.isActive ? 'نشط' : 'غير نشط',
                    valueColor: subscription.isActive ? Colors.green : Colors.red,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Renew Button (if expiring soon)
          if (isExpiringSoon)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRedeemDialog(context),
                icon: const Icon(Icons.refresh),
                label: const Text('تجديد الاشتراك'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            Text(
              'حدث خطأ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Retry Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<SubscriptionBloc>().add(const LoadSubscription());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInactiveSubscription(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lock Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 80,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 24),

            // Message
            Text(
              'الاشتراك غير مفعل',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'يرجى تفعيل الاشتراك للوصول إلى جميع الميزات',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Features
            _buildFeatureItem('✓ إدارة غير محدودة للطلاب'),
            _buildFeatureItem('✓ تسجيل الحصص والمدفوعات'),
            _buildFeatureItem('✓ تقارير مفصلة ورسوم بيانية'),
            _buildFeatureItem('✓ نسخ احتياطي سحابي'),
            _buildFeatureItem('✓ دعم فني مباشر'),
            const SizedBox(height: 32),

            // Redeem Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRedeemDialog(context),
                icon: const Icon(Icons.card_giftcard),
                label: const Text('استبدال قسيمة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contact Support
            TextButton.icon(
              onPressed: () {
                // TODO: Contact support
                EasyLoading.showToast('للحصول على قسيمة، تواصل مع الدعم الفني');
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('كيفية الحصول على قسيمة؟'),
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
    Color? valueColor,
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showRedeemDialog(BuildContext context) {
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocListener<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionError) {
            Navigator.pop(dialogContext);
            EasyLoading.showError(state.message);
          } else if (state is SubscriptionLoaded && state.subscription != null && state.subscription!.isActive) {
            Navigator.pop(dialogContext);
            EasyLoading.showSuccess('تم تفعيل الاشتراك بنجاح!');
          }
        },
        child: AlertDialog(
          title: const Text('استبدال قسيمة'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'أدخل كود القسيمة للحصول على الاشتراك',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'كود القسيمة',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.card_giftcard),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'هذا الحقل مطلوب';
                    }
                    if (value.length < 6) {
                      return 'الكود يجب أن يكون 6 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            BlocBuilder<SubscriptionBloc, SubscriptionState>(
              builder: (context, state) {
                final isLoading = state is SubscriptionLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            context.read<SubscriptionBloc>().add(
                                  RedeemSubscriptionVoucher(
                                    codeController.text.trim().toUpperCase(),
                                  ),
                                );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('تفعيل'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
