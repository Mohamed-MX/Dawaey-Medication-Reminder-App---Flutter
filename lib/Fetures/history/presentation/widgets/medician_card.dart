import 'package:dawaey/Fetures/medications/data/model/doise_model.dart';
import 'package:dawaey/Fetures/medications/presentation/cubit/medications_state.dart';
import 'package:flutter/material.dart';

class MedicianCard extends StatelessWidget {
  const MedicianCard({
    super.key,
    required this.name,
    required this.dose,
    required this.status,
    required this.time,
    required this.primeryContainerColor,
    required this.secondryContainerColor,
  });

  final String name;
  final String dose;
  final TimeOfDay time;
  final DoseStatus status;
  final Color primeryContainerColor;
  final Color secondryContainerColor;

  double _rs(BuildContext context, double value) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 382).clamp(0.9, 1.2);
    return value * scale;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: _rs(context, 16.0)),
      child: Container(
        height: _rs(context, 55),
        padding: EdgeInsets.symmetric(horizontal: _rs(context, 12)),
        decoration: BoxDecoration(
          color: primeryContainerColor,
          borderRadius: BorderRadius.circular(_rs(context, 20)),
        ),
        child: Row(
          children: [
            _buildStatusIcon(context),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _rs(context, 8)),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "$name $dose",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _rs(context, 15),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: _rs(context, 22),
              child: VerticalDivider(
                color: secondryContainerColor,
                thickness: 1,
              ),
            ),

            SizedBox(width: _rs(context, 8)),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: _rs(context, 12),
                vertical: _rs(context, 6),
              ),
              decoration: BoxDecoration(
                color: secondryContainerColor,
                borderRadius: BorderRadius.circular(_rs(context, 25)),
              ),
              child: Text(
                "${time.minute.toString().padLeft(2, '0')} : "
                "${time.hour % 12 == 0 ? 12 : time.hour % 12} "
                "${time.hour >= 12 ? 'م' : 'ص'}",
                style: TextStyle(
                  fontSize: _rs(context, 13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _buildStatusIcon(BuildContext context) {
    final double iconBoxSize = _rs(context, 36);
    final double iconSize = _rs(context, 24);

    if (status == DoseStatus.taken) {
      return Container(
        width: iconBoxSize,
        height: iconBoxSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
        child: Icon(Icons.done, size: iconSize, color: Colors.white),
      );
    } else if (status == DoseStatus.missed) {
      return Container(
        width: iconBoxSize,
        height: iconBoxSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Icon(Icons.close, size: iconSize, color: const Color(0xffF5F8FD),),
      );
    } else {
      return Container(
        width: iconBoxSize,
        height: iconBoxSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        child: Icon(Icons.access_time, size: iconSize, color: Colors.white),
      );
    }
  }
}