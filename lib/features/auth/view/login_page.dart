import 'package:Santri/features/admin/view/ustadzPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/auth/model/user_model.dart';
import '../../admin/view/admin_page.dart';
import '../../santri/views/santri_page.dart';
import '../../walisantri/views/wali_santri_page.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final auth = Get.put(AuthController()); // DAFTARKAN CONTROLLER

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, size: 80, color: Colors.blue),
                  SizedBox(height: 16),
                  Text(
                    "e-Penilaian Santri",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  SizedBox(height: 24),

                  // EMAIL
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // BUTTON LOGIN
                  Obx(() {
                    return auth.loading.value
                        ? CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                await handleLogin();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Login",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                  }),

                  SizedBox(height: 16),

                  // ERROR MESSAGE
                  Obx(() {
                    return auth.error.value == null
                        ? SizedBox()
                        : Text(
                            auth.error.value!,
                            style: TextStyle(color: Colors.red),
                          );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // LOGIN METHOD VERSI GETX
 
 Future<void> handleLogin() async {
    auth.error.value = null;

    User? user = await auth.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (user != null) {
      switch (user.role) {
        case 'admin':
          Get.offAll(() => AdminPage());
          break;

        case 'ustadz':
          Get.offAll(() => Ustadzpage());
          break;

        case 'wali':
          Get.offAll(() => WaliSantriPage()); // PERBAIKAN INI
          break;

        default:
          auth.error.value = "Role tidak dikenali!";
      }
    } else {
      auth.error.value = "Email atau password salah!";
    }
  }

 }
