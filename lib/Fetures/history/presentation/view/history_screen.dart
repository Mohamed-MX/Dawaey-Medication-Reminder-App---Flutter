import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dawaey/Fetures/history/presentation/widgets/medician_card.dart';
import 'package:dawaey/Fetures/medications/data/model/doise_model.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:dawaey/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<Map<String, dynamic>> medicines = [
    {
      'name': 'أملوديب',
      'status': DoseStatus.taken,
      'dose': '5 مجم',
      'time': TimeOfDay(hour: 9, minute: 0),
      'primaryContainerColor': const Color(0xFFF3FAF6),
      'secondaryContainerColor': const Color(0xFFE8F6EF),
    },
    {
      'name': 'مينوكسيد',
      'status': DoseStatus.missed,
      'dose': '500 مجم',
      'time': TimeOfDay(hour: 14, minute: 0),
      'primaryContainerColor': const Color(0xFFFFF5F6),
      'secondaryContainerColor': const Color(0xFFFDECEF),
    },
    {
      'name': 'أتورفاستاتين',
      'status': DoseStatus.pending,
      'dose': '20 مجم',
      'time': TimeOfDay(hour: 8, minute: 0),
      'primaryContainerColor': const Color(0xFFF5F8FD),
      'secondaryContainerColor': const Color(0xFFF0F4FA),
    },
  ];
  double rs(BuildContext context, double value) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 382).clamp(0.9, 1.2);

    return value * scale;
  }

  DateTime requiredMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime selected = DateTime(DateTime.now().year, DateTime.now().month);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سجل الأدوية',
          style: AppFonts.inter30BoldDark.copyWith(fontSize: rs(context, 30)),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, size: rs(context, 30)),
          color: AppColors.textDark,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    requiredMonth = DateTime(
                      requiredMonth.year,
                      requiredMonth.month + 1,
                    );
                    selected = requiredMonth;
                  });
                },
                icon: Icon(Icons.arrow_back_ios_outlined),
              ),
              TextButton(
                onPressed: () async {
                  final selectedDate = await showMonthYearPicker(
                    context: context,
                    initialDate: requiredMonth,
                    firstDate: DateTime(2010),
                    lastDate: DateTime(2030),
                  );
                  setState(() {
                    requiredMonth = DateTime(
                      selectedDate?.year ?? DateTime.now().year,
                      selectedDate?.month ?? DateTime.now().month,
                      1,
                    );
                    selected = requiredMonth;
                  });
                },
                child: Text(
                  "${DateFormat('MMMM yyyy', 'ar').format(requiredMonth)}",
                  style: AppFonts.inter30BoldDark.copyWith(
                    fontSize: rs(context, 18),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    requiredMonth = DateTime(
                      requiredMonth.year,
                      requiredMonth.month - 1,
                    );
                    selected = requiredMonth;
                  });
                },
                icon: Icon(Icons.arrow_forward_ios_outlined),
              ),
            ],
          ),
          DatePicker(
            daysCount: DateUtils.getDaysInMonth(
              requiredMonth.year,
              requiredMonth.month,
            ),
            dateTextStyle: TextStyle(fontSize: rs(context, 18), fontWeight: FontWeight.bold),
            dayTextStyle: TextStyle(fontSize: rs(context, 18), color: Colors.grey),
            monthTextStyle: TextStyle(fontSize: rs(context, 18), color: Colors.grey),
            width: rs(context, 60),
            height: rs(context, 80),
            key: ValueKey(requiredMonth),
            requiredMonth,
            locale: 'ar_EG',
            selectionColor: AppColors.blackBlue,
            initialSelectedDate: requiredMonth,
            onDateChange: (selectedDate) {
              setState(() {
                selected = selectedDate;
              });
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: medicines.length,
              itemBuilder: (context, index) => MedicianCard(
                name: medicines[index]['name'],
                dose: medicines[index]['dose'],
                status: medicines[index]['status'],
                time: medicines[index]['time'],
                primeryContainerColor:
                    medicines[index]['primaryContainerColor'],
                secondryContainerColor:
                    medicines[index]['secondaryContainerColor'],
              ),
            ),
          ),
      
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: rs(context, 16) , vertical: rs(context, 32) ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xffEAF1FC),
              borderRadius: BorderRadius.circular(20)
            ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding:  EdgeInsets.symmetric(horizontal: rs(context, 16.0)  , vertical:  rs(context, 16.0)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                       decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(999)
                       ),
                       width: rs(context, 25),
                       height: rs(context, 25),
                       child: Center(child: Icon(Icons.done , color: Colors.white,size: 16,)),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(right: rs(context, 16)),
                      child: Text("تم أخذه" , style: AppFonts.inter30BoldDark.copyWith(fontSize: rs(context, 18)),),
                    ),
                    SizedBox(height: 36,child: VerticalDivider(thickness: rs(context, 1),),),
                     Container(
                       decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(999)
                       ),
                       width: rs(context, 25),
                       height: rs(context, 25),
                       child: Center(child: Icon(Icons.close , color: Colors.white,size: rs(context , 16),)),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(right: rs(context, 16)),
                      child: Text("لم يتم أخذه" , style: AppFonts.inter30BoldDark.copyWith(fontSize: rs(context, 18)),),
                    ),
                    SizedBox(height: 36,child: VerticalDivider(thickness: rs(context, 1),),),
                     Container(
                       decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(999)
                       ),
                       width: rs(context , 25),
                       height: rs(context , 25),
                       child: Center(child: Icon(Icons.access_time , color: Colors.white,size: rs(context, 16),)),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(right: rs(context, 16)),
                      child: Text("قيد الانتظار" , style: AppFonts.inter30BoldDark.copyWith(fontSize: rs(context, 18)),),
                    ),
                  ],
                            ),
                ),
              ),
          ),
        )
        ],
      ),
    );
  }
}
