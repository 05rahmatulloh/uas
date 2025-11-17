import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:itull2/features/admin/controllers/bobot_nilai.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'features/admin/view/admin_page.dart';
import 'features/santri/views/santri_page.dart';
import 'features/walisantri/views/wali_santri_page.dart';
import 'features/auth/view/login_page.dart';
import 'providers/providers_auth.dart';
// import 'providers/mata_pelajaran_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi FFI untuk desktop
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BobotProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // ChangeNotifierProvider(
        //   create: (_) => MataPelajaranProvider(),
        // ), // provider global
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Consumer<AuthProvider>(
      
      builder: (context, auth, _) {
        if (!auth.isLoaded) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        Widget homePage;
        if (auth.isLoggedIn) {
          switch (auth.user!.role) {
            case 'admin':
              homePage = AdminPage();
              break;
            case 'wali':
              homePage = WaliSantriPage();
              break;
            case 'santri':
              homePage = SantriPage();
              break;
            default:
              homePage = LoginPage();
          }
        } else {
          homePage = LoginPage();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'e-Penilaian Santri',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: homePage,
        );
      },
    );
  }
}
