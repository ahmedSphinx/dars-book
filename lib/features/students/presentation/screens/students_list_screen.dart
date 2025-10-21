import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/students_bloc.dart';
import '../bloc/students_event.dart';
import '../bloc/students_state.dart';
import '../../domain/entities/student.dart';
import '../widgets/student_card.dart';
import 'student_form_screen.dart';
import 'student_detail_screen.dart';

class StudentsListScreen extends StatefulWidget {
  const StudentsListScreen({super.key});

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  final _searchController = TextEditingController();
  String _selectedYear = 'all';
  String _selectedFilter = 'all'; // all, active, inactive, overdue, ontime

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<StudentsBloc>()..add(const LoadStudents()),
      child: Scaffold(
        appBar: AppBar(
          
          title: Text('الطلاب'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterSheet,
            ),
          ],
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  hintText: 'بحث عن الطالب',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            context.read<StudentsBloc>().add(const LoadStudents());
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    context.read<StudentsBloc>().add(SearchStudents(value));
                  } else {
                    context.read<StudentsBloc>().add(const LoadStudents());
                  }
                },
              ),
            ),

            // Students List
            Expanded(
              child: BlocConsumer<StudentsBloc, StudentsState>(
                listener: (context, state) {
                  if (state is StudentOperationSuccess) {
                    EasyLoading.showSuccess(state.message);
                    // Reload after operation
                    context.read<StudentsBloc>().add(const LoadStudents());
                  } else if (state is StudentsError) {
                    EasyLoading.showError(state.message);
                  }
                },
                builder: (context, state) {
                  if (state is StudentsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is StudentsLoaded || state is StudentOperationSuccess) {
                    final students = state is StudentsLoaded 
                        ? state.students 
                        : (state as StudentOperationSuccess).students;

                    if (students.isEmpty) {
                      return _buildEmptyState();
                    }

                    // Apply filters
                    var filteredStudents = _applyFilters(students);

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<StudentsBloc>().add(const LoadStudents());
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          return StudentCard(
                            student: student,
                            onTap: () => _navigateToDetail(student),
                            onEdit: () => _navigateToEdit(student),
                            onToggleActive: () {
                              context.read<StudentsBloc>().add(
                                    ToggleStudentActive(student.id),
                                  );
                            },
                          );
                        },
                      ),
                    );
                  } else if (state is StudentsError) {
                    return _buildErrorState(state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _navigateToAdd,
          icon: const Icon(Icons.add),
          label: Text('إضافة طالب'),
        ),
      ),
    );
  }

  List<Student> _applyFilters(List<Student> students) {
    var filtered = students;

    // Year filter
    if (_selectedYear != 'all') {
      filtered = filtered.where((s) => s.year == _selectedYear).toList();
    }

    // Status filter
    switch (_selectedFilter) {
      case 'active':
        filtered = filtered.where((s) => s.isActive).toList();
        break;
      case 'inactive':
        filtered = filtered.where((s) => !s.isActive).toList();
        break;
      case 'overdue':
        filtered = filtered.where((s) => s.aggregates.remaining > 0).toList();
        break;
      case 'ontime':
        filtered = filtered.where((s) => s.aggregates.remaining == 0).toList();
        break;
    }

    return filtered;
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تصفية',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // Year Filter
              DropdownButtonFormField<String>(
                value: _selectedYear,
                decoration: InputDecoration(
                  labelText: 'السنة الدراسية',
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'all', child: Text('الجميع السنوات')),
                  const DropdownMenuItem(value: 'الصف الأول الثانوي', child: Text('الصف الأول الثانوي')),
                  const DropdownMenuItem(value: 'الصف الثاني الثانوي', child: Text('الصف الثاني الثانوي')),
                  const DropdownMenuItem(value: 'الصف الثالث الثانوي', child: Text('الصف الثالث الثانوي')),
                ],
                onChanged: (value) {
                  setState(() => _selectedYear = value!);
                  this.setState(() {});
                },
              ),
              const SizedBox(height: 16),
              
              // Status Filter
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: Text('كل الطلاب'),
                    selected: _selectedFilter == 'all',
                    onSelected: (selected) {
                      setState(() => _selectedFilter = 'all');
                      this.setState(() {});
                    },
                  ),
                  FilterChip(
                    label: Text('نشط'),
                    selected: _selectedFilter == 'active',
                    onSelected: (selected) {
                      setState(() => _selectedFilter = 'active');
                      this.setState(() {});
                    },
                  ),
                  FilterChip(
                    label: Text('غير نشط'),
                    selected: _selectedFilter == 'inactive',
                    onSelected: (selected) {
                      setState(() => _selectedFilter = 'inactive');
                      this.setState(() {});
                    },
                  ),
                  FilterChip(
                    label: Text('الطلاب المتأخرون'),
                    selected: _selectedFilter == 'overdue',
                    onSelected: (selected) {
                      setState(() => _selectedFilter = 'overdue');
                      this.setState(() {});
                    },
                  ),
                  FilterChip(
                    label: Text('الطلاب المنتظمون'),
                    selected: _selectedFilter == 'ontime',
                    onSelected: (selected) {
                      setState(() => _selectedFilter = 'ontime');
                      this.setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('تم'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد طلاب',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _navigateToAdd,
            icon: const Icon(Icons.add),
            label: Text('إضافة طالب'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<StudentsBloc>().add(const LoadStudents());
            },
            icon: const Icon(Icons.refresh),
            label: Text("إعادة المحاولة"),
          ),
        ],
      ),
    );
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StudentFormScreen(),
      ),
    ).then((_) {
      // Reload students after adding
      if (mounted) {
        context.read<StudentsBloc>().add(const LoadStudents());
      }
    });
  }

  void _navigateToEdit(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentFormScreen(student: student),
      ),
    ).then((_) {
      // Reload students after editing
      if (mounted) {
        context.read<StudentsBloc>().add(const LoadStudents());
      }
    });
  }

  void _navigateToDetail(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentDetailScreen(student: student),
      ),
    ).then((_) {
      // Reload students after viewing detail
      if (mounted) {
        context.read<StudentsBloc>().add(const LoadStudents());
      }
    });
  }
}

