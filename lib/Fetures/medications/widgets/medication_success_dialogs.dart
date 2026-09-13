import 'package:dawaey/core/theme/fonts.dart';
import 'package:flutter/material.dart';

void showDeleteSuccessDialog(
  BuildContext context,
  double Function(BuildContext, double) rs,
) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: rs(context, 56),
                height: rs(context, 56),
                padding: EdgeInsets.all(
                  rs(context, 8),
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    181,
                    244,
                    212,
                    184,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.delete,
                  size: rs(context, 30),
                  color: const Color(0xffEF4444),
                ),
              ),
          
              SizedBox(
                height: rs(context, 12),
              ),
          
              Text(
                'تم حذف الدواء',
                textAlign: TextAlign.center,
                style: AppFonts.inter30BoldDark.copyWith(
                  fontSize: rs(context, 24),
                ),
              ),
          
              SizedBox(
                height: rs(context, 6),
              ),
          
              Text(
                'تم حذف أملوديبين من قائمتك',
                textAlign: TextAlign.center,
                style: AppFonts.inter18BoldRed.copyWith(
                  fontSize: rs(context, 18),
                ),
              ),
            ],
          ),
        ),

        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                  181,
                  244,
                  212,
                  184,
                ),
                foregroundColor: Colors.blue,
                minimumSize: Size(
                  rs(context, 120),
                  rs(context, 50),
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'حسنا',
                style: AppFonts
                    .inter18RegularSoftMintGreen
                    .copyWith(
                  color: Colors.blue,
                  fontSize: rs(context, 18),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showPauseSuccessDialog(

  BuildContext context,
  double Function(BuildContext, double) rs,
  String duration,
) {
  final durationText = duration == 'day'
      ? 'يوم واحد'
      : duration == 'week'
          ? 'أسبوع واحد'
          : 'مدة مخصصة';

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: rs(context, 56),
                height: rs(context, 56),
                padding: EdgeInsets.all(
                  rs(context, 8),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4E2F3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.pause,
                  size: rs(context, 30),
                  color: const Color(0xFF8FA6C3),
                ),
              ),
          
              SizedBox(
                height: rs(context, 12),
              ),
          
              Text(
                'تم إيقاف الدواء مؤقتا',
                textAlign: TextAlign.center,
                style: AppFonts.inter30BoldDark.copyWith(
                  fontSize: rs(context, 24),
                ),
              ),
          
              SizedBox(
                height: rs(context, 6),
              ),
          
              Text(
                'سيتم إيقاف التنبيهات لمدة $durationText',
                textAlign: TextAlign.center,
                style: AppFonts.inter18BoldRed.copyWith(
                  fontSize: rs(context, 18),
                ),
              ),
            ],
          ),
        ),

        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFD4E2F3),
                foregroundColor: Colors.blue,
                minimumSize: Size(
                  rs(context, 120),
                  rs(context, 50),
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'حسنا',
                style: AppFonts
                    .inter18RegularSoftMintGreen
                    .copyWith(
                  color: Colors.blue,
                  fontSize: rs(context, 18),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}