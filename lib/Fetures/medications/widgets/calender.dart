import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderFeature extends StatefulWidget {
  const CalenderFeature({super.key , required this.onSelected , required this.beforeDate});
  final ValueChanged<DateTime> onSelected ;
  final DateTime? beforeDate ;
  @override
  State<CalenderFeature> createState() => _CalenderFeatureState();
}

class _CalenderFeatureState extends State<CalenderFeature> {
    DateTime today = DateUtils.dateOnly(DateTime.now());
    DateTime selected = DateUtils.dateOnly(DateTime.now());
  @override
  Widget build(BuildContext context) {

    return Column(
        children: [
          Container(
            child: TableCalendar(
              focusedDay: selected,
              firstDay: DateTime.utc(2010,1,1),
              lastDay: DateTime.utc(2030,1,1),
              locale: 'ar_EG' ,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selected = DateUtils.dateOnly(selectedDay);
          
                }); 
                widget.onSelected(selected);
              },
              selectedDayPredicate: (day) => isSameDay(selected, day),
              enabledDayPredicate: (day) {
                return !day.isBefore(widget.beforeDate ?? today);
              },
              headerStyle: HeaderStyle(formatButtonVisible: false , titleCentered: true),
            ),
          ),
        ],
      
    );
  }
}
