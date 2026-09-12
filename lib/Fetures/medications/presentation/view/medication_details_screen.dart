import 'package:dawaey/Fetures/medications/widgets/medication_action_sheets.dart';
import 'package:dawaey/Fetures/medications/widgets/medication_info.dart';
import 'package:dawaey/Fetures/medications/widgets/medication_success_dialogs.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:dawaey/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class MedicationDetailsScreen extends StatefulWidget {
  const MedicationDetailsScreen({super.key});

  @override
  State<MedicationDetailsScreen> createState() =>
      _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen> {
  final medicationData = const [
    {'label': 'الجرعة', 'value': '5 مجم (قرص واحد)'},
    {'label': 'معدل التكرار', 'value': 'معدل يومي'},
    {'label': 'موعد الدواء', 'value': '9:00 ص'},
    {'label': 'تاريخ البداية', 'value': '1 أبريل 2025'},
    {'label': 'تاريخ الانتهاء', 'value': '31 ديسمبر 2025'},
    {'label': 'الوصفة الطبية', 'value': '90 جرعة'},
    {'label': 'ملاحظات', 'value': 'يؤخذ بعد الفطار'},
  ];

  double rs(BuildContext context, double value) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 382).clamp(0.9, 1.2);

    return value * scale;
  }

  Future<void> _showDeleteBottomSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return DeleteMedicationSheet(
          medicationName: 'أملوديبين',
          dosage: '5 مجم',
          rs: rs,
        );
      },
    );

    if (result == true && mounted) {
      showDeleteSuccessDialog(context, rs);
    }
  }

  Future<void> _showPauseBottomSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) {
        return PauseMedicationSheet(
          medicationName: 'أملوديبين',
          dosage: '5 مجم',
          rs: rs,
        );
      },
    );

    if (result != null && mounted) {
      showPauseSuccessDialog(
        context,
        rs,
        result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'تفاصيل الدواء',
            style: AppFonts.inter30BoldDark.copyWith(
              fontSize: rs(context, 36),
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
        body: Column(
          children: [
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
                          'أملوديبين',
                          style: AppFonts.inter30BoldDark.copyWith(
                            fontSize: rs(context, 24),
                          ),
                        ),
                        Text(
                          '5 مجم',
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
                              'قطر الدم',
                              style: AppFonts.inter18BoldRed.copyWith(
                                fontSize: rs(context, 18),
                              ),
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
            Expanded(
              child: Padding(
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
            Padding(
              padding: EdgeInsets.only(
                bottom: rs(context, 8),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: rs(context, 5),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showDeleteBottomSheet,
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

                  // إيقاف مؤقت
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showPauseBottomSheet,
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
        ),
      ),
    );
  }
}