import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/payments_bloc.dart';
import '../../../students/domain/entities/student.dart';
import '../../domain/entities/payment.dart';

class RecordPaymentScreen extends StatefulWidget {
  final Student student;

  const RecordPaymentScreen({
    super.key,
    required this.student,
  });

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  double _suggestedAmount = 0;

  @override
  void initState() {
    super.initState();
    _suggestedAmount = widget.student.aggregates.remaining;
    _amountController.text = _suggestedAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.student.aggregates.remaining;
    final total = widget.student.aggregates.totalCharges;
    final paid = widget.student.aggregates.totalPaid;

    return BlocProvider(
      create: (_) => sl<PaymentsBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('سجل الدفعات - ${widget.student.name}'),
        ),
        body: BlocConsumer<PaymentsBloc, PaymentsState>(
          listener: (context, state) {
            if (state is PaymentOperationSuccess) {
              EasyLoading.showSuccess(state.message);
              if (context.mounted) {
                Navigator.pop(context, true); // Return true to indicate success
              }
            } else if (state is PaymentsError) {
              EasyLoading.showError(state.message);
            }
          },
          builder: (context, state) {
            final isLoading = state is PaymentsLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text(
                                    widget.student.name[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.student.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        widget.student.year,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.grey.shade600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            
                            // Financial Summary
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryItem(
                                    context,
                                    label: 'الإجمالي',
                                    value: '$total ج.م',
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSummaryItem(
                                    context,
                                    label: 'المدفوع',
                                    value: '$paid ج.م',
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildSummaryItem(
                                    context,
                                    label: 'المتبقي',
                                    value: '$remaining ج.م',
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Amount Field
                    Text(
                      'المبلغ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        suffixText: 'ج.م',
                        helperText: remaining > 0 
                            ? 'المبلغ المتبقي: $remaining ج.م'
                            : null,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'يرجى إدخال مبلغ صحيح';
                        }
                        if (amount > remaining) {
                          return 'المبلغ أكبر من المتبقي ($remaining ج.م)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Quick Amount Buttons
                    if (remaining > 0) ...[
                      Wrap(
                        spacing: 8,
                        children: [
                          if (remaining >= 50)
                            _buildQuickAmountChip('50 ج.م', 50),
                          if (remaining >= 100)
                            _buildQuickAmountChip('100 ج.م', 100),
                          if (remaining >= 200)
                            _buildQuickAmountChip('200 ج.م', 200),
                          _buildQuickAmountChip(
                            'المتبقي كاملاً',
                            remaining,
                            isPrimary: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    
                    // Payment Method
                    Text(
                     'طريقة الدفع',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: PaymentMethod.values.map((method) {
                        return ChoiceChip(
                          label: Text(_getMethodLabel(method)),
                          avatar: Icon(
                            _getMethodIcon(method),
                            size: 18,
                          ),
                          selected: _selectedMethod == method,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedMethod = method);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Note Field
                    Text(
                      'ملاحظات (${'اختياري'})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'أضف ملاحظة...',
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _savePayment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'تسجيل الدفعة',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
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
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
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

  Widget _buildQuickAmountChip(String label, double amount, {bool isPrimary = false}) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _amountController.text = amount.toString();
      },
      backgroundColor: isPrimary 
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : null,
      side: isPrimary
          ? BorderSide(color: Theme.of(context).primaryColor)
          : null,
    );
  }

  String _getMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'نقدي';
      case PaymentMethod.transfer:
        return 'تحويل بنكي';
      case PaymentMethod.wallet:
        return 'محفظة إلكترونية';
    }
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.transfer:
        return Icons.account_balance;
      case PaymentMethod.wallet:
        return Icons.account_balance_wallet;
    }
  }

  void _savePayment() {
    if (_formKey.currentState!.validate()) {
      final payment = Payment(
        id: '',
        studentId: widget.student.id,
        amount: double.parse(_amountController.text),
        method: _selectedMethod,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        createdAt: DateTime.now(),
      );

      context.read<PaymentsBloc>().add(AddPayment(payment));
    }
  }
}

