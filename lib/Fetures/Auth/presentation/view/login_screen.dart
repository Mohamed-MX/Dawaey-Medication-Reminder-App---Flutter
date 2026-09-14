import 'package:dawaey/Fetures/Auth/presentation/view/role_selection_screen.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_cubit.dart';
import 'package:dawaey/Fetures/Auth/presentation/view_model/auth_state.dart';
import 'package:dawaey/Fetures/Auth/presentation/widgets/auth_button.dart';
import 'package:dawaey/Fetures/Auth/presentation/widgets/auth_text_field.dart';
import 'package:dawaey/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dawaey/Fetures/Auth/data/models/user_model.dart';
import 'package:dawaey/Fetures/Auth/presentation/view/signup_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();

    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isTablet = screenWidth >= 600;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          if (state.message.contains('google_new_user')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SignupScreen(role: UserRole.patient),
              ),
            );
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
          // BlocBuilder in main.dart handles routing automatically
        }
      },
      builder: (context, state) {
        final cubit = context.read<AuthCubit>();

        return Directionality(
          textDirection: TextDirection.rtl,

            child: Scaffold(
              // خلفية شاشة الـ Login
              backgroundColor: AppColors.authBackground,

              body: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 60 : 24,
                      vertical: 20,
                    ),

                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 460,
                      ),

                      child: Form(
                        key: formKey,

                        child: Column(
                          children: [
                            SizedBox(
                              height: isTablet ? 30 : 20,
                            ),

                            // Logo
                            SizedBox(
                              width: isTablet ? 180 : 145,
                              height: isTablet ? 120 : 100,
                              child: Image.asset(
                                'assets/transpa app icon.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(
                              height: isTablet ? 35 : 25,
                            ),

                            // Title
                            Text(
                              'مرحبًا بعودتك',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: AppColors.primaryBlue,

                                fontSize: isTablet ? 32 : 29,

                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            // Subtitle
                            Text(
                              'سجل دخولك لمتابعة العناية',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: AppColors.greyText,

                                fontSize: isTablet ? 18 : 16,
                              ),
                            ),

                            SizedBox(
                              height: isTablet ? 55 : 45,
                            ),

                            // Email
                            AuthTextField(
                              controller: emailController,

                              hintText: 'البريد الإلكتروني',

                              icon: Icons.email_outlined,

                              keyboardType:
                                  TextInputType.emailAddress,

                              textInputAction:
                                  TextInputAction.next,

                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'اكتب البريد الإلكتروني';
                                }

                                if (!value.contains('@')) {
                                  return 'اكتب بريد إلكتروني صحيح';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 18,
                            ),

                            // Password
                            AuthTextField(
                              controller: passwordController,

                              hintText: 'كلمة المرور',

                              icon: Icons.lock_outline,

                              obscureText:
                                  cubit.hidePassword,

                              textInputAction:
                                  TextInputAction.done,

                              suffixIcon: IconButton(
                                onPressed: () {
                                  cubit.changePasswordVisibility();
                                },

                                icon: Icon(
                                  cubit.hidePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,

                                  color: AppColors.primaryBlue,
                                ),
                              ),

                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'اكتب كلمة المرور';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            // Remember Me
                            Align(
                              alignment: Alignment.centerRight,

                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Checkbox(
                                    value: cubit.rememberMe,

                                    activeColor:
                                        AppColors.primaryBlue,

                                    onChanged: (value) {
                                      cubit.changeRememberMe(
                                        value ?? false,
                                      );
                                    },
                                  ),

                                  const Text(
                                    'تذكرني',

                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(
                              height: 28,
                            ),

                            // Login Button
                            AuthButton(
                              text: 'تسجيل الدخول',

                              isLoading:
                                  state is AuthLoading,

                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      if (formKey
                                          .currentState!
                                          .validate()) {
                                        cubit.login(
                                          email:
                                              emailController
                                                  .text
                                                  .trim(),

                                          password:
                                              passwordController
                                                  .text,
                                        );
                                      }
                                    },
                            ),

                            const SizedBox(
                              height: 32,
                            ),

                            // OR
                            const Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color:
                                        AppColors.dividerGrey,
                                  ),
                                ),

                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),

                                  child: Text(
                                    'أو',

                                    style: TextStyle(
                                      fontSize: 16,
                                      color:
                                          AppColors.textDark,
                                    ),
                                  ),
                                ),

                                Expanded(
                                  child: Divider(
                                    color:
                                        AppColors.dividerGrey,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 32,
                            ),

                            // Google Login Button
                            AuthButton(
                              text: 'المتابعة باستخدام جوجل',
                              isOutlined: true,
                              icon: SvgPicture.asset(
                                'assets/imgs/google_logo.svg',
                                height: 24,
                                width: 24,
                              ),
                              onPressed: () {
                                cubit.signInWithGoogle();
                              },
                            ),

                            const SizedBox(
                              height: 16,
                            ),

                            // Create Account Button
                            AuthButton(
                              text: 'إنشاء حساب',

                              isOutlined: true,

                              onPressed: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const SignupScreen(role: UserRole.patient);
                                    },
                                  ),
                                );
                              },
                            ),

                            const SizedBox(
                              height: 25,
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