import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/routes.dart';
import '../bloc/templates_bloc.dart';
import '../widgets/template_card.dart';

class TemplatesListScreen extends StatelessWidget {
  const TemplatesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TemplatesBloc>()..add(const LoadTemplates()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('القوالب'),
        ),
        body: BlocBuilder<TemplatesBloc, TemplatesState>(
          builder: (context, state) {
            if (state is TemplatesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TemplatesError) {
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
                        context.read<TemplatesBloc>().add(const LoadTemplates());
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            } else if (state is TemplatesLoaded) {
              if (state.templates.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_repeat_outlined,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد قوالب بعد',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'أنشئ قالب لتسهيل إنشاء الحصص',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _navigateToForm(context),
                        icon: const Icon(Icons.add),
                        label: const Text('إنشاء قالب'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.templates.length,
                itemBuilder: (context, index) {
                  final template = state.templates[index];
                  return TemplateCard(
                    template: template,
                    onTap: () {
                      // Navigate to template detail
                      Navigator.pushNamed(
                        context,
                        Routes.templateDetail,
                        arguments: template,
                      );
                    },
                    onEdit: () => _navigateToForm(context, template: template),
                    onDelete: () => _confirmDelete(context, template),
                    onQuickStart: () => _quickStartSession(context, template),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _navigateToForm(context),
          icon: const Icon(Icons.add),
          label: const Text('قالب جديد'),
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, {template}) async {
    final result = await Navigator.pushNamed(
      context,
      Routes.templateForm,
      arguments: template,
    );

    if (result == true && context.mounted) {
      context.read<TemplatesBloc>().add(const LoadTemplates());
    }
  }

  void _confirmDelete(BuildContext context, template) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف قالب "${template.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<TemplatesBloc>().add(DeleteTemplate(template.id));
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _quickStartSession(BuildContext context, template) {
    // Navigate to create session with pre-filled data
    Navigator.pushNamed(
      context,
      Routes.createSession,
      arguments: {'template': template},
    );
  }
}

