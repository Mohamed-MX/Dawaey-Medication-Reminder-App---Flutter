import 'package:flutter_svg/flutter_svg.dart';
import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_cubit.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_state.dart';
import 'package:dawaey/Fetures/Auth/presentation/widgets/auth_button.dart';
import 'package:dawaey/Fetures/Auth/presentation/widgets/auth_text_field.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  final UserRole role;

  const SignupScreen({
    super.key,
    required this.role,
  });

  @override
  State<SignupScreen> createState() {
    return _SignupScreenState();
  }
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final patientPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    patientPhoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isTablet = screenWidth >= 600;

    final bool isCaregiver =
        widget.role == UserRole.caregiver;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          if (state.message.contains('google_new_user')) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }

        if (state is AuthSuccess) {
          // Pop back to LoginScreen which will auto-route via BlocBuilder in main.dart
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
              backgroundColor:
                  AppColors.authBackground,

              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          isTablet ? 60 : 24,
                      vertical: 20,
                    ),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 460,
                      ),
                      child: Form(
                        key: formKey,
                        child: Column(
                          children: [
                            // Back Button
                            Align(
                              alignment:
                                  Alignment.centerRight,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color:
                                      AppColors.primaryBlue,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            // Logo
                            SizedBox(
                              width: isTablet ? 180 : 145,
                              height: isTablet ? 120 : 100,
                              child: Image.asset(
                                'assets/app icon.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(
                              height: isTablet ? 35 : 25,
                            ),

                            // Title
                            Text(
                              'إنشاء حساب',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color:
                                    AppColors.primaryBlue,
                                fontSize:
                                    isTablet ? 32 : 29,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            // Subtitle
                            Text(
                              isCaregiver
                                  ? 'أنشئ حسابك لمتابعة أحد أفراد عائلتك'
                                  : 'أنشئ حسابك لإدارة أدويتك بسهولة',
                              textAlign:
                                  TextAlign.center,
                              style: TextStyle(
                                color:
                                    AppColors.greyText,
                                fontSize:
                                    isTablet ? 18 : 16,
                              ),
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // Profile Image
                            GestureDetector(
                              onTap: () {
                                cubit
                                    .pickProfileImage();
                              },
                              child: Stack(
                                alignment:
                                    Alignment.bottomLeft,
                                children: [
                                  Container(
                                    width: isTablet
                                        ? 125
                                        : 110,
                                    height: isTablet
                                        ? 125
                                        : 110,
                                    decoration:
                                        BoxDecoration(
                                      shape:
                                          BoxShape.circle,
                                      color:
                                          Colors.white,
                                      border:
                                          Border.all(
                                        color: AppColors
                                            .authBorder,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: ClipOval(
                                      child: cubit
                                                  .profileImageBytes !=
                                              null
                                          ? Image.memory(
                                              cubit
                                                  .profileImageBytes!,
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit
                                                  .cover,
                                            )
                                          : const Icon(
                                              Icons
                                                  .person_outline,
                                              size: 55,
                                              color: AppColors
                                                  .primaryBlue,
                                            ),
                                    ),
                                  ),

                                  // Plus Button
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration:
                                        BoxDecoration(
                                      color: AppColors
                                          .primaryBlue,
                                      shape:
                                          BoxShape.circle,
                                      border:
                                          Border.all(
                                        color:
                                            Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child:
                                        const Icon(
                                      Icons.add,
                                      color:
                                          Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            // Add Image Text
                            TextButton(
                              onPressed: () {
                                cubit
                                    .pickProfileImage();
                              },
                              child: const Text(
                                'إضافة صورة',
                                style: TextStyle(
                                  color: AppColors
                                      .primaryBlue,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // Full Name
                            AuthTextField(
                              controller:
                                  nameController,
                              hintText:
                                  'الاسم بالكامل',
                              icon:
                                  Icons.person_outline,
                              textInputAction:
                                  TextInputAction.next,
                              validator: (value) {
                                if (value == null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'اكتب الاسم بالكامل';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // Email
                            AuthTextField(
                              controller:
                                  emailController,
                              hintText:
                                  'البريد الإلكتروني',
                              icon:
                                  Icons.email_outlined,
                              keyboardType:
                                  TextInputType
                                      .emailAddress,
                              textInputAction:
                                  TextInputAction.next,
                              validator: (value) {
                                if (value == null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'اكتب البريد الإلكتروني';
                                }

                                if (!value
                                    .contains('@')) {
                                  return 'اكتب بريد إلكتروني صحيح';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // Phone
                            AuthTextField(
                              controller:
                                  phoneController,
                              hintText:
                                  'رقم الهاتف',
                              icon:
                                  Icons.phone_outlined,
                              keyboardType:
                                  TextInputType.phone,
                              textInputAction:
                                  TextInputAction.next,
                              validator: (value) {
                                if (value == null ||
                                    value
                                        .trim()
                                        .isEmpty) {
                                  return 'اكتب رقم الهاتف';
                                }

                                return null;
                              },
                            ),

                            // Patient Phone
                            // بيظهر للـ Caregiver بس
                            if (isCaregiver) ...[
                              const SizedBox(
                                height: 16,
                              ),

                              AuthTextField(
                                controller:
                                    patientPhoneController,
                                hintText:
                                    'رقم هاتف المريض',
                                icon: Icons
                                    .phone_in_talk_outlined,
                                keyboardType:
                                    TextInputType.phone,
                                textInputAction:
                                    TextInputAction.next,
                                validator: (value) {
                                  if (value ==
                                          null ||
                                      value
                                          .trim()
                                          .isEmpty) {
                                    return 'اكتب رقم هاتف المريض';
                                  }

                                  return null;
                                },
                              ),
                            ],

                            const SizedBox(
                              height: 16,
                            ),

                            // Password
                            AuthTextField(
                              controller:
                                  passwordController,
                              hintText:
                                  'كلمة المرور',
                              icon:
                                  Icons.lock_outline,
                              obscureText:
                                  cubit.hidePassword,
                              textInputAction:
                                  TextInputAction.next,
                              suffixIcon:
                                  IconButton(
                                onPressed: () {
                                  cubit
                                      .changePasswordVisibility();
                                },
                                icon: Icon(
                                  cubit.hidePassword
                                      ? Icons
                                          .visibility_off_outlined
                                      : Icons
                                          .visibility_outlined,
                                  color: AppColors
                                      .primaryBlue,
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'اكتب كلمة المرور';
                                }

                                if (value.length < 6) {
                                  return 'كلمة المرور لازم تكون 6 أحرف على الأقل';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // Confirm Password
                            AuthTextField(
                              controller:
                                  confirmPasswordController,
                              hintText:
                                  'تأكيد كلمة المرور',
                              icon:
                                  Icons.lock_outline,
                              obscureText:
                                  cubit.hidePassword,
                              textInputAction:
                                  TextInputAction.done,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'أكد كلمة المرور';
                                }

                                if (value !=
                                    passwordController
                                        .text) {
                                  return 'كلمتا المرور غير متطابقتين';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // Create Account Button
                            AuthButton(
                              text:
                                  'إنشاء الحساب',
                              isLoading:
                                  state is AuthLoading,
                              onPressed:
                                  state is AuthLoading
                                      ? null
                                      : () {
                                          if (formKey
                                              .currentState!
                                              .validate()) {
                                            cubit
                                                .signUp(
                                              name: nameController
                                                  .text
                                                  .trim(),

                                              email: emailController
                                                  .text
                                                  .trim(),

                                              password:
                                                  passwordController
                                                      .text,

                                              phone: phoneController
                                                  .text
                                                  .trim(),

                                              role:
                                                  widget
                                                      .role,

                                              patientPhone:
                                                  isCaregiver
                                                      ? patientPhoneController
                                                          .text
                                                          .trim()
                                                      : null,
                                            );
                                          }
                                        },
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // OR
                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: AppColors.dividerGrey,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: Text(
                                    'أو',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: AppColors.dividerGrey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 30,
                            ),

                            // Google Signup Button
                            AuthButton(
                              text: 'المتابعة باستخدام جوجل',
                              isOutlined: true,
                              icon: SvgPicture.asset(
                                'assets/imgs/google_logo.svg',
                                height: 24,
                                width: 24,
                              ),
                              onPressed: () {
                                cubit.signInWithGoogle(createIfNotFound: true);
                              },
                            ),

                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
  }
}