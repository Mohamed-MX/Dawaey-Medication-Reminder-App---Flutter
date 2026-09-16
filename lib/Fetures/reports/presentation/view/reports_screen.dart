import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../view_model/reports_cubit.dart';
import '../view_model/reports_state.dart';
import '../../data/models/report_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReportsCubit()..loadReportsData(),
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Color(0xFFF7FBFD),
          body: SafeArea(
            child: ReportsBody(),
          ),
        ),
      ),
    );
  }
}

class ReportsBody extends StatelessWidget {
  const ReportsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (state is ReportsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  (state).message,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<ReportsCubit>().loadReportsData();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF169B88),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ReportsSuccess) {
          return RefreshIndicator(
            onRefresh: () => context.read<ReportsCubit>().loadReportsData(),
            color: const Color(0xFF169B88),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  // 1. Patient Header Card
                  _buildPatientCard(context, state),
                  const SizedBox(height: 16),

                  // 2. Filter Period Tabs (يومي, أسبوعي, شهري, سنوي)
                  _buildPeriodTabs(context, state.selectedPeriod),
                  const SizedBox(height: 16),

                  // 3. Stats Summary Card
                  _buildStatsCard(state.summary),
                  const SizedBox(height: 16),

                  // 4. Bar Chart Card (Dynamic for Daily, Weekly, Monthly, Yearly)
                  _buildWeeklyChartCard(
                    chartData: state.chartData,
                    chartLabels: state.chartLabels,
                    headerTitle: state.chartHeaderTitle,
                  ),
                  const SizedBox(height: 20),

                  // 5. Today's Medications Header & List
                  _buildTodayMedicationsSection(state.todayMedications),
                  const SizedBox(height: 20),

                  // 6. Motivation Banner
                  _buildMotivationBanner(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }

        return const Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
      },
    );
  }

  // 1. Patient Header Widget
  Widget _buildPatientCard(BuildContext context, ReportsSuccess state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF5FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFC7E2E8),
                child: Icon(Icons.person, color: Color(0xFF1B363F), size: 28),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.patientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B363F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (state.patientAge != null)
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'العمر: ${state.patientAge} سنة',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
          const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1B363F)),
        ],
      ),
    );
  }

  // 2. Period Filter Tabs Widget
  Widget _buildPeriodTabs(BuildContext context, String selectedPeriod) {
    final periods = ['سنوي', 'شهري', 'أسبوعي', 'يومي'];

    return Row(
      children: periods.map((period) {
        final isSelected = period == selectedPeriod;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              context.read<ReportsCubit>().changePeriod(period);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF169B88)
                    : const Color(0xFFEEF5FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color:
                        isSelected ? Colors.white : const Color(0xFF1B363F),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 3. Stats Summary Card Widget
  Widget _buildStatsCard(ReportSummaryModel summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F1F5)),
      ),
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 85,
            height: 85,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: summary.commitmentPercentage / 100,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFE0F2F1),
                  color: const Color(0xFF169B88),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${summary.commitmentPercentage}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B363F),
                        ),
                      ),
                      const Text(
                        'نسبة الالتزام',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Vertical divider
          Container(height: 70, width: 1, color: Colors.grey.shade200),
          const SizedBox(width: 16),
          // Stats Counters (Taken, Missed, Pending)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  count: summary.takenCount,
                  label: 'تم أخذه',
                ),
                _buildStatColumn(
                  icon: Icons.cancel,
                  iconColor: Colors.red.shade400,
                  count: summary.missedCount,
                  label: 'لم يتم أخذه',
                ),
                _buildStatColumn(
                  icon: Icons.access_time_filled,
                  iconColor: Colors.orange.shade300,
                  count: summary.pendingCount,
                  label: 'في الانتظار',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required Color iconColor,
    required int count,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B363F),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  // 4. Bar Chart Card Widget
  Widget _buildWeeklyChartCard({
    required List<double> chartData,
    required List<String> chartLabels,
    required String headerTitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F1F5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Color(0xFF169B88)),
              const SizedBox(width: 6),
              Text(
                headerTitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF169B88),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: Color(0xFF169B88)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Y-axis percentage labels
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('100%',
                      style: TextStyle(fontSize: 9, color: Colors.grey)),
                  SizedBox(height: 18),
                  Text('75%',
                      style: TextStyle(fontSize: 9, color: Colors.grey)),
                  SizedBox(height: 18),
                  Text('50%',
                      style: TextStyle(fontSize: 9, color: Colors.grey)),
                  SizedBox(height: 18),
                  Text('25%',
                      style: TextStyle(fontSize: 9, color: Colors.grey)),
                  SizedBox(height: 18),
                  Text('0%',
                      style: TextStyle(fontSize: 9, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 8),
              // Bars
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:
                      List.generate(chartLabels.length, (index) {
                    final heightRatio = index < chartData.length
                        ? chartData[index]
                        : 0.0;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: chartLabels.length > 6 ? 14 : 18,
                          height: 120 * heightRatio,
                          decoration: BoxDecoration(
                            color: heightRatio > 0
                                ? const Color(0xFF169B88)
                                : const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chartLabels[index],
                          style: const TextStyle(
                              fontSize: 9, color: Color(0xFF1B363F)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Today's Medications Section Widget
  Widget _buildTodayMedicationsSection(
      List<TodayMedicationReport> medications) {
    // Format today's date dynamically in Arabic
    final now = DateTime.now();
    final arabicDays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    final arabicMonths = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final dayName = arabicDays[now.weekday - 1];
    final monthName = arabicMonths[now.month - 1];
    final todayFormatted = '$dayName، ${now.day} $monthName';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F1F5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.medication_outlined,
                      color: Color(0xFF169B88), size: 24),
                  SizedBox(width: 8),
                  Text(
                    'أدوية اليوم',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B363F),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    todayFormatted,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          medications.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'لا يوجد أدوية مسجلة لهذا اليوم',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                )
              : Column(
                  children: medications
                      .map((med) => _buildMedicationRow(med))
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildMedicationRow(TodayMedicationReport med) {
    Color statusBg;
    Color statusText;
    String statusLabel;
    IconData statusIcon;

    if (med.status == 'taken') {
      statusBg = const Color(0xFFE3F4EC);
      statusText = const Color(0xFF169B88);
      statusLabel = 'تم أخذه';
      statusIcon = Icons.check_circle;
    } else if (med.status == 'missed') {
      statusBg = const Color(0xFFFFEBEE);
      statusText = Colors.red;
      statusLabel = 'لم يتم أخذه';
      statusIcon = Icons.cancel;
    } else {
      statusBg = const Color(0xFFFFF8E1);
      statusText = Colors.orange.shade800;
      statusLabel = 'في الانتظار';
      statusIcon = Icons.error_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDF3F7)),
      ),
      child: Row(
        children: [
          // Medication Name & Icon (right side in RTL)
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.medication,
                    color: Color(0xFF169B88), size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B363F),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        med.dosage,
                        style:
                            const TextStyle(fontSize: 11, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Time
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                med.time,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Status Pill Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusText),
                const SizedBox(width: 4),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 6. Motivation Banner Widget
  Widget _buildMotivationBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5F8), Color(0xFFE2F3F0)],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_outlined,
                  color: Color(0xFF169B88), size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'معاً.. نحو حياة أكثر صحة',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF169B88),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'التزامك اليوم يصنع فرقاً غداً',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border,
                color: Color(0xFF169B88), size: 20),
          ),
        ],
      ),
    );
  }
}
