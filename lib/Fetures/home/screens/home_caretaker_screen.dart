import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../medications/presentation/view/add_medication_screen.dart';
import '../../medications/presentation/view/medications_screen.dart';
import '../../medications/presentation/cubit/medications_cubit.dart';
import '../../medications/presentation/cubit/medications_state.dart';
import '../../medications/data/model/doise_model.dart';
import '../../patients/presentation/cubit/patients_cubit.dart';
import '../../patients/presentation/cubit/patients_state.dart';
import '../../patients/data/model/patient_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_cubit.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_state.dart';
import 'package:dawaey/core/routes/app_routes.dart';

class home_caretaker_screen extends StatefulWidget {
  const home_caretaker_screen({super.key});

  @override
  State<home_caretaker_screen> createState() => _home_caretaker_screenState();
}

class _home_caretaker_screenState extends State<home_caretaker_screen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Add navigation logic later to the created empty screens
  }

  @override
  Widget build(BuildContext context) {
    // Wrapping the entire Scaffold in Directionality RTL to make the BottomAppBar
    // arrange children from right to left naturally.
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'متابعة العائلة',
            style: TextStyle(
              color: Color(0xFF1B363F),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('الحساب'),
                    content: const Text('ماذا تريد أن تفعل؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.read<AuthCubit>().logout();
                        },
                        child: const Text(
                          'تسجيل الخروج',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 16),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFE0F2F1),
                  child: Icon(Icons.person, color: Colors.teal, size: 22),
                ),
              ),
            ),
          ],
        ),
        body: _selectedIndex == 0 ? _buildBody() : (_selectedIndex == 1 ? const MedicationsScreen() : const Center(child: Text('صفحة قيد الإنشاء'))),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddMedicationScreen(),
              ),
            );
          },
          backgroundColor: Colors.teal,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: Colors.white,
          elevation: 10,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavBarItem(Icons.home_outlined, 'الرئيسية', 0),
                    const SizedBox(width: 24),
                    _buildNavBarItem(Icons.medication_outlined, 'الأدوية', 1),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavBarItem(Icons.calendar_today_outlined, 'المواعيد', 2),
                    const SizedBox(width: 24),
                    _buildNavBarItem(Icons.notifications_outlined, 'التنبيهات', 3),
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<MedicationsCubit, MedicationsState>(
      builder: (context, state) {
        if (state is MedicationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is MedicationsError) {
          return Center(child: Text(state.message));
        }

        int totalDoses = 0;
        int takenDoses = 0;
        List<Widget> medicationCards = [];

        if (state is MedicationsLoaded) {
          totalDoses = state.totalDosesCount;
          takenDoses = state.takenDosesCount;

          for (var dose in state.todaysDoses) {
            final med = state.getMedicationById(dose.medicationId);
            final name = med?.medicationName ?? 'غير معروف';
            
            // Format time
            final hour = dose.time.hour;
            final minute = dose.time.minute.toString().padLeft(2, '0');
            final period = hour >= 12 ? 'م' : 'ص';
            final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
            final timeStr = '$hour12:$minute $period';

            final taken = dose.status == DoseStatus.taken;
            final upcoming = dose.status == DoseStatus.pending;

            medicationCards.add(Column(
              children: [
                _buildMedicationCard(name, timeStr, taken, upcoming, () {
                    // Toggle status for demo purposes
                    final newStatus = taken ? DoseStatus.pending : DoseStatus.taken;
                    context.read<MedicationsCubit>().updateDoseStatus(dose.id, newStatus);
                }),
                const SizedBox(height: 16),
              ],
            ));
          }

          if (medicationCards.isEmpty) {
            medicationCards.add(const Center(child: Text('لا توجد أدوية اليوم')));
          }
        }

        final adherenceRatio = totalDoses == 0 ? 0.0 : takenDoses / totalDoses;
        final adherencePercentage = (adherenceRatio * 100).toInt();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Dropdown section
              BlocConsumer<PatientsCubit, PatientsState>(
                listener: (context, patientState) {
                  if (patientState is PatientsLoaded) {
                    context.read<MedicationsCubit>().loadMedications(
                          patientId: patientState.selectedPatientId,
                          updateFilter: true,
                        );
                  }
                },
                builder: (context, patientState) {
                  if (patientState is PatientsLoaded) {
                    final selectedPatient = patientState.selectedPatientId == null
                        ? null
                        : patientState.patients.firstWhere(
                            (p) => p.id == patientState.selectedPatientId,
                            orElse: () => patientState.patients.first,
                          );

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButton<String?>(
                                  value: patientState.selectedPatientId,
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
                                  underline: const SizedBox(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B363F),
                                    fontFamily: 'NotoSansArabic',
                                  ),
                                  onChanged: (String? newValue) {
                                    context.read<PatientsCubit>().selectPatient(newValue);
                                  },
                                  items: [
                                    ...patientState.patients.map<DropdownMenuItem<String?>>((PatientModel p) {
                                      return DropdownMenuItem<String?>(
                                        value: p.id,
                                        child: Text(p.name),
                                      );
                                    }).toList(),
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('الكل'),
                                    ),
                                  ],
                                ),
                                Text(
                                  selectedPatient?.relationship ?? 'جميع المرضى',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.teal, size: 20),
                            onPressed: () {
                              _showAddPatientDialog(context);
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 30),

              // Weekly Commitment Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نسبة الالتزام هذا الأسبوع',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B363F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'ممتاز',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'استمروا على هذا المستوى المميز',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 70,
                          width: 70,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: adherenceRatio,
                                backgroundColor: Colors.grey.shade200,
                                color: Colors.teal,
                                strokeWidth: 6,
                              ),
                              Center(
                                child: Text(
                                  '$adherencePercentage%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1B363F),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Bar Chart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildBar('أحد', 0.5, Colors.red, false),
                        _buildBar('إثنين', 0.7, Colors.teal, true),
                        _buildBar('ثلاثاء', 0.6, Colors.teal, true),
                        _buildBar('أربعاء', 0.8, Colors.teal, true),
                        _buildBar('خميس', 0.4, Colors.red, false),
                        _buildBar('جمعة', 0.75, Colors.teal, true),
                        _buildBar('سبت', 0.5, Colors.red, false),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Today's Medications
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'أدوية اليوم',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B363F),
                    ),
                  ),
                  Text(
                    'تم $totalDoses/$takenDoses',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.teal,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ...medicationCards,
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(String day, double heightRatio, Color color, bool taken) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 80 * heightRatio,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        CircleAvatar(
          radius: 3,
          backgroundColor: taken ? Colors.transparent : Colors.red,
        ),
      ],
    );
  }

  Widget _buildMedicationCard(
      String name, String time, bool taken, bool upcoming, VoidCallback onTap) {
    Color bgColor;
    Color iconColor;
    IconData icon;

    if (upcoming) {
      bgColor = Colors.white;
      iconColor = Colors.teal;
      icon = Icons.access_time;
    } else if (taken) {
      bgColor = Colors.white;
      iconColor = Colors.teal;
      icon = Icons.check_circle;
    } else {
      bgColor = Colors.red.shade50;
      iconColor = Colors.red;
      icon = Icons.cancel;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: upcoming || taken
              ? Border.all(color: Colors.grey.shade200)
              : Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  time,
                  style: TextStyle(
                    color: upcoming ? Colors.teal : (taken ? Colors.teal : Colors.red),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B363F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedRelationship = 'نفسي';
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إضافة شخص جديد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRelationship,
                    decoration: const InputDecoration(
                      labelText: 'صلة القرابة',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'نفسي', child: Text('أنا')),
                      DropdownMenuItem(value: 'أب', child: Text('أب')),
                      DropdownMenuItem(value: 'أم', child: Text('أم')),
                      DropdownMenuItem(value: 'أخ/أخت', child: Text('أخ/أخت')),
                      DropdownMenuItem(value: 'ابن/ابنة', child: Text('ابن/ابنة')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        if (val != null) selectedRelationship = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final newPatient = PatientModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        relationship: selectedRelationship,
                      );
                      context.read<PatientsCubit>().addPatient(newPatient);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('إضافة'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
