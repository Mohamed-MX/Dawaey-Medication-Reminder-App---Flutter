import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view/login_screen.dart';
import 'package:dawaey/Fetures/Auth/view_model/auth_cubit.dart';
import 'package:dawaey/Fetures/history/presentation/view/history_screen.dart';
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
        if (state is PatientHomeLoading || state is PatientHomeInitial) {
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
                HistoryScreen(
                  currentUser: currentUser,
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: state.selectedIndex,
              onTap: (index) {
                if (index == 2) {
                  _showMoreMenu(context);
                  return;
                }

                context
                    .read<PatientHomeCubit>()
                    .changeBottomNavIndex(index);
              },
              selectedItemColor: AppColors.tealGreen,
              unselectedItemColor: AppColors.blackBlue,
              type: BottomNavigationBarType.fixed,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  activeIcon: Icon(Icons.history),
                  label: 'سجل الأدوية',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    key: moreButtonKey,
                    child: const Icon(Icons.more_horiz),
                  ),
                  activeIcon: Container(
                    key: moreButtonKey,
                    child: const Icon(Icons.more_horiz),
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
        moreButtonKey.currentContext?.findRenderObject() as RenderBox?;

    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;

    if (button == null || overlay == null) {
      return;
    }

    final buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    final buttonSize = button.size;

    final position = RelativeRect.fromLTRB(
      buttonPosition.dx - 120,
      buttonPosition.dy - 170,
      overlay.size.width - buttonPosition.dx - buttonSize.width,
      overlay.size.height - buttonPosition.dy,
    );

    showMenu<dynamic>(
      context: context,
      position: position,
      elevation: 10,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.tealGreen.withOpacity(0.12),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.tealGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentUser.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blackBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentUser.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          onTap: () {
            // 1. استدعاء الخروج إذا كان الـ AuthViewModel متوفر في الـ Context
            try {
              context.read<AuthViewModel>().logout();
            } catch (_) {}

            // 2. الانتقال المباشر لشاشة تسجيل الدخول وتفريغ الـ Stack بالكامل
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}