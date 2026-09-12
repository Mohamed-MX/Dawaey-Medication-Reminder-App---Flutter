import 'package:dawaey/Fetures/medications/widgets/choice_chip_widget.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:dawaey/core/theme/fonts.dart';
import 'package:flutter/material.dart';

class DeleteMedicationSheet extends StatelessWidget {
  final String medicationName;
  final String dosage;
  final double Function(BuildContext, double) rs;

  const DeleteMedicationSheet({
    super.key,
    required this.medicationName,
    required this.dosage,
    required this.rs,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: rs(context, 16),
            vertical: rs(context, 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(rs(context, 8)),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(181, 244, 212, 184),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.delete,
                  size: rs(context, 30),
                  color: const Color(0xffEF4444),
                ),
              ),

              SizedBox(height: rs(context, 8)),

              Text(
                "حذف الدواء",
                style: AppFonts.inter30BoldDark.copyWith(
                  fontSize: rs(context, 24),
                ),
              ),

              Text(
                "هل أنت متأكد من حذف هذا الدواء من قائمتك؟",
                textAlign: TextAlign.center,
                style: AppFonts.inter18BoldRed.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: rs(context, 18),
                ),
              ),

              Text(
                "لا يمكن التراجع عن هذا الإجراء",
                textAlign: TextAlign.center,
                style: AppFonts.inter18BoldRed.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: rs(context, 16),
                ),
              ),

              SizedBox(height: rs(context, 16)),

              _buildMedicationCard(context),

              SizedBox(height: rs(context, 32)),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, rs(context, 52)),
                        backgroundColor: const Color(0xFF4285E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'حذف',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: rs(context, 15),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: rs(context, 12)),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(double.infinity, rs(context, 52)),
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF294B63),
                        side: const BorderSide(color: Color(0xFFD9DDE1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: rs(context, 15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs(context, 8)),
      decoration: BoxDecoration(
        color: const Color.fromARGB(181, 244, 212, 184),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/imgs/Pill_Icon.png",
            width: rs(context, 40),
            height: rs(context, 30),
          ),

          SizedBox(width: rs(context, 8)),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medicationName,
                style: AppFonts.inter30BoldDark.copyWith(
                  fontSize: rs(context, 20),
                ),
              ),
              Text(
                dosage,
                style: AppFonts.inter18BoldRed.copyWith(
                  color: AppColors.BlueGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PauseMedicationSheet extends StatefulWidget {
  final String medicationName;
  final String dosage;
  final double Function(BuildContext, double) rs;

  const PauseMedicationSheet({
    super.key,
    required this.medicationName,
    required this.dosage,
    required this.rs,
  });

  @override
  State<PauseMedicationSheet> createState() => _PauseMedicationSheetState();
}

class _PauseMedicationSheetState extends State<PauseMedicationSheet> {
  String selectedDuration = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.rs(context, 16),
            vertical: widget.rs(context, 16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(widget.rs(context, 8)),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4E2F3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.pause,
                  size: widget.rs(context, 30),
                  color: const Color(0xFF8FA6C3),
                ),
              ),

              SizedBox(height: widget.rs(context, 8)),

              Text(
                'إيقاف الدواء مؤقتا',
                style: AppFonts.inter30BoldDark.copyWith(
                  fontSize: widget.rs(context, 24),
                ),
              ),

              Text(
                'سيتم إيقاف تنبيهك بتناول هذا الدواء مؤقتا',
                textAlign: TextAlign.center,
                style: AppFonts.inter18BoldRed.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: widget.rs(context, 18),
                ),
              ),

              SizedBox(height: widget.rs(context, 16)),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(widget.rs(context, 8)),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4E2F3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/imgs/Pill_Icon.png',
                      width: widget.rs(context, 40),
                      height: widget.rs(context, 30),
                    ),

                    SizedBox(width: widget.rs(context, 8)),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.medicationName,
                          style: AppFonts.inter30BoldDark.copyWith(
                            fontSize: widget.rs(context, 20),
                          ),
                        ),
                        Text(
                          widget.dosage,
                          style: AppFonts.inter18BoldRed.copyWith(
                            color: AppColors.BlueGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: widget.rs(context, 16)),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختر المدة (اختياري)',
                  style: AppFonts.inter18BoldRed.copyWith(
                    color: Colors.blue,
                    fontSize: widget.rs(context, 18),
                  ),
                ),
              ),

              SizedBox(height: widget.rs(context, 8)),

              Row(
                children: [
                  Expanded(
                    child: DurationChip(
                      title: 'يوم واحد',
                      selected: selectedDuration == 'day',
                      onTap: () {
                        setState(() {
                          selectedDuration = 'day';
                        });
                      },
                    ),
                  ),

                  SizedBox(width: widget.rs(context, 8)),

                  Expanded(
                    child: DurationChip(
                      title: 'أسبوع',
                      selected: selectedDuration == 'week',
                      onTap: () {
                        setState(() {
                          selectedDuration = 'week';
                        });
                      },
                    ),
                  ),

                  SizedBox(width: widget.rs(context, 8)),

                  Expanded(
                    child: DurationChip(
                      title: 'أخرى',
                      selected: selectedDuration == 'other',
                      onTap: () {
                        setState(() {
                          selectedDuration = 'other';
                        });
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: widget.rs(context, 16)),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final duration = selectedDuration.isEmpty
                            ? 'other'
                            : selectedDuration;

                        Navigator.pop(context, duration);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          widget.rs(context, 52),
                        ),
                        backgroundColor: const Color(0xFF4285E5),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إيقاف مؤقت'),
                    ),
                  ),

                  SizedBox(width: widget.rs(context, 12)),

                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          widget.rs(context, 52),
                        ),
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF294B63),
                        side: const BorderSide(color: Color(0xFFD9DDE1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إلغاء'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
