import 'package:flutter/material.dart';

class home_caretaker_screen extends StatefulWidget {
  const home_caretaker_screen({super.key});

  @override
  State<home_caretaker_screen> createState() => _home_caretaker_screenState();
}

class _home_caretaker_screenState extends State<home_caretaker_screen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // TODO: Add navigation logic later to the created empty screens
  }

  @override
  Widget build(BuildContext context) {
    // Wrapping the entire Scaffold in Directionality RTL to make the BottomAppBar
    // arrange children from right to left naturally.
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'متابعة العائلة',
            style: TextStyle(
              color: Color(0xFF1B363F),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: _buildBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: FAB action
          },
          backgroundColor: Colors.teal,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: Colors.white,
          elevation: 10,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavBarItem(Icons.home_outlined, 'الرئيسية', 0),
                    const SizedBox(width: 24),
                    _buildNavBarItem(Icons.medication_outlined, 'الأدوية', 1),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavBarItem(Icons.calendar_today_outlined, 'المواعيد', 2),
                    const SizedBox(width: 24),
                    _buildNavBarItem(Icons.notifications_outlined, 'التنبيهات', 3),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Dropdown section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  // user select dropdown to select from list of patients
                },
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey,
                      // TODO: Add actual image
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'أحمد محمد',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B363F),
                          ),
                        ),
                        Text(
                          'أبي',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.teal, size: 20),
                  onPressed: () {
                    // Add new users (patients to monitor)
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Weekly Commitment Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نسبة الالتزام هذا الأسبوع',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B363F),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'ممتاز',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'استمروا على هذا المستوى المميز',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CircularProgressIndicator(
                            value: 0.86,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.teal,
                            strokeWidth: 6,
                          ),
                          const Center(
                            child: Text(
                              '86%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B363F),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Bar Chart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar('أحد', 0.5, Colors.red, false),
                    _buildBar('إثنين', 0.7, Colors.teal, true),
                    _buildBar('ثلاثاء', 0.6, Colors.teal, true),
                    _buildBar('أربعاء', 0.8, Colors.teal, true),
                    _buildBar('خميس', 0.4, Colors.red, false),
                    _buildBar('جمعة', 0.75, Colors.teal, true),
                    _buildBar('سبت', 0.5, Colors.red, false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Today's Medications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'أدوية اليوم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B363F),
                ),
              ),
              Text(
                'تم 3/2',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildMedicationCard(
            'أملوديبين 5 مجم',
            '9:00 ص',
            true, // taken
            false, // upcoming
          ),
          const SizedBox(height: 16),
          _buildMedicationCard(
            'ميتفورمين 500 مجم',
            '2:00 م',
            false, // missed
            false, // upcoming
          ),
          const SizedBox(height: 16),
          _buildMedicationCard(
            'أتورفاستاتين 20 مجم',
            '8:00 م',
            false, // missed
            true, // upcoming
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double heightRatio, Color color, bool taken) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 80 * heightRatio,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        CircleAvatar(
          radius: 3,
          backgroundColor: taken ? Colors.transparent : Colors.red,
        ),
      ],
    );
  }

  Widget _buildMedicationCard(
      String name, String time, bool taken, bool upcoming) {
    Color bgColor;
    Color iconColor;
    IconData icon;

    if (upcoming) {
      bgColor = Colors.white;
      iconColor = Colors.teal;
      icon = Icons.access_time;
    } else if (taken) {
      bgColor = Colors.white;
      iconColor = Colors.teal;
      icon = Icons.check_circle;
    } else {
      bgColor = Colors.red.shade50;
      iconColor = Colors.red;
      icon = Icons.cancel;
    }

    return InkWell(
      onTap: () {
        // Navigate to user profile
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: upcoming || taken
              ? Border.all(color: Colors.grey.shade200)
              : Border.all(color: Colors.red.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  time,
                  style: TextStyle(
                    color: upcoming ? Colors.teal : (taken ? Colors.teal : Colors.red),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B363F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
