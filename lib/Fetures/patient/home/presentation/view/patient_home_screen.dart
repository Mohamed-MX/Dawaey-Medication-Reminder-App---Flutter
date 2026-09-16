import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/history/data/model/history_data_model.dart';
import 'package:dawaey/Fetures/medications/data/model/doise_model.dart';
import 'package:dawaey/Fetures/patient/home/presentation/view_model/patient_home_cubit.dart';
import 'package:dawaey/Fetures/patient/home/presentation/view_model/patient_home_state.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:dawaey/core/theme/fonts.dart';

class PatientHomeScreen extends StatelessWidget {
  final UserModel currentUser;

  const PatientHomeScreen({
    super.key,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientHomeCubit, PatientHomeState>(
      builder: (context, state) {
        if (state is PatientHomeLoading || state is PatientHomeInitial) {
          return const _LoadingStateView();
        }

        if (state is PatientHomeError) {
          return _ErrorStateView(message: state.message);
        }

        if (state is PatientHomeLoaded) {
          return _PatientHomeBody(
            currentUser: currentUser,
            state: state,
          );
        }

        return const Scaffold(
          backgroundColor: Color(0xffF6FBFC),
        );
      },
    );
  }
}

// ==================================================================
// HOME BODY
// ==================================================================

class _PatientHomeBody extends StatelessWidget {
  final UserModel currentUser;
  final PatientHomeLoaded state;

  const _PatientHomeBody({
    required this.currentUser,
    required this.state,
  });

