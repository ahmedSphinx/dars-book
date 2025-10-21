import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/routes.dart';
import '../../domain/entities/teacher.dart';
import '../bloc/teacher_profile_bloc.dart';
import '../bloc/teacher_profile_event.dart';
import '../bloc/teacher_profile_state.dart';

class TeacherProfileCompletionScreen extends StatefulWidget {
  const TeacherProfileCompletionScreen({super.key});

  @override
  State<TeacherProfileCompletionScreen> createState() =>
      _TeacherProfileCompletionScreenState();
}

class _TeacherProfileCompletionScreenState
    extends State<TeacherProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      _phoneController.text = user.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? '';

    return BlocProvider(
      create: (_) => sl<TeacherProfileBloc>()..add(LoadTeacherProfile(uid)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('استكمال بيانات المعلم'),
          automaticallyImplyLeading: false,
        ),
        body: BlocConsumer<TeacherProfileBloc, TeacherProfileState>(
          listener: (context, state) {
            if (state is TeacherProfileLoaded && state.teacher != null) {
              final t = state.teacher!;
              _nameController.text = t.name;
              if (_phoneController.text.isEmpty) {
                _phoneController.text = t.phone;
              }
              _subjectController.text = t.subject;
              _cityController.text = t.city;
            }
            if (state is TeacherProfileSaved) {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.dashboard, (route) => false);
            }
          },
          builder: (context, state) {
            final isLoading = state is TeacherProfileLoading;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Icon(Icons.person,
                        size: 72, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 12),
                    Text(
                      'مرحبا! لنكمل بعض البيانات الأساسية للبدء',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'الاسم',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'هذا الحقل مطلوب'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'هذا الحقل مطلوب'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'المادة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.menu_book),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'هذا الحقل مطلوب'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'المدينة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'هذا الحقل مطلوب'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _onSave(uid),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white)))
                            : const Text('حفظ والمتابعة'),
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

  void _onSave(String uid) {
    if (!_formKey.currentState!.validate()) return;
    final teacher = Teacher(
      id: uid,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      subject: _subjectController.text.trim(),
      city: _cityController.text.trim(),
    );
    context.read<TeacherProfileBloc>().add(SaveTeacherProfile(teacher));
  }
}
