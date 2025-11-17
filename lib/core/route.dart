import 'package:flutter/material.dart';
import 'package:itull2/features/admin/view/admin_page.dart';
import 'package:itull2/features/auth/view/login_page.dart';
import 'package:itull2/features/santri/views/santri_page.dart';
import 'package:itull2/features/walisantri/views/wali_santri_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String admin = '/admin';
  static const String wali = '/wali';
  static const String santri = '/santri';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case admin:
        return MaterialPageRoute(builder: (_) => AdminPage());
      case wali:
        return MaterialPageRoute(builder: (_) => WaliSantriPage());
      case santri:
        return MaterialPageRoute(builder: (_) => SantriPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