  double _rs(BuildContext context, double value) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 382).clamp(0.9, 1.5);
    return value * scale;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "صباح الخير";
    return "مساء الخير";
  }

  String _getUserName() {
    final name = currentUser.name.trim();
    return name.isEmpty ? "يا صديقي" : "يا $name";
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted = DateFormat('EEEE , d MMMM yyyy', 'ar').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xffF6FBFC),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isLandscape = orientation == Orientation.landscape;

            // --------------------------------------------------------
            // LANDSCAPE LAYOUT (شاشتان بجانب بعضهما)
            // --------------------------------------------------------
            if (isLandscape) {
              return Row(
                children: [
                  // العمود الأيسر: الهيدر والتاريخ وكارت الدواء الحالي
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: _rs(context, 12),
                        vertical: _rs(context, 8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(context),
                          SizedBox(height: _rs(context, 8)),
                          Center(
                            child: Text(
                              dateFormatted,
                              style: AppFonts.inter24BoldGray.copyWith(
                                fontSize: _rs(context, 14),
                              ),
                            ),
                          ),
                          SizedBox(height: _rs(context, 8)),
                          if (state.currentDose != null)
                            _CurrentMedicineCard(
                              currentDose: state.currentDose!,
                              rs: _rs,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const VerticalDivider(width: 1, color: Color(0xffE0E0E0)),

                  // العمود الأيمن: قائمة الأدوية القادمة
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(_rs(context, 12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "مواعيد اليوم",
                                style: AppFonts.inter30BoldDark.copyWith(
                                  fontSize: _rs(context, 16),
                                ),
                              ),
                              Text(
                                "${state.completedDoses}/${state.totalDoses} تم",
                                style: AppFonts.inter30BoldDark.copyWith(
                                  fontSize: _rs(context, 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: state.upcomingDoses.isEmpty
                              ? _EmptyStateView(
                                  hasCurrentDose: state.currentDose != null,
                                  rs: _rs,
                                )
                              : ListView.builder(
                                  itemCount: state.upcomingDoses.length,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _rs(context, 12),
                                  ),
                                  itemBuilder: (context, index) {
                                    return UpcomingMedicineTile(
                                      rs: _rs,
                                      upcomingDoise: state.upcomingDoses[index],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // --------------------------------------------------------
            // PORTRAIT LAYOUT (الترتيب الرأسي الطبيعي)
            // --------------------------------------------------------
            return Column(
              children: [
                _buildHeaderSection(context),
                SizedBox(height: _rs(context, 16)),

                Text(
                  dateFormatted,
                  style: AppFonts.inter24BoldGray.copyWith(
                    fontSize: _rs(context, 16),
                  ),
                ),
                SizedBox(height: _rs(context, 8)),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _rs(context, 16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "مواعيد اليوم",
                        style: AppFonts.inter30BoldDark.copyWith(
                          fontSize: _rs(context, 16),
                        ),
                      ),
                      Text(
                        "${state.completedDoses}/${state.totalDoses} تم",
                        style: AppFonts.inter30BoldDark.copyWith(
                          fontSize: _rs(context, 16),
                        ),
                      ),
                    ],
                  ),
                ),

                if (state.currentDose != null)
                  _CurrentMedicineCard(
                    currentDose: state.currentDose!,
                    rs: _rs,
                  ),

                Expanded(
                  child: state.upcomingDoses.isEmpty
                      ? _EmptyStateView(
                          hasCurrentDose: state.currentDose != null,
                          rs: _rs,
                        )
                      : ListView.builder(
                          itemCount: state.upcomingDoses.length,
                          padding: EdgeInsets.symmetric(
                            horizontal: _rs(context, 16),
                          ),
                          itemBuilder: (context, index) {
                            return UpcomingMedicineTile(
                              rs: _rs,
                              upcomingDoise: state.upcomingDoses[index],
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _rs(context, 16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: AppFonts.inter24BoldGray,
                ),
                Text(
                  _getUserName(),
                  style: AppFonts.inter30BoldDark.copyWith(
                    fontSize: _rs(context, 28),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "هنتابع معاك يومك... ودوائك بكل ثقة",
                  style: AppFonts.inter24BoldGray.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: _rs(context, 14),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none,
              size: _rs(context, 28),
            ),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// CURRENT MEDICINE CARD WIDGET
// ==================================================================

class _CurrentMedicineCard extends StatelessWidget {
  final HistoryDataModel currentDose;
  final double Function(BuildContext, double) rs;

  const _CurrentMedicineCard({
    required this.currentDose,
    required this.rs,
  });

  String _getDoseStatusText(DoseStatus status) {
    switch (status) {
      case DoseStatus.pending:
        return "الآن";
      case DoseStatus.taken:
        return "تم أخذه";
      case DoseStatus.missed:
        return "فات الموعد";
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PatientHomeCubit>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 16),
        vertical: rs(context, 8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(rs(context, 15)),
          color: const Color.fromARGB(255, 188, 252, 188),
          border: Border.all(
            color: const Color.fromARGB(255, 78, 202, 78),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(rs(context, 8)),
              child: Row(
                children: [
                  Container(
                    width: rs(context, 20),
                    height: rs(context, 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: const Color(0xffFFF6EB),
                    ),
                    child: Image.asset("assets/imgs/Pill_Icon.png"),
                  ),
                  SizedBox(width: rs(context, 8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentDose.medication.medicationName,
                          style: AppFonts.inter24BoldGray.copyWith(
                            fontSize: rs(context, 18),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: rs(context, 2)),
                        Text(
                          currentDose.medication.dosage,
                          style: AppFonts.inter24BoldGray.copyWith(
                            fontSize: rs(context, 13),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: rs(context, 8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rs(context, 10),
                      vertical: rs(context, 5),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _getDoseStatusText(currentDose.dose.status),
                      style: AppFonts.inter20Boldgreen.copyWith(
                        fontSize: rs(context, 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rs(context, 16),
                vertical: rs(context, 8),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => cubit.takeDose(currentDose.dose),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff0D8A45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    foregroundColor: Colors.white,
                    textStyle: AppFonts.inter30BoldDark.copyWith(
                      fontSize: rs(context, 18),
                      color: Colors.white,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.done, size: rs(context, 24)),
                      SizedBox(width: rs(context, 8)),
                      const Flexible(
                        child: Text(
                          "تم أخذ الدواء",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: rs(context, 16),
                right: rs(context, 16),
                bottom: rs(context, 8),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => cubit.remindMeAfterHour(currentDose.dose),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                      side: const BorderSide(
                        color: Color(0xffAFC5D5),
                        width: 1.0,
                      ),
                    ),
                    foregroundColor: AppColors.blackBlue,
                    textStyle: AppFonts.inter30BoldDark.copyWith(
                      fontSize: rs(context, 18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, size: rs(context, 24)),
                      SizedBox(width: rs(context, 8)),
                      const Flexible(
                        child: Text(
                          "ذكرني بعد ساعة",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================================
// HELPER VIEWS (LOADING / ERROR / EMPTY)
// ==================================================================

class _LoadingStateView extends StatelessWidget {
  const _LoadingStateView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xffF6FBFC),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xff0D8A45),
        ),
      ),
    );
  }
}

class _ErrorStateView extends StatelessWidget {
  final String message;

  const _ErrorStateView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6FBFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: AppFonts.inter24BoldGray,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<PatientHomeCubit>().loadTodayDoses(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  final bool hasCurrentDose;
  final double Function(BuildContext, double) rs;

  const _EmptyStateView({
    required this.hasCurrentDose,
    required this.rs,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rs(context, 30)),
        child: Text(
          !hasCurrentDose
              ? "مفيش أدوية متبقية لليوم"
              : "مفيش أدوية تانية جاية النهارده",
          textAlign: TextAlign.center,
          style: AppFonts.inter24BoldGray.copyWith(
            fontSize: rs(context, 16),
          ),
        ),
      ),
    );
  }
}

// ==================================================================
// UPCOMING MEDICINE TILE
// ==================================================================

class UpcomingMedicineTile extends StatelessWidget {
  final double Function(BuildContext, double) rs;
  final HistoryDataModel upcomingDoise;

  const UpcomingMedicineTile({
    super.key,
    required this.rs,
    required this.upcomingDoise,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs(context, 10)),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/add_med',
            arguments: upcomingDoise.medication,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: rs(context, 16),
            vertical: rs(context, 12),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(rs(context, 15)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upcomingDoise.medication.medicationName,
                      style: AppFonts.inter30BoldDark.copyWith(
                        fontSize: rs(context, 18),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: rs(context, 2)),
                    Text(
                      upcomingDoise.medication.dosage,
                      style: AppFonts.inter24BoldGray.copyWith(
                        fontSize: rs(context, 13),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: rs(context, 12)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rs(context, 8),
                  vertical: rs(context, 5),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffE3F4EC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "لاحقًا",
                  style: AppFonts.inter20Boldgreen.copyWith(
                    fontSize: rs(context, 12),
                  ),
                ),
              ),
              SizedBox(width: rs(context, 8)),
              Text(
                upcomingDoise.dose.time.format(context),
                style: AppFonts.inter30BoldDark.copyWith(
                  fontSize: rs(context, 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}