import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_app/helpers/constant/text.dart';
import 'package:map_app/helpers/widgets/custom_elevated_button.dart';
import 'package:map_app/helpers/widgets/custom_textfield.dart';
import 'package:map_app/helpers/constant/enums.dart';
import 'package:map_app/services/controller/auth_controller.dart';
import 'package:map_app/helpers/constant/snack_bar.dart';
import 'package:map_app/screens/active_jobs_screen.dart';
import 'package:map_app/screens/admin_dashboard_screen.dart';

class LoginAndRegisterScreen extends StatefulWidget {
  const LoginAndRegisterScreen({super.key});

  @override
  State<LoginAndRegisterScreen> createState() => _LoginAndRegisterScreenState();
}

class _LoginAndRegisterScreenState extends State<LoginAndRegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final lastnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true;
  bool isAdmin = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    lastnameController.dispose();
    super.dispose();
  }

  void _createUser(WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text;
      String password = passwordController.text;
      String name = nameController.text;
      String lastName = lastnameController.text;

      final value = await ref.read(authControllerProvider).createAccount(email, password, name, lastName, isAdmin);
      if (value == AuthResultStatus.successful) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isAdmin ? const AdminDashboardScreen() : const ActiveJobsScreen(),
          ),
        );
      } else {
        snackBar(context, value.name);
      }
    }
  }

  void _signIn(WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      String email = emailController.text;
      String password = passwordController.text;

      final value = await ref.read(authControllerProvider).login(email, password, isAdmin);
      if (value == AuthResultStatus.successful) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isAdmin ? const AdminDashboardScreen() : const ActiveJobsScreen(),
          ),
        );
      } else {
        snackBar(context, value.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return Form(
        key: _formKey,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isLogin) ...[
                  CustomTextField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        snackBar(context, ConstantText.notEmptyName);
                      }
                      return null;
                    },
                    controller: nameController,
                    hintText: ConstantText.name,
                  ),
                  CustomTextField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        snackBar(context, ConstantText.notEmptySurname);
                      }
                      return null;
                    },
                    controller: lastnameController,
                    hintText: ConstantText.surname,
                  ),
                ],
                CustomTextField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      snackBar(context, ConstantText.notEmptyMail);
                    }
                    return null;
                  },
                  controller: emailController,
                  hintText: ConstantText.mail,
                  prefixIcon: const Icon(Icons.mail_outline),
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      snackBar(context, ConstantText.notEmptyPassword);
                    }
                    return null;
                  },
                  obscureText: true,
                  controller: passwordController,
                  hintText: ConstantText.password,
                  prefixIcon: const Icon(Icons.password),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isLogin ? Text(ConstantText.isAdminLogin) : Text(ConstantText.isAdminJoin),
                    Checkbox(
                      activeColor: Colors.lightBlueAccent,
                      value: isAdmin,
                      onChanged: (value) {
                        setState(() {
                          isAdmin = value!;
                        });
                      },
                    ),
                  ],
                ),
                CustomElevatedButton(
                    onPressed: () {
                      if (isLogin) {
                        _signIn(ref);
                      } else {
                        _createUser(ref);
                      }
                    },
                    buttonText: isLogin ? ConstantText.login : ConstantText.join),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: isLogin
                      ? Text(ConstantText.notHaveJoin, style: const TextStyle(color: Colors.lightBlueAccent))
                      : Text(ConstantText.haveJoin, style: const TextStyle(color: Colors.lightBlueAccent)),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
