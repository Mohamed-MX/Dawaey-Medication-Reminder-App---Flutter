import 'package:flutter/material.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;

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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                    Icon(Icons.arrow_forward, size: 20, color: Color(0xFF1B363F)), // Forward icon because RTL
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
                  // TODO: Submit action
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
                    const Icon(Icons.arrow_back, size: 20, color: Colors.white), // Back icon because RTL
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12))),
                  child: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
                Expanded(
                  child: TextField(
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
              Expanded(child: _buildUsageMethod('قرص', Icons.circle_outlined, true)),
              const SizedBox(width: 12),
              Expanded(child: _buildUsageMethod('كبسولة', Icons.medication, false)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildUsageMethod('شراب', Icons.local_drink, false)),
              const SizedBox(width: 12),
              Expanded(child: _buildUsageMethod('حقنة', Icons.vaccines, false)),
            ],
          ),
          const SizedBox(height: 12),
          _buildUsageMethod('أخرى', Icons.close, false, fullWidth: true),
        ],
      ),
    );
  }

  Widget _buildUsageMethod(String title, IconData icon, bool selected, {bool fullWidth = false}) {
    return Container(
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
          _buildFrequencyOption('مرة واحدة يوميًا', false),
          const SizedBox(height: 12),
          _buildFrequencyOption('مرتين يوميًا', true),
          const SizedBox(height: 12),
          _buildFrequencyOption('ثلاث مرات يوميًا', false),
          const SizedBox(height: 12),
          _buildFrequencyOption('كل يومين', false),
          const SizedBox(height: 12),
          // User requested adding "every X hours" option here
          _buildFrequencyOption('كل (عدد الساعات) ساعة', false),
        ],
      ),
    );
  }

  Widget _buildFrequencyOption(String title, bool selected) {
    return Container(
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
    );
  }

  // --- Step 4 ---
  Widget _buildStep4() {
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
          _buildTimeOption('08:00'),
          const SizedBox(height: 12),
          _buildTimeOption('14:00'),
          const SizedBox(height: 12),
          _buildTimeOption('20:00'),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              border: Border.all(color: Colors.teal),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, color: Colors.teal),
                SizedBox(width: 8),
                Text('إضافة موعد جديد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimeOption(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          const Icon(Icons.delete_outline, color: Colors.red),
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
          _buildInputField('تاريخ البداية', '2025/09/05', icon: Icons.calendar_today),
          const SizedBox(height: 16),
          _buildInputField('تاريخ الانتهاء (اختياري)', 'اختر التاريخ', icon: Icons.calendar_today),
          const SizedBox(height: 16),
          _buildInputField('عدد الجرعات المتبقية (اختياري)', 'مثال: 30'),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
        const SizedBox(height: 8),
        TextField(
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
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('ملاحظات إضافية (اختياري)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B363F))),
          const SizedBox(height: 8),
          TextField(
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
