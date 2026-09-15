import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_cubit.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_state.dart';
import 'package:dawaey/Fetures/medications/data/model/doise_model.dart';
import 'package:dawaey/Fetures/medications/presentation/cubit/medications_cubit.dart';
import 'package:dawaey/Fetures/medications/presentation/cubit/medications_state.dart';
import 'package:dawaey/Fetures/medications/presentation/view/add_medication_screen.dart';
import 'package:dawaey/Fetures/medications/presentation/view/medications_screen.dart';
import 'package:dawaey/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class home_caretaker_screen extends StatefulWidget {
  const home_caretaker_screen({super.key});

  @override
  State<home_caretaker_screen> createState() =>
      _home_caretaker_screenState();
}

class _home_caretaker_screenState
    extends State<home_caretaker_screen> {
  int _selectedIndex = 0;

  String? _linkedPatientName;
  String? _linkedPatientImage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeHome();
    });
  }

  Future<void> _initializeHome() async {
    final authCubit = context.read<AuthCubit>();

    if (authCubit.currentUser == null) {
      await authCubit.checkCurrentUser();
    }

    if (!mounted) return;

    final user = authCubit.currentUser;

    if (user == null) {
      return;
    }

    final patientId = _getTargetPatientId(user);

    if (patientId == null || patientId.isEmpty) {
      setState(() {
        _linkedPatientName = null;
        _linkedPatientImage = null;
      });

      return;
    }

    await _loadLinkedPatientInfo(patientId);

    if (!mounted) return;

    // loadMedications ترجع void
    // لذلك مفيش await هنا
    context.read<MedicationsCubit>().loadMedications(
          patientId: patientId,
          updateFilter: true,
        );
  }

  String? _getTargetPatientId(
    UserModel user,
  ) {
    if (user.role == UserRole.patient) {
      return user.uid;
    }

    return user.linkedUserId;
  }

  Future<void> _loadLinkedPatientInfo(
    String patientId,
  ) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(patientId)
          .get()
          .timeout(
            const Duration(
              seconds: 5,
            ),
          );

      if (!mounted) return;

      final data = doc.data();

      if (!doc.exists || data == null) {
        setState(() {
          _linkedPatientName =
              'المريض المرتبط';

          _linkedPatientImage = null;
        });

        return;
      }

      setState(() {
        final name =
            (data['name'] ?? '')
                .toString()
                .trim();

        _linkedPatientName =
            name.isEmpty
                ? 'المريض المرتبط'
                : name;

        _linkedPatientImage =
            (data['profileImage'] ?? '')
                .toString()
                .trim();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _linkedPatientName ??=
            'المريض المرتبط';

        _linkedPatientImage = null;
      });
    }
  }

  Future<void> _openAddMedication() async {
    final user =
        context.read<AuthCubit>().currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر تحديد المستخدم الحالي',
          ),
        ),
      );

      return;
    }

    final patientId =
        _getTargetPatientId(user);

    if (patientId == null ||
        patientId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'لا يوجد مريض مرتبط بهذا الحساب',
          ),
        ),
      );

      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AddMedicationScreen(
            targetPatientId: patientId,
          );
        },
      ),
    );

    if (!mounted) return;

    // بعد ما نرجع من شاشة إضافة الدواء
    // نعمل Refresh لنفس المريض

    context
        .read<MedicationsCubit>()
        .loadMedications(
          patientId: patientId,
          updateFilter: true,
        );
  }

  void _onItemTapped(
    int index,
  ) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
        AuthCubit,
        AuthState>(
      listener: (
        context,
        state,
      ) {
        if (state
            is AuthUnauthenticated) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false,
          );
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                state.message,
              ),
            ),
          );
        }
      },
      child: Directionality(
        textDirection:
            TextDirection.rtl,
        child: Scaffold(
          backgroundColor:
              Colors.white,

          appBar: AppBar(
            backgroundColor:
                Colors.white,
            elevation: 0,
            title: const Text(
              'متابعة العائلة',
              style: TextStyle(
                color: Color(
                  0xFF1B363F,
                ),
                fontWeight:
                    FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (
                      dialogContext,
                    ) {
                      return AlertDialog(
                        title:
                            const Text(
                          'الحساب',
                        ),
                        content:
                            const Text(
                          'ماذا تريد أن تفعل؟',
                        ),
                        actions: [
                          TextButton(
                            onPressed:
                                () {
                              Navigator.of(
                                dialogContext,
                              ).pop();
                            },
                            child:
                                const Text(
                              'إلغاء',
                            ),
                          ),
                          TextButton(
                            onPressed:
                                () {
                              Navigator.of(
                                dialogContext,
                              ).pop();

                              context
                                  .read<
                                      AuthCubit>()
                                  .logout();
                            },
                            child:
                                const Text(
                              'تسجيل الخروج',
                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .red,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child:
                    const Padding(
                  padding:
                      EdgeInsets.only(
                    left: 16,
                  ),
                  child:
                      CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Color(
                      0xFFE0F2F1,
                    ),
                    child: Icon(
                      Icons.person,
                      color:
                          Colors.teal,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),

          body:
              _selectedIndex == 0
                  ? _buildBody()
                  : _selectedIndex ==
                          1
                      ? const MedicationsScreen()
                      : const Center(
                          child:
                              Text(
                            'صفحة قيد الإنشاء',
                          ),
                        ),

          floatingActionButton:
              FloatingActionButton(
            onPressed:
                _openAddMedication,
            backgroundColor:
                Colors.teal,
            shape:
                const CircleBorder(),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),

          floatingActionButtonLocation:
              FloatingActionButtonLocation
                  .centerDocked,

          bottomNavigationBar:
              BottomAppBar(
            shape:
                const CircularNotchedRectangle(),
            notchMargin: 8,
            color: Colors.white,
            elevation: 10,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildNavBarItem(
                        Icons
                            .home_outlined,
                        'الرئيسية',
                        0,
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      _buildNavBarItem(
                        Icons
                            .medication_outlined,
                        'الأدوية',
                        1,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildNavBarItem(
                        Icons
                            .calendar_today_outlined,
                        'المواعيد',
                        2,
                      ),
                      const SizedBox(
                        width: 24,
                      ),
                      _buildNavBarItem(
                        Icons
                            .notifications_outlined,
                        'التنبيهات',
                        3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarItem(
    IconData icon,
    String label,
    int index,
  ) {
    final isSelected =
        _selectedIndex == index;

    return InkWell(
      onTap: () {
        _onItemTapped(index);
      },
      splashColor:
          Colors.transparent,
      highlightColor:
          Colors.transparent,
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        mainAxisAlignment:
            MainAxisAlignment
                .center,
        children: [
          Icon(
            icon,
            color:
                isSelected
                    ? Colors.blue
                    : Colors.grey,
            size: 28,
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  isSelected
                      ? FontWeight
                          .bold
                      : FontWeight
                          .normal,
              color:
                  isSelected
                      ? Colors.blue
                      : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<
        MedicationsCubit,
        MedicationsState>(
      builder: (
        context,
        state,
      ) {
        if (state
            is MedicationsLoading) {
          return const Center(
            child:
                CircularProgressIndicator(),
          );
        }

        if (state
            is MedicationsError) {
          return Center(
            child: Text(
              state.message,
            ),
          );
        }

        int totalDoses = 0;
        int takenDoses = 0;

        final medicationCards =
            <Widget>[];

        if (state
            is MedicationsLoaded) {
          totalDoses =
              state.totalDosesCount;

          takenDoses =
              state.takenDosesCount;

          for (final dose
              in state.todaysDoses) {
            final med =
                state
                    .getMedicationById(
              dose.medicationId,
            );

            final name =
                med?.medicationName ??
                    'غير معروف';

            final hour =
                dose.time.hour;

            final minute =
                dose.time.minute
                    .toString()
                    .padLeft(
                      2,
                      '0',
                    );

            final period =
                hour >= 12
                    ? 'م'
                    : 'ص';

            final hour12 =
                hour > 12
                    ? hour - 12
                    : hour == 0
                        ? 12
                        : hour;

            final timeStr =
                '$hour12:$minute $period';

            final taken =
                dose.status ==
                    DoseStatus.taken;

            final upcoming =
                dose.status ==
                    DoseStatus.pending;

            medicationCards.add(
              Column(
                children: [
                  _buildMedicationCard(
                    name,
                    timeStr,
                    taken,
                    upcoming,
                    () {
                      final newStatus =
                          taken
                              ? DoseStatus
                                  .pending
                              : DoseStatus
                                  .taken;

                      context
                          .read<
                              MedicationsCubit>()
                          .updateDoseStatus(
                            dose.id,
                            newStatus,
                          );
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            );
          }

          if (medicationCards
              .isEmpty) {
            medicationCards.add(
              const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(
                    20,
                  ),
                  child: Text(
                    'لا توجد أدوية اليوم',
                  ),
                ),
              ),
            );
          }
        }

        final adherenceRatio =
            totalDoses == 0
                ? 0.0
                : takenDoses /
                    totalDoses;

        final adherencePercentage =
            (adherenceRatio * 100)
                .toInt();

        return RefreshIndicator(
          onRefresh:
              _initializeHome,
          child:
              SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding:
                const EdgeInsets.all(
              20,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                _buildLinkedPatient(),

                const SizedBox(
                  height: 30,
                ),

                Container(
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.white,
                    borderRadius:
                        BorderRadius
                            .circular(
                      16,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                          0.05,
                        ),
                        blurRadius:
                            10,
                        offset:
                            const Offset(
                          0,
                          5,
                        ),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      const Text(
                        'نسبة الالتزام هذا الأسبوع',
                        style:
                            TextStyle(
                          fontSize:
                              16,
                          fontWeight:
                              FontWeight
                                  .bold,
                          color:
                              Color(
                            0xFF1B363F,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'ممتاز',
                                style:
                                    TextStyle(
                                  fontSize:
                                      24,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  color:
                                      Colors
                                          .teal,
                                ),
                              ),
                              SizedBox(
                                height:
                                    4,
                              ),
                              Text(
                                'استمروا على هذا المستوى المميز',
                                style:
                                    TextStyle(
                                  fontSize:
                                      12,
                                  color:
                                      Colors
                                          .grey,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 70,
                            width: 70,
                            child:
                                Stack(
                              fit:
                                  StackFit
                                      .expand,
                              children: [
                                CircularProgressIndicator(
                                  value:
                                      adherenceRatio,
                                  backgroundColor:
                                      Colors
                                          .grey
                                          .shade200,
                                  color:
                                      Colors
                                          .teal,
                                  strokeWidth:
                                      6,
                                ),
                                Center(
                                  child:
                                      Text(
                                    '$adherencePercentage%',
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color:
                                          Color(
                                        0xFF1B363F,
                                      ),
                                      fontSize:
                                          16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .end,
                        children: [
                          _buildBar(
                            'أحد',
                            0.5,
                            Colors.red,
                            false,
                          ),
                          _buildBar(
                            'إثنين',
                            0.7,
                            Colors.teal,
                            true,
                          ),
                          _buildBar(
                            'ثلاثاء',
                            0.6,
                            Colors.teal,
                            true,
                          ),
                          _buildBar(
                            'أربعاء',
                            0.8,
                            Colors.teal,
                            true,
                          ),
                          _buildBar(
                            'خميس',
                            0.4,
                            Colors.red,
                            false,
                          ),
                          _buildBar(
                            'جمعة',
                            0.75,
                            Colors.teal,
                            true,
                          ),
                          _buildBar(
                            'سبت',
                            0.5,
                            Colors.red,
                            false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                  children: [
                    const Text(
                      'أدوية اليوم',
                      style:
                          TextStyle(
                        fontSize:
                            18,
                        fontWeight:
                            FontWeight
                                .bold,
                        color:
                            Color(
                          0xFF1B363F,
                        ),
                      ),
                    ),
                    Text(
                      'تم $takenDoses/$totalDoses',
                      style:
                          const TextStyle(
                        fontSize:
                            14,
                        color:
                            Colors.teal,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                ...medicationCards,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLinkedPatient() {
    final displayName =
        (_linkedPatientName ==
                    null ||
                _linkedPatientName!
                    .isEmpty)
            ? 'المريض المرتبط'
            : _linkedPatientName!;

    ImageProvider?
        imageProvider;

    if (_linkedPatientImage !=
            null &&
        _linkedPatientImage!
            .isNotEmpty) {
      try {
        imageProvider =
            MemoryImage(
          base64Decode(
            _linkedPatientImage!,
          ),
        );
      } catch (_) {
        imageProvider = null;
      }
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor:
              const Color(
            0xFFE0F2F1,
          ),
          backgroundImage:
              imageProvider,
          child:
              imageProvider == null
                  ? const Icon(
                      Icons.person,
                      color:
                          Colors.teal,
                      size: 32,
                    )
                  : null,
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                displayName,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight
                          .bold,
                  color:
                      Color(
                    0xFF1B363F,
                  ),
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              const Text(
                'المريض الذي تتابعه',
                style:
                    TextStyle(
                  fontSize: 14,
                  color:
                      Colors.teal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(
    String day,
    double heightRatio,
    Color color,
    bool taken,
  ) {
    return Column(
      children: [
        Container(
          width: 14,
          height:
              80 * heightRatio,
          decoration:
              BoxDecoration(
            color: color,
            borderRadius:
                const BorderRadius
                    .only(
              topLeft:
                  Radius.circular(
                4,
              ),
              topRight:
                  Radius.circular(
                4,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        Text(
          day,
          style:
              const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),

        const SizedBox(
          height: 6,
        ),

        CircleAvatar(
          radius: 3,
          backgroundColor:
              taken
                  ? Colors
                      .transparent
                  : Colors.red,
        ),
      ],
    );
  }

  Widget _buildMedicationCard(
    String name,
    String time,
    bool taken,
    bool upcoming,
    VoidCallback onTap,
  ) {
    Color bgColor;
    Color iconColor;
    IconData icon;

    if (upcoming) {
      bgColor =
          Colors.white;
      iconColor =
          Colors.teal;
      icon =
          Icons.access_time;
    } else if (taken) {
      bgColor =
          Colors.white;
      iconColor =
          Colors.teal;
      icon =
          Icons.check_circle;
    } else {
      bgColor =
          Colors.red.shade50;
      iconColor =
          Colors.red;
      icon =
          Icons.cancel;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration:
            BoxDecoration(
          color: bgColor,
          borderRadius:
              BorderRadius.circular(
            12,
          ),
          border:
              upcoming || taken
                  ? Border.all(
                      color: Colors
                          .grey
                          .shade200,
                    )
                  : Border.all(
                      color: Colors
                          .red
                          .shade100,
                    ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color:
                      iconColor,
                  size: 28,
                ),

                const SizedBox(
                  width: 12,
                ),

                Text(
                  time,
                  style:
                      TextStyle(
                    color:
                        upcoming
                            ? Colors
                                .teal
                            : taken
                                ? Colors
                                    .teal
                                : Colors
                                    .red,
                    fontWeight:
                        FontWeight
                            .bold,
                    fontSize:
                        16,
                  ),
                ),
              ],
            ),

            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight
                          .bold,
                  color:
                      Color(
                    0xFF1B363F,
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