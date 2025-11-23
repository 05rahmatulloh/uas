import 'package:flutter/material.dart';
import 'package:Santri/core/route.dart';
import 'package:Santri/features/auth/controllers/auth_controller.dart';
import 'package:Santri/features/auth/view/login_page.dart';
import 'package:Santri/providers/providers_auth.dart';
import 'package:provider/provider.dart';

class WaliSantriPage extends StatelessWidget {
    final AuthController authController = AuthController();

   WaliSantriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text("wali santri Page"),
    
       actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          ),
        ],
 
    
         ),
    body: Center(child: Text("Selamat datang, Wali Santri!")),
    );
  }
}
