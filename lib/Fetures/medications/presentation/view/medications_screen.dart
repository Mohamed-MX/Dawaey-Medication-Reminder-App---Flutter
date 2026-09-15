import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/medications_cubit.dart';
import '../cubit/medications_state.dart';
import '../../data/model/medication_model.dart';
import 'add_medication_screen.dart';
import '../../../patients/presentation/cubit/patients_cubit.dart';
import '../../../patients/presentation/cubit/patients_state.dart';
import '../../../patients/data/model/patient_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_cubit.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Patient filter dropdown
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
            if (patientState is! PatientsLoaded) return const SizedBox.shrink();

            final selectedPatient = patientState.selectedPatientId == null
                ? null
                : patientState.patients.firstWhere(
                    (p) => p.id == patientState.selectedPatientId,
                    orElse: () => patientState.patients.first,
                  );

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                          ...patientState.patients
                              .map<DropdownMenuItem<String?>>((PatientModel p) {
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
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),

        // Medication list
        Expanded(
          child: BlocBuilder<MedicationsCubit, MedicationsState>(
            builder: (context, state) {
              if (state is MedicationsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is MedicationsError) {
                return Center(child: Text(state.message));
              }
              if (state is MedicationsLoaded) {
                final medications = state.medications;

                if (medications.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد أدوية مضافة بعد',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final med = medications[index];
                    return _MedicationCardWidget(medication: med);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _MedicationCardWidget extends StatefulWidget {
  final MedicationModel medication;

  const _MedicationCardWidget({required this.medication});

  @override
  State<_MedicationCardWidget> createState() => _MedicationCardWidgetState();
}

class _MedicationCardWidgetState extends State<_MedicationCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final med = widget.medication;
    final isStopped = med.status == MedicationStatus.stopped;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isStopped ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    med.medicationName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isStopped ? Colors.grey : const Color(0xFF1B363F),
                      decoration: isStopped ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isStopped ? Colors.grey.shade300 : Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    med.administrationRoute,
                    style: TextStyle(
                      color: isStopped ? Colors.grey.shade600 : Colors.teal,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                // Edit (Pen) Icon
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMedicationScreen(editMedication: med),
                      ),
                    );
                  },
                ),
                // 3-dots menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.blueGrey),
                  onSelected: (value) {
                    if (value == 'toggle') {
                      context.read<MedicationsCubit>().toggleMedicationStatus(med.id);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, med.id);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'toggle',
                      child: Text(isStopped ? 'تفعيل الدواء' : 'إيقاف الدواء'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('حذف الدواء', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.medication, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'الجرعة: ${med.dosage}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.repeat, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'التكرار: ${_frequencyToString(med.frequency)}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'المواعيد: ${med.intakeTimes.map((t) => "${t.hour % 12 == 0 ? 12 : t.hour % 12}:${t.minute.toString().padLeft(2, '0')} ${t.hour >= 12 ? 'م' : 'ص'}").join(", ")}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.date_range, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'تاريخ البدء: ${med.startDate.year}/${med.startDate.month}/${med.startDate.day}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              if (med.remainingMedicationAmount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.inventory, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'المتبقي: ${med.remainingMedicationAmount}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
              if (med.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.note, size: 20, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'ملاحظات: ${med.notes}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ]
            ]
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String medId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الدواء؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<MedicationsCubit>().deleteMedication(medId);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _frequencyToString(MedicationFrequency freq) {
    switch (freq) {
      case MedicationFrequency.onceDaily:
        return 'مرة واحدة يوميًا';
      case MedicationFrequency.twiceDaily:
        return 'مرتين يوميًا';
      case MedicationFrequency.threeTimesDaily:
        return 'ثلاث مرات يوميًا';
      case MedicationFrequency.fourTimesDaily:
        return 'أربع مرات يوميًا';
      case MedicationFrequency.onceWeekly:
        return 'مرة أسبوعيًا';
      default:
        return 'غير معروف';
    }
  }
}
