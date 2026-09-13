import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderFeature extends StatefulWidget {
  const CalenderFeature({super.key, required this.onSelected, required this.beforeDate, this.initialDate});
  final ValueChanged<DateTime> onSelected;
  final DateTime? beforeDate;
  final DateTime? initialDate;
  @override
  State<CalenderFeature> createState() => _CalenderFeatureState();
}

class _CalenderFeatureState extends State<CalenderFeature> {
  late DateTime today;
  late DateTime selected;

  @override
  void initState() {
    super.initState();
    today = DateUtils.dateOnly(DateTime.now());
    
    DateTime initial = widget.initialDate != null 
        ? DateUtils.dateOnly(widget.initialDate!) 
        : today;
        
    DateTime minDate = widget.beforeDate != null ? DateUtils.dateOnly(widget.beforeDate!) : today;
    
    if (initial.isBefore(minDate)) {
      initial = minDate;
    }
    
    selected = initial;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Container(
            child: TableCalendar(
              focusedDay: selected,
              firstDay: DateTime.utc(2010,1,1),
              lastDay: DateTime.utc(2030,1,1),
              locale: 'ar_EG',
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  selected = DateUtils.dateOnly(selectedDay);
                }); 
                widget.onSelected(selected);
              },
              selectedDayPredicate: (day) => isSameDay(selected, day),
              enabledDayPredicate: (day) {
                DateTime minDate = widget.beforeDate != null ? DateUtils.dateOnly(widget.beforeDate!) : today;
                return !DateUtils.dateOnly(day).isBefore(minDate);
              },
              headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            ),
          ),
        ],
    );
  }
}
