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
  const HistoryScreen({
    super.key,
    required this.currentUser,
  });

  final UserModel currentUser;

  double rs(BuildContext context, double value) {
    final mediaQuery = MediaQuery.of(context);
    final shortSide = mediaQuery.size.shortestSide;
    final scale = (shortSide / 380).clamp(0.85, 1.25);
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
     data: item,
      primeryContainerColor: getPrimaryColor(item.dose.status),
      secondryContainerColor: getSecondaryColor(item.dose.status),
    );
  }

  Widget buildMedicationList(List<HistoryDataModel> medicines) {
    if (medicines.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'لا توجد أدوية في هذا اليوم',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        return buildMedicationCard(medicines[index]);
      },
    );
  }

  Widget buildLegendItem(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          width: rs(context, 20),
          height: rs(context, 20),
          child: Center(
            child: Icon(
              icon,
              color: Colors.white,
              size: rs(context, 12),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppFonts.inter30BoldDark.copyWith(
            fontSize: rs(context, 13),
          ),
        ),
      ],
    );
  }

  Widget buildLegend(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: rs(context, 16),
        vertical: rs(context, 8),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(rs(context, 10)),
        decoration: BoxDecoration(
          color: const Color(0xffEAF1FC),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 12,
          runSpacing: 8,
          children: [
            buildLegendItem(
              context,
              color: Colors.green,
              icon: Icons.done,
              label: 'تم أخذه',
            ),
            buildLegendItem(
              context,
              color: Colors.red,
              icon: Icons.close,
              label: 'لم يتم أخذه',
            ),
            buildLegendItem(
              context,
              color: Colors.grey,
              icon: Icons.access_time,
              label: 'قيد الانتظار',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMonthSelector(BuildContext context) {
    final cubit = context.read<HistoryCubit>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => cubit.nextMonth(currentUser),
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            size: rs(context, 18),
          ),
        ),
        Flexible(
          child: TextButton(
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
                cubit.selectDate(firstDayOfMonth, currentUser);
              }
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                DateFormat('MMMM yyyy', 'ar').format(cubit.requiredMonth),
                style: AppFonts.inter30BoldDark.copyWith(
                  fontSize: rs(context, 16),
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () => cubit.previousMonth(currentUser),
          icon: Icon(
            Icons.arrow_forward_ios_outlined,
            size: rs(context, 18),
          ),
        ),
      ],
    );
  }

  Widget buildDatePicker(BuildContext context) {
    final cubit = context.read<HistoryCubit>();

    return SizedBox(
      height: rs(context, 80),
      child: DatePicker(
        cubit.requiredMonth,
        key: ValueKey(cubit.requiredMonth),
        daysCount: DateUtils.getDaysInMonth(
          cubit.requiredMonth.year,
          cubit.requiredMonth.month,
        ),
        dateTextStyle: TextStyle(
          fontSize: rs(context, 15),
          fontWeight: FontWeight.bold,
        ),
        dayTextStyle: TextStyle(
          fontSize: rs(context, 10),
          color: Colors.grey,
        ),
        monthTextStyle: TextStyle(
          fontSize: rs(context, 10),
          color: Colors.grey,
        ),
        width: rs(context, 50),
        height: rs(context, 70),
        locale: 'ar_EG',
        selectionColor: AppColors.blackBlue,
        initialSelectedDate: cubit.selected,
        onDateChange: (selectedDate) {
          cubit.selectDate(selectedDate, currentUser);
        },
      ),
    );
  }

  Widget buildHistoryContent(BuildContext context, HistoryState state) {
    if (state is HistoryLoadingState) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is HistoryFailState) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            state.msg,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state is HistorySuccessState) {
      return buildMedicationList(state.thisDateMediciens);
    }

    return const SizedBox.shrink();
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
                  fontSize: rs(context, 22),
                ),
              ),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: rs(context, 22),
                ),
                color: AppColors.textDark,
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          buildMonthSelector(context),
                          buildDatePicker(context),
                          buildLegend(context),
                          const Divider(height: 1),
                          buildHistoryContent(context, state),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      buildMonthSelector(context),
                      buildDatePicker(context),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: buildHistoryContent(context, state),
                        ),
                      ),
                      buildLegend(context),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}