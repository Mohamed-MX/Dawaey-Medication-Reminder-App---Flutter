import 'package:dawaey/Fetures/medications/widgets/calender.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/medications_cubit.dart';
import '../../data/model/medication_model.dart';
import '../../data/model/doise_model.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;
  DateTime? startSelectedDate ;
  DateTime? endSelectedDate ;
  List<TimeOfDay?> selectedTimes = List.filled(4, null);

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController doseController = TextEditingController();
  final TextEditingController remainingDosesController = TextEditingController();
  final TextEditingController pillsLeftController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedUsageMethod = 'قرص';
  String selectedFrequency = 'مرتين يوميًا';

  @override
  void dispose() {
    nameController.dispose();
    doseController.dispose();
    remainingDosesController.dispose();
    pillsLeftController.dispose();
    notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }
    double rs(BuildContext context, double value) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 382).clamp(0.9, 1.2);

    return value * scale;
  }
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B363F)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'إضافة دواء جديد',
            style: TextStyle(
              color: Color(0xFF1B363F),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            _buildProgressBar(),
            const SizedBox(height: 8),
            Text(
              '${_currentPage + 1}/$_totalPages',
              style: const TextStyle(
                color: Color(0xFF1B363F),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                  _buildStep6(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(_totalPages, (index) {
          bool isActive = index <= _currentPage;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Colors.teal : Colors.teal.withOpacity(0.3),
                  ),
                ),
                if (index < _totalPages - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive ? Colors.teal : Colors.teal.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          );
        }).toList()
          ..removeLast() // because the last one shouldn't have a trailing line
          ..add(
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == _totalPages - 1
                    ? Colors.teal
                    : Colors.teal.withOpacity(0.3),
              ),
            ),
          ),
      ),
    );
  }

  // --- Footer Buttons ---
  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_back, size: 20, color: Color(0xFF1B363F)), // Forward icon because RTL
                    SizedBox(width: 8),
                    Text(
                      'السابق',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B363F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentPage == _totalPages - 1) {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إدخال اسم الدواء')));
                    return;
                  }
                  
                  final medId = DateTime.now().millisecondsSinceEpoch.toString();
                  final newMed = MedicationModel(
                    id: medId,
                    patientId: 'user_1',
                    medicationName: name,
                    administrationRoute: selectedUsageMethod,
                    dosage: doseController.text.trim(),
                    frequency: _mapFrequency(selectedFrequency),
                    intakeTimes: selectedTimes.take(_getSlotCount()).where((t) => t != null).cast<TimeOfDay>().toList(),
                    startDate: startSelectedDate ?? DateTime.now(),
                    endDate: endSelectedDate ?? DateTime.now().add(const Duration(days: 30)),
                    remainingDoses: int.tryParse(remainingDosesController.text) ?? 0,
                    remainingMedicationAmount: int.tryParse(pillsLeftController.text) ?? 0,
                    notes: notesController.text,
                    status: MedicationStatus.active,
                  );

                  context.read<MedicationsCubit>().addMedication(newMed);
                  Navigator.of(context).pop();
                } else {
                  _nextPage();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF106A8E), // dark blue/teal matching design
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == _totalPages - 1 ? 'إضافة الدواء' : 'التالي',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_currentPage < _totalPages - 1) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20, color: Colors.white), // Back icon because RTL
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 1 ---
  MedicationFrequency _mapFrequency(String freq) {
    switch (freq) {
      case 'مرة واحدة يوميًا': return MedicationFrequency.onceDaily;
      case 'مرتين يوميًا': return MedicationFrequency.twiceDaily;
      case 'ثلاث مرات يوميًا': return MedicationFrequency.threeTimesDaily;
      case 'أربع مرات يوميًا': return MedicationFrequency.fourTimesDaily;
      default: return MedicationFrequency.onceDaily;
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const Text('اسم الدواء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade50),
            child: Icon(Icons.medication, size: 50, color: Colors.blue.shade300),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: const Text('اسم الدواء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'مثال: أموكسيسيلين',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: const Text('أو اختر من الأدوية الشائعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          ),
          const SizedBox(height: 12),
          _buildCommonMed('ميتفورمين'),
          const SizedBox(height: 12),
          _buildCommonMed('أموكسيسيلين'),
          const SizedBox(height: 12),
          _buildCommonMed('أوميبرازول'),
        ],
      ),
    );
  }

  Widget _buildCommonMed(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          Container(
            decoration: BoxDecoration(color: Colors.teal.shade100, shape: BoxShape.circle),
            padding: const EdgeInsets.all(4),
            child: const Icon(Icons.add, color: Colors.teal, size: 20),
          ),
        ],
      ),
    );
  }

  // --- Step 2 ---
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const Text('الجرعة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.yellow.shade50),
            child: Icon(Icons.medication_liquid, size: 50, color: Colors.yellow.shade700), // Approximate icon
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: const Text('الجرعة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: doseController,
                    decoration: const InputDecoration(
                      hintText: 'مثال: 500 مجم',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: const Text('طريقة الاستخدام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildUsageMethod('قرص', Icons.circle_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _buildUsageMethod('كبسولة', Icons.medication)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildUsageMethod('شراب', Icons.local_drink)),
              const SizedBox(width: 12),
              Expanded(child: _buildUsageMethod('حقنة', Icons.vaccines)),
            ],
          ),
          const SizedBox(height: 12),
          _buildUsageMethod('أخرى', Icons.close, fullWidth: true),
        ],
      ),
    );
  }

  Widget _buildUsageMethod(String title, IconData icon, {bool fullWidth = false}) {
    bool selected = selectedUsageMethod == title;
    return InkWell(
      onTap: () {
        setState(() {
          selectedUsageMethod = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.teal.shade50 : Colors.white,
          border: Border.all(color: selected ? Colors.teal : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: selected ? Colors.teal : const Color(0xFF1B363F))),
              ],
            ),
            if (selected) const Icon(Icons.radio_button_checked, color: Colors.teal),
          ],
        ),
      ),
    );
  }

  // --- Step 3 ---
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const Text('معدل التكرار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade50),
            child: Icon(Icons.calendar_month, size: 50, color: const Color(0xFF106A8E)),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: const Text('كم مرة يتم تناوله؟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          ),
          const SizedBox(height: 16),
          _buildFrequencyOption('مرة واحدة يوميًا'),
          const SizedBox(height: 12),
          _buildFrequencyOption('مرتين يوميًا'),
          const SizedBox(height: 12),
          _buildFrequencyOption('ثلاث مرات يوميًا'),
          const SizedBox(height: 12),
          _buildFrequencyOption('أربع مرات يوميًا'),
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(String title) {
    bool selected = selectedFrequency == title;
    return InkWell(
      onTap: () {
        setState(() {
          selectedFrequency = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? Colors.teal.shade50 : Colors.white,
          border: Border.all(color: selected ? Colors.teal : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: selected ? Colors.teal : const Color(0xFF1B363F))),
            Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? Colors.teal : Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- Step 4 ---
  int _getSlotCount() {
    switch (selectedFrequency) {
      case 'مرة واحدة يوميًا': return 1;
      case 'مرتين يوميًا': return 2;
      case 'ثلاث مرات يوميًا': return 3;
      case 'أربع مرات يوميًا': return 4;
      default: return 1;
    }
  }

  Widget _buildStep4() {
    final int slotCount = _getSlotCount();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const Text('مواعيد التناول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade50),
            child: Icon(Icons.access_time, size: 50, color: const Color(0xFF106A8E)),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: const Text('اختر مواعيد التناول', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          ),
          const SizedBox(height: 16),
          ...List.generate(slotCount, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildTimeOption(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeOption(int index) {
    final time = selectedTimes[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
         time == null 
          ? const Text("بالرجاء تحديد موعد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))) 
          : Text("${time.hour % 12 == 0 ? 12 : time.hour % 12}:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'مساء' : 'صباحا'}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
         IconButton(
          onPressed: () async {
            TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: time ?? TimeOfDay.now(),
            );
            if (selectedTime != null) {
              setState(() {
                selectedTimes[index] = selectedTime;
                
                // Auto-fill subsequent times if the first slot is selected
                if (index == 0) {
                  int interval = 24;
                  if (selectedFrequency == 'مرتين يوميًا') interval = 12;
                  else if (selectedFrequency == 'ثلاث مرات يوميًا') interval = 8;
                  else if (selectedFrequency == 'أربع مرات يوميًا') interval = 6;

                  for (int i = 1; i < _getSlotCount(); i++) {
                    int newHour = (selectedTime.hour + (interval * i)) % 24;
                    selectedTimes[i] = TimeOfDay(hour: newHour, minute: selectedTime.minute);
                  }
                }
              });
            }
          }, 
          icon: const Icon(Icons.access_time), 
          color: Colors.red
         ),
        ],
      ),
    );
  }

  // --- Step 5 ---
  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          const Text('مدة الاستخدام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.shade50),
            child: Icon(Icons.calendar_today, size: 50, color: const Color(0xFF106A8E)),
          ),
          const SizedBox(height: 32),
          _buildDateField('تاريخ البداية', 'start', icon: Icons.calendar_today),
          const SizedBox(height: 16),
          _buildDateField('تاريخ الانتهاء (اختياري)' , 'end' , icon: Icons.calendar_today),
          const SizedBox(height: 16),
          _buildInputField('عدد الجرعات المتبقية (اختياري)', 'مثال: 30', controller: remainingDosesController),
        ],
      ),
    );
  }

    Widget _buildDateField(String label,  String type, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: type == "start" ? (startSelectedDate == null ? 'برجاء اختيار التاريخ من التقويم' : '${startSelectedDate!.year} / ${startSelectedDate!.month} / ${startSelectedDate!.day}'): (endSelectedDate == null ? 'برجاء اختيار التاريخ من التقويم' : '${endSelectedDate!.year} / ${endSelectedDate!.month} / ${endSelectedDate!.day}'),
            prefixIcon: icon != null ? IconButton( onPressed: () async{
                 final selectedDatev =  await showDialog<DateTime>(
                  context: context,
                   builder: (context){
                    DateTime? selected = type == 'start' ? startSelectedDate : endSelectedDate;
                        return AlertDialog(
                          content: SingleChildScrollView(
                            child: SizedBox(
                              width: rs(context, 350),
                              child: CalenderFeature( 
                                beforeDate: type == 'start' ? null : startSelectedDate, 
                                initialDate: type == 'start' ? startSelectedDate : endSelectedDate,
                                onSelected: (value) {
                                  selected = value;
                                }
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(onPressed: (){
                              Navigator.pop(context , selected );
                            }, child: const Text("تأكيد"))
                          ],
                        );
                   });
                   
                   if (selectedDatev != null) {
                     setState(() {
                      type == 'start' ? startSelectedDate = selectedDatev : endSelectedDate = selectedDatev ;
                     });
                   }
            } , icon: Icon(icon), color: Colors.grey) : null,

            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }
  Widget _buildInputField(String label, String hint, {IconData? icon, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  // --- Step 6 ---
  Widget _buildStep6() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Text('معلومات إضافية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B363F)))),
          const SizedBox(height: 32),
          const Text('كم قرصا متبقي لديك ؟', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          const SizedBox(height: 8),
          TextField(
            controller: pillsLeftController,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('ملاحظات إضافية (اختياري)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          const SizedBox(height: 8),
          TextField(
            controller: notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'أي ملاحظات مهمة حول الدواء...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
        ],
      ),
    );
  }
}
