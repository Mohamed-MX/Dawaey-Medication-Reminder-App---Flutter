import 'package:dawaey/Fetures/medications/data/model/medication_model.dart';
import 'package:dawaey/Fetures/medications/widgets/medication_action_sheets.dart';
import 'package:dawaey/Fetures/medications/widgets/medication_info.dart';
import 'package:dawaey/Fetures/medications/widgets/medication_success_dialogs.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:dawaey/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MedicationDetailsScreen extends StatelessWidget {
  MedicationDetailsScreen({super.key});

  late MedicationModel medication;

  double rs(BuildContext context, double value) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 382).clamp(0.9, 1.2);

    return value * scale;
  }

  List<Map<String, String>> get medicationData => [
        {
          'label': 'الجرعة',
          'value': medication.dosage,
        },
        {
          'label': 'معدل التكرار',
          'value': medication.frequency.arabicName,
        },
        {
          'label': 'موعد الدواء',
          'value': medication.intakeTimes.map((time) {
            final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
            final minute = time.minute.toString().padLeft(2, '0');
            final period = time.hour >= 12 ? 'م' : 'ص';

            return '$hour:$minute $period';
          }).join(' - '),
        },
        {
          'label': 'تاريخ البداية',
          'value': DateFormat(
            'd MMMM yyyy',
            'ar',
          ).format(medication.startDate),
        },
        {
          'label': 'تاريخ الانتهاء',
          'value': DateFormat(
            'd MMMM yyyy',
            'ar',
          ).format(medication.endDate),
        },
        {
          'label': 'المتبقي لديك',
          'value': '${medication.remainingDoses} جرعة',
        },
        {
          'label': 'ملاحظات',
          'value': medication.notes,
        },
      ];

  void _showMedicationInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'تفاصيل الدواء',
            style: AppFonts.inter30BoldDark.copyWith(
              fontSize: rs(context, 22),
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: medicationData.length,
              itemBuilder: (context, index) {
                return MedicationInfo(
                  label: medicationData[index]['label']!,
                  value: medicationData[index]['value']!,
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return DeleteMedicationSheet(
          medicationName: medication.medicationName,
          dosage: medication.dosage,
          rs: rs,
        );
      },
    );

    if (result == true && context.mounted) {
      showDeleteSuccessDialog(context, rs);
    }
  }

  Future<void> _showPauseBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return PauseMedicationSheet(
          medicationName: medication.medicationName,
          dosage: medication.dosage,
          rs: rs,
        );
      },
    );

    if (result != null && context.mounted) {
      showPauseSuccessDialog(
        context,
        rs,
        result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    medication =
        ModalRoute.of(context)!.settings.arguments as MedicationModel;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'تفاصيل الدواء',
            style: AppFonts.inter30BoldDark.copyWith(
              fontSize: rs(context, 30),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: rs(context, 30),
            ),
            color: AppColors.textDark,
          ),
          centerTitle: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isShortScreen = constraints.maxHeight < 500;

            return Column(
              children: [
                // Medication Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: rs(context, 48),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication.medicationName,
                              style: AppFonts.inter30BoldDark.copyWith(
                                fontSize: rs(context, 24),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              medication.dosage,
                              style: AppFonts.inter30BoldDark.copyWith(
                                fontSize: rs(context, 20),
                              ),
                            ),
                            Container(
                              width: rs(context, 106),
                              height: rs(context, 32),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppColors.softMintGreen,
                              ),
                              child: Center(
                                child: Text(
                                  medication.administrationRoute,
                                  style: AppFonts.inter18BoldRed.copyWith(
                                    fontSize: rs(context, 18),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        width: rs(context, 30),
                      ),

                      Container(
                        width: rs(context, 88),
                        height: rs(context, 88),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: AppColors.lightBlue,
                        ),
                        child: Image.asset(
                          'assets/imgs/Pill_Icon.png',
                          width: rs(context, 56),
                          height: rs(context, 24.5),
                        ),
                      ),
                    ],
                  ),
                ),

                // Medication Information
                Expanded(
                  child: isShortScreen
                      ? Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showMedicationInfoDialog(context);
                            },
                            icon: Icon(
                              Icons.info_outline,
                              size: rs(context, 20),
                            ),
                            label: Text(
                              'عرض تفاصيل الدواء',
                              style: AppFonts.inter18BoldRed.copyWith(
                                color: Colors.white,
                                fontSize: rs(context, 14),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.tealGreen,
                              foregroundColor: Colors.white,
                              minimumSize: Size(
                                rs(context, 180),
                                rs(context, 50),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: rs(context, 48),
                            vertical: rs(context, 36),
                          ),
                          child: ListView.builder(
                            itemCount: medicationData.length,
                            itemBuilder: (context, index) {
                              return MedicationInfo(
                                label: medicationData[index]['label']!,
                                value: medicationData[index]['value']!,
                              );
                            },
                          ),
                        ),
                ),

                // Bottom Actions
                Padding(
                  padding: EdgeInsets.only(
                    bottom: rs(context, 8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: rs(context, 5),
                      ),

                      // Add Medication
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/add_medications',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tealGreen,
                            minimumSize: Size(
                              0,
                              rs(context, 60),
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: rs(context, 18),
                              ),
                              Text(
                                'إضافة دواء جديد',
                                style: AppFonts.inter18BoldRed.copyWith(
                                  color: Colors.white,
                                  fontSize: rs(context, 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        width: rs(context, 5),
                      ),

                      // Delete Medication
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showDeleteBottomSheet(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            minimumSize: Size(
                              0,
                              rs(context, 60),
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.delete,
                                size: rs(context, 14),
                              ),
                              Text(
                                'حذف الدواء',
                                style: AppFonts.inter18BoldRed.copyWith(
                                  color: Colors.white,
                                  fontSize: rs(context, 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        width: rs(context, 5),
                      ),

                      // Pause Medication
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _showPauseBottomSheet(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff8BA0BC),
                            minimumSize: Size(
                              0,
                              rs(context, 60),
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.pause,
                                size: rs(context, 18),
                              ),
                              Text(
                                'إيقاف الدواء مؤقتا',
                                style: AppFonts.inter18BoldRed.copyWith(
                                  color: Colors.white,
                                  fontSize: rs(context, 10),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        width: rs(context, 5),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}