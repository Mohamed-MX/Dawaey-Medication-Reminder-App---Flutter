import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/history/data/model/history_data_model.dart';
import 'package:dawaey/Fetures/history/presentation/view_model/history_cubit.dart';
import 'package:dawaey/Fetures/history/presentation/view_model/history_state.dart';
import 'package:dawaey/Fetures/history/presentation/widgets/medician_card.dart';
import 'package:dawaey/Fetures/medications/data/model/doise_model.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:dawaey/core/theme/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({
    super.key,
    required this.currentUser,
  });

  final UserModel currentUser;

  double rs(BuildContext context, double value) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final scale = (screenWidth / 382).clamp(0.9, 1.2);

    return value * scale;
  }

  Color getPrimaryColor(DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return const Color(0xFFF3FAF6);
      case DoseStatus.missed:
        return const Color(0xFFFFF5F6);
      case DoseStatus.pending:
        return const Color(0xFFF5F8FD);
    }
  }

  Color getSecondaryColor(DoseStatus status) {
    switch (status) {
      case DoseStatus.taken:
        return const Color(0xFFE8F6EF);
      case DoseStatus.missed:
        return const Color(0xFFFDECEF);
      case DoseStatus.pending:
        return const Color(0xFFF0F4FA);
    }
  }

  Widget buildMedicationCard(HistoryDataModel item) {
    return MedicianCard(
      name: item.medication.medicationName,
      dose: item.medication.dosage,
      status: item.dose.status,
      time: item.dose.time,
      primeryContainerColor: getPrimaryColor(item.dose.status),
      secondryContainerColor: getSecondaryColor(item.dose.status),
    );
  }

  void showMedicinesDialog(
    BuildContext context,
    List<HistoryDataModel> medicines,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'سجل الأدوية',
            textAlign: TextAlign.center,
            style: AppFonts.inter30BoldDark.copyWith(
              fontSize: rs(context, 22),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                return buildMedicationCard(medicines[index]);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'إغلاق',
                style: AppFonts.inter30BoldDark.copyWith(
                  fontSize: rs(context, 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildMedicationList(
    List<HistoryDataModel> medicines,
  ) {
    if (medicines.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أدوية في هذا اليوم',
        ),
      );
    }

    return ListView.builder(
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        return buildMedicationCard(medicines[index]);
      },
    );
  }

  Widget buildLandscapeButton(
    BuildContext context,
    List<HistoryDataModel> medicines,
  ) {
    return Center(
      child: ElevatedButton(
        onPressed: medicines.isEmpty
            ? null
            : () {
                showMedicinesDialog(
                  context,
                  medicines,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blackBlue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: rs(context, 10),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'عرض الأدوية',
          style: AppFonts.inter30BoldDark.copyWith(
            color: Colors.white,
            fontSize: rs(context, 16),
          ),
        ),
      ),
    );
  }

  Widget buildLegend(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 16),
        vertical: rs(context, 16),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xffEAF1FC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: rs(context, 16),
              vertical: rs(context, 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  width: rs(context, 25),
                  height: rs(context, 25),
                  child: Center(
                    child: Icon(
                      Icons.done,
                      color: Colors.white,
                      size: rs(context, 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: rs(context, 16),
                  ),
                  child: Text(
                    'تم أخذه',
                    style: AppFonts.inter30BoldDark.copyWith(
                      fontSize: rs(context, 18),
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: VerticalDivider(
                    thickness: rs(context, 1),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  width: rs(context, 25),
                  height: rs(context, 25),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: rs(context, 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: rs(context, 16),
                  ),
                  child: Text(
                    'لم يتم أخذه',
                    style: AppFonts.inter30BoldDark.copyWith(
                      fontSize: rs(context, 18),
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: VerticalDivider(
                    thickness: rs(context, 1),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  width: rs(context, 25),
                  height: rs(context, 25),
                  child: Center(
                    child: Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: rs(context, 16),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    right: rs(context, 16),
                  ),
                  child: Text(
                    'قيد الانتظار',
                    style: AppFonts.inter30BoldDark.copyWith(
                      fontSize: rs(context, 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMonthSelector(BuildContext context) {
    final cubit = context.read<HistoryCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {
            cubit.nextMonth(currentUser);
          },
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
          ),
        ),

        TextButton(
          onPressed: () async {
            final selectedDate = await showMonthYearPicker(
              context: context,
              initialDate: cubit.requiredMonth,
              firstDate: DateTime(2010),
              lastDate: DateTime(2030),
            );

            if (selectedDate != null && context.mounted) {
              final firstDayOfMonth = DateTime(
                selectedDate.year,
                selectedDate.month,
                1,
              );

              cubit.selectDate(
                firstDayOfMonth,
                currentUser,
              );
            }
          },
          child: Text(
            DateFormat(
              'MMMM yyyy',
              'ar',
            ).format(cubit.requiredMonth),
            style: AppFonts.inter30BoldDark.copyWith(
              fontSize: rs(context, 18),
            ),
          ),
        ),

        IconButton(
          onPressed: () {
            cubit.previousMonth(currentUser);
          },
          icon: const Icon(
            Icons.arrow_forward_ios_outlined,
          ),
        ),
      ],
    );
  }

  Widget buildDatePicker(BuildContext context) {
    final cubit = context.read<HistoryCubit>();

    return DatePicker(
      daysCount: DateUtils.getDaysInMonth(
        cubit.requiredMonth.year,
        cubit.requiredMonth.month,
      ),
      dateTextStyle: TextStyle(
        fontSize: rs(context, 18),
        fontWeight: FontWeight.bold,
      ),
      dayTextStyle: TextStyle(
        fontSize: rs(context, 11),
        color: Colors.grey,
      ),
      monthTextStyle: TextStyle(
        fontSize: rs(context, 11),
        color: Colors.grey,
      ),
      width: rs(context, 50),
      height: rs(context, 70),
      key: ValueKey(cubit.requiredMonth),
      cubit.requiredMonth,
      locale: 'ar_EG',
      selectionColor: AppColors.blackBlue,
      initialSelectedDate: cubit.selected,
      onDateChange: (selectedDate) {
        cubit.selectDate(
          selectedDate,
          currentUser,
        );
      },
    );
  }

  Widget buildHistoryContent(
    BuildContext context,
    HistoryState state,
  ) {
    if (state is HistoryLoadingState) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is HistoryFailState) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              state.msg,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (state is HistorySuccessState) {
      final medicines = state.thisDateMediciens;

      return Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isShortScreen = constraints.maxHeight < 200;

            if (isShortScreen) {
              return buildLandscapeButton(
                context,
                medicines,
              );
            }

            return buildMedicationList(
              medicines,
            );
          },
        ),
      );
    }

    return const Expanded(
      child: SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
    create: (_) => HistoryCubit()
      ..getRelativeMediciensWithDate(
        DateTime.now(),
        currentUser,
      ),
    
    child: BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'سجل الأدوية',
              style: AppFonts.inter30BoldDark.copyWith(
                fontSize: rs(context, 30),
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: rs(context, 30),
              ),
              color: AppColors.textDark,
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              buildMonthSelector(context),
              buildDatePicker(context),

              buildHistoryContent(
                context,
                state,
              ),

              buildLegend(context),
            ],
          ),
        );
      },
    )
    );
  }
}