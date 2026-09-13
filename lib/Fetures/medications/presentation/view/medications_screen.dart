import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/medications_cubit.dart';
import '../cubit/medications_state.dart';
import '../../data/model/medication_model.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicationsCubit, MedicationsState>(
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
              return _buildMedicationCard(med);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMedicationCard(MedicationModel med) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Text(
                med.medicationName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B363F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  med.administrationRoute,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
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
          ]
        ],
      ),
    );
  }

  String _frequencyToString(MedicationFrequency freq) {
    switch (freq) {
      case MedicationFrequency.onceDaily: return 'مرة واحدة يوميًا';
      case MedicationFrequency.twiceDaily: return 'مرتين يوميًا';
      case MedicationFrequency.threeTimesDaily: return 'ثلاث مرات يوميًا';
      case MedicationFrequency.fourTimesDaily: return 'أربع مرات يوميًا';
      case MedicationFrequency.onceWeekly: return 'مرة أسبوعيًا';
      default: return 'غير معروف';
    }
  }
}
