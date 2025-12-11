import 'dart:io';
import 'package:Santri/core/dbhelper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'firebase_options.dart';
import 'features/admin/controllers/bobot_nilai.dart';
import 'features/admin/view/admin_page.dart';
import 'features/santri/views/santri_page.dart';
import 'features/walisantri/views/wali_santri_page.dart';
import 'features/auth/view/login_page.dart';
import 'providers/providers_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// WAJIB PAKAI OPTIONS
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
// final connectionProvider = ConnectionProvider();
//   DBHelper().setConnectionProvider(connectionProvider);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BobotProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseConnectionProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isLoaded) {
          return GetMaterialApp(
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
              homePage = SantriNilaiListPage();
              break;
            default:
              homePage = LoginPage();
          }
        } else {
          homePage = LoginPage();
        }

        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'e-Penilaian Santri',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: homePage,
        );
      },
    );
  }
}
