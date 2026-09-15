import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_cubit.dart';
import 'package:dawaey/Fetures/history/presentation/view/history_screen.dart';
import 'package:dawaey/Fetures/medications/presentation/view/medications_screen.dart';
import 'package:dawaey/Fetures/patient/home/presentation/view/patient_home_screen.dart';
import 'package:dawaey/Fetures/patient/home/presentation/view_model/patient_home_cubit.dart';
import 'package:dawaey/Fetures/patient/home/presentation/view_model/patient_home_state.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientMainScreen extends StatelessWidget {
  final UserModel currentUser;

  PatientMainScreen({
    super.key,
    required this.currentUser,
  });

  final GlobalKey _moreButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientHomeCubit(
        uid: currentUser.uid,
      )..initialize(),
      child: PatientMainView(
        currentUser: currentUser,
        moreButtonKey: _moreButtonKey,
      ),
    );
  }
}

class PatientMainView extends StatelessWidget {
  final UserModel currentUser;
  final GlobalKey moreButtonKey;

  const PatientMainView({
    super.key,
    required this.currentUser,
    required this.moreButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientHomeCubit, PatientHomeState>(
      builder: (context, state) {
        if (state is PatientHomeLoading ||
            state is PatientHomeInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.tealGreen,
              ),
            ),
          );
        }

        if (state is PatientHomeError) {
          return Scaffold(
            body: Center(
              child: Text(state.message),
            ),
          );
        }

        if (state is PatientHomeLoaded) {
          return Scaffold(
            body: IndexedStack(
              index: state.selectedIndex,
              children: [
                PatientHomeScreen(
                  currentUser: currentUser,
                ),

                MedicationsScreen(),
                
                HistoryScreen(
                  currentUser: currentUser,
                ),

                const SizedBox.shrink(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state.selectedIndex,
              onTap: (index) {
                if (index == 3) {
                  _showMoreMenu(context);
                  return;
                }

                context
                    .read<PatientHomeCubit>()
                    .changeBottomNavIndex(index);
              },

              // اللون الأساسي للأيقونة والعنصر المحدد
              selectedItemColor: AppColors.tealGreen,

              // لون العناصر غير المحددة
              unselectedItemColor: AppColors.blackBlue,

              type: BottomNavigationBarType.fixed,

              items: [
                const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_outlined,
                  ),
                  activeIcon: Icon(
                    Icons.home,
                  ),
                  label: 'الرئيسية',
                ),

                const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.medication_outlined,
                  ),
                  activeIcon: Icon(
                    Icons.medication,
                  ),
                  label: 'أدويتي',
                ),

                const BottomNavigationBarItem(
                  icon: Icon(
                    Icons.history_outlined,
                  ),
                  activeIcon: Icon(
                    Icons.history,
                  ),
                  label: 'سجل الأدوية',
                ),

                BottomNavigationBarItem(
                  icon: Container(
                    key: moreButtonKey,
                    child: const Icon(
                      Icons.more_horiz,
                    ),
                  ),
                  activeIcon: Container(
                    key: moreButtonKey,
                    child: const Icon(
                      Icons.more_horiz,
                    ),
                  ),
                  label: 'المزيد',
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showMoreMenu(BuildContext context) {
    final RenderBox? button =
        moreButtonKey.currentContext?.findRenderObject()
            as RenderBox?;

    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject()
            as RenderBox?;

    if (button == null || overlay == null) {
      return;
    }

    final buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    final buttonSize = button.size;

    final position = RelativeRect.fromLTRB(
      buttonPosition.dx,
      buttonPosition.dy - 10,
      overlay.size.width -
          buttonPosition.dx -
          buttonSize.width,
      overlay.size.height -
          buttonPosition.dy -
          buttonSize.height,
    );

    showMenu(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      items: [
        PopupMenuItem(
          onTap: () {
            context.read<AuthCubit>().logout();
          },
          child: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}