import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/providers_auth.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/auth/model/user_model.dart';
import '../../admin/view/admin_page.dart';
import '../../santri/views/santri_page.dart';
import '../../walisantri/views/wali_santri_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = AuthController();

  bool loading = false;
  String? error;

  void handleLogin() async {
    setState(() {
      loading = true;
      error = null;
    });

    final User? user = await authController.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      loading = false;
    });

    if (user != null) {
      context.read<AuthProvider>().login(user);

      Widget home;
      switch (user.role) {
        case 'admin':
          home = AdminPage();
          break;
        case 'ustadz':
          home = AdminPage();
          break;
        case 'wali':
          home = SantriNilaiListPage();
          break;
        default:
          home = LoginPage();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => home),
      );
    } else {
      setState(() {
        error = "Email atau password salah!";
      });
    }
  }

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
                  loading
                      ? CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: handleLogin,
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
                        ),
                  if (error != null) ...[
                    SizedBox(height: 16),
                    Text(error!, style: TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
