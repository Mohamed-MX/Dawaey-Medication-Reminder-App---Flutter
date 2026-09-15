import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/history/data/model/history_data_model.dart';
import 'package:dawaey/Fetures/medications/data/model/doise_model.dart';
import 'package:dawaey/Fetures/patient/home/presentation/view_model/patient_home_cubit.dart';
import 'package:dawaey/Fetures/patient/home/presentation/view_model/patient_home_state.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:dawaey/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PatientHomeScreen extends StatelessWidget {
  final UserModel currentUser;

  const PatientHomeScreen({
    super.key,
    required this.currentUser,
  });

  double rs(BuildContext context, double value) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 382).clamp(0.9, 1.5);

    return value * scale;
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "صباح الخير";
    }

    if (hour >= 12 && hour < 17) {
      return "مساء الخير";
    }

    if (hour >= 17 && hour < 22) {
      return "مساء الخير";
    }

    return "مساء الخير";
  }

  String _getUserName() {
    final name = currentUser.name.trim();

    if (name.isEmpty) {
      return "يا صديقي";
    }

    return "يا $name";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientHomeCubit, PatientHomeState>(
      builder: (context, state) {
        if (state is PatientHomeLoading ||
            state is PatientHomeInitial) {
          return const Scaffold(
            backgroundColor: Color(0xffF6FBFC),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xff0D8A45),
              ),
            ),
          );
        }

        if (state is PatientHomeError) {
          return Scaffold(
            backgroundColor: const Color(0xffF6FBFC),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      style: AppFonts.inter24BoldGray,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<PatientHomeCubit>()
                            .loadTodayDoses();
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is PatientHomeLoaded) {
          return _buildHome(
            context,
            state,
          );
        }

        return const Scaffold(
          backgroundColor: Color(0xffF6FBFC),
        );
      },
    );
  }

  // ==============================================================
  // HOME
  // ==============================================================

  Widget _buildHome(
    BuildContext context,
    PatientHomeLoaded state,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xffF6FBFC),
      body: SafeArea(
        child: Column(
          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rs(context, 16),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: AppFonts.inter24BoldGray,
                        ),

                        Text(
                          _getUserName(),
                          style:
                              AppFonts.inter30BoldDark.copyWith(
                            fontSize: rs(context, 32),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        Text(
                          "هنتابع معاك يومك... ودوائك بكل ثقة",
                          style:
                              AppFonts.inter24BoldGray.copyWith(
                            fontWeight: FontWeight.w400,
                            fontSize: rs(context, 14),
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
                      size: rs(context, 28),
                    ),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),

            SizedBox(
              height: rs(context, 16),
            ),

            // ====================================================
            // DATE
            // ====================================================

            Text(
              DateFormat(
                'EEEE , d MMMM yyyy',
                'ar',
              ).format(DateTime.now()),
              style: AppFonts.inter24BoldGray.copyWith(
                fontSize: rs(context, 16),
              ),
            ),

            SizedBox(
              height: rs(context, 8),
            ),

            // ====================================================
            // TODAY HEADER
            // ====================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rs(context, 16),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "مواعيد اليوم",
                    style:
                        AppFonts.inter30BoldDark.copyWith(
                      fontSize: rs(context, 16),
                    ),
                  ),

                  Text(
                    "${state.completedDoses}/${state.totalDoses} تم",
                    style:
                        AppFonts.inter30BoldDark.copyWith(
                      fontSize: rs(context, 16),
                    ),
                  ),
                ],
              ),
            ),

            // ====================================================
            // CURRENT MEDICINE
            // ====================================================

            if (state.currentDose != null)
              _buildCurrentMedicineCard(
                context,
                state.currentDose!,
              ),

            // ====================================================
            // UPCOMING MEDICINES
            // ====================================================

            Expanded(
              child: state.upcomingDoses.isEmpty
                  ? _buildEmptyState(
                      context,
                      state,
                    )
                  : ListView.builder(
                      itemCount:
                          state.upcomingDoses.length,
                      padding: EdgeInsets.symmetric(
                        horizontal: rs(context, 16),
                      ),
                      itemBuilder: (context, index) {
                        final dose =
                            state.upcomingDoses[index];

                        return UpcomingMedicineTile(
                          rs: rs,
                          upcomingDoise: dose,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // EMPTY STATE
  // ==============================================================

  Widget _buildEmptyState(
    BuildContext context,
    PatientHomeLoaded state,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: rs(context, 30),
        ),
        child: Text(
          state.currentDose == null
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

  // ==============================================================
  // CURRENT MEDICINE CARD
  // ==============================================================

  Widget _buildCurrentMedicineCard(
    BuildContext context,
    HistoryDataModel currentDose,
  ) {
    final cubit =
        context.read<PatientHomeCubit>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 16),
        vertical: rs(context, 8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            rs(context, 15),
          ),
          color: const Color.fromARGB(
            255,
            188,
            252,
            188,
          ),
          border: Border.all(
            color: const Color.fromARGB(
              255,
              78,
              202,
              78,
            ),
          ),
        ),
        child: Column(
          children: [
            // ==================================================
            // MEDICINE INFO + STATUS
            // ==================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rs(context, 8),
                vertical: rs(context, 8),
              ),
              child: Row(
                children: [
                  Container(
                    width: rs(context, 20),
                    height: rs(context, 20),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(999),
                      color: const Color(0xffFFF6EB),
                    ),
                    child: Image.asset(
                      "assets/imgs/Pill_Icon.png",
                    ),
                  ),

                  SizedBox(
                    width: rs(context, 8),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentDose.medication
                              .medicationName,
                          style:
                              AppFonts.inter24BoldGray
                                  .copyWith(
                            fontSize: rs(context, 18),
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),

                        SizedBox(
                          height: rs(context, 2),
                        ),

                        Text(
                          currentDose.medication.dosage,
                          style:
                              AppFonts.inter24BoldGray
                                  .copyWith(
                            fontSize: rs(context, 13),
                            fontWeight:
                                FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: rs(context, 8),
                  ),

                  // STATUS
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: rs(context, 10),
                      vertical: rs(context, 5),
                    ),
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.7),
                      borderRadius:
                          BorderRadius.circular(999),
                    ),
                    child: Text(
                      _getDoseStatusText(
                        currentDose,
                      ),
                      style:
                          AppFonts.inter20Boldgreen
                              .copyWith(
                        fontSize: rs(context, 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // TAKE BUTTON
            // ==================================================

            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: rs(context, 16),
                vertical: rs(context, 12),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cubit.takeDose(
                      currentDose.dose,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xff0D8A45),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(100),
                    ),
                    foregroundColor: Colors.white,
                    textStyle:
                        AppFonts.inter30BoldDark
                            .copyWith(
                      fontSize: rs(context, 20),
                      color: Colors.white,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.done,
                        size: rs(context, 32),
                      ),
                      SizedBox(
                        width: rs(context, 8),
                      ),
                      Flexible(
                        child: Text(
                          "تم أخذ الدواء",
                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // REMIND BUTTON
            // ==================================================

            Padding(
              padding: EdgeInsets.only(
                left: rs(context, 16),
                right: rs(context, 16),
                bottom: rs(context, 12),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    cubit.remindMeAfterHour(
                      currentDose.dose,
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(100),
                      side: const BorderSide(
                        color: Color(0xffAFC5D5),
                        width: 1.0,
                      ),
                    ),
                    foregroundColor:
                        AppColors.blackBlue,
                    textStyle:
                        AppFonts.inter30BoldDark
                            .copyWith(
                      fontSize: rs(context, 20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: rs(context, 32),
                      ),
                      SizedBox(
                        width: rs(context, 8),
                      ),
                      Flexible(
                        child: Text(
                          "ذكرني بعد ساعة",
                          overflow:
                              TextOverflow.ellipsis,
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

  // ==============================================================
  // STATUS TEXT
  // ==============================================================

  String _getDoseStatusText(
    HistoryDataModel dose,
  ) {
    switch (dose.dose.status) {
      case DoseStatus.pending:
        return "الآن";

      case DoseStatus.taken:
        return "تم أخذه";

      case DoseStatus.missed:
        return "فات الموعد";
    }
  }
}

// ==================================================================
// UPCOMING MEDICINE TILE
// ==================================================================

class UpcomingMedicineTile extends StatelessWidget {
  final double Function(
    BuildContext,
    double,
  ) rs;

  final HistoryDataModel upcomingDoise;

  const UpcomingMedicineTile({
    super.key,
    required this.rs,
    required this.upcomingDoise,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: rs(context, 10),
      ),
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
            borderRadius:
                BorderRadius.circular(
              rs(context, 15),
            ),
          ),
          child: Row(
            children: [
              // ==================================================
              // MEDICINE NAME
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      upcomingDoise.medication
                          .medicationName,
                      style:
                          AppFonts.inter30BoldDark
                              .copyWith(
                        fontSize: rs(context, 18),
                      ),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                    ),

                    SizedBox(
                      height: rs(context, 2),
                    ),

                    Text(
                      upcomingDoise.medication.dosage,
                      style:
                          AppFonts.inter24BoldGray
                              .copyWith(
                        fontSize: rs(context, 13),
                        fontWeight:
                            FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: rs(context, 12),
              ),

              // ==================================================
              // STATUS
              // ==================================================

              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: rs(context, 8),
                  vertical: rs(context, 5),
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xffE3F4EC),
                  borderRadius:
                      BorderRadius.circular(999),
                ),
                child: Text(
                  "لاحقًا",
                  style:
                      AppFonts.inter20Boldgreen
                          .copyWith(
                    fontSize: rs(context, 12),
                  ),
                ),
              ),

              SizedBox(
                width: rs(context, 8),
              ),

              // ==================================================
              // TIME
              // ==================================================

              Text(
                upcomingDoise.dose.time.format(
                  context,
                ),
                style:
                    AppFonts.inter30BoldDark
                        .copyWith(
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