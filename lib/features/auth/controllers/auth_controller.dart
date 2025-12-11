import 'dart:convert';
import 'package:Santri/features/admin/view/admin_page.dart';
import 'package:Santri/features/admin/view/ustadzPage.dart';
import 'package:Santri/features/auth/view/login_page.dart';
import 'package:Santri/features/walisantri/views/wali_santri_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Santri/features/auth/model/user_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AppStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> saveUser({
    required String email,
    required String password,
    required String role,
  }) async {
    print("STATUS: Menyimpan user ke storage...");
    await _storage.write(key: 'email', value: email);
    await _storage.write(key: 'password', value: password);
    await _storage.write(key: 'role', value: role);
    print("STATUS: User berhasil disimpan!");
  }

  Future<Map<String, String?>> readUser() async {
    print("STATUS: Membaca user dari storage...");
    final data = {
      'email': await _storage.read(key: 'email'),
      'password': await _storage.read(key: 'password'),
      'role': await _storage.read(key: 'role'),
    };
    print("STATUS: Data user terbaca: $data");
    return data;
  }

  Future<void> logout() async {
    print("STATUS: Menghapus user dari storage...");
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'password');
    await _storage.delete(key: 'role');
    print("STATUS: Logout berhasil!");
  }
}

class AuthController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  var ustadzList = <User>[].obs;
  // var loading = true.obs;
  var loading = false.obs;
  var error = RxnString();

  // STATE LOGIN
  var isLoaded = false.obs; // untuk aplikasi pertama dibuka
  var isLoggedIn = false.obs; // user sedang login?
  var email = "".obs;
  var role = "".obs;

  @override
  void onInit() {
    super.onInit();
    autoLogin();
  }

  // ================================
  // AUTO LOGIN
  // ================================
  Future<void> autoLogin() async {
    print("AUTO LOGIN: Mengecek secure storage...");

    final emailStored = await _storage.read(key: 'email');
    final passwordStored = await _storage.read(key: 'password');
    final roleStored = await _storage.read(key: 'role');

    if (emailStored != null && passwordStored != null && roleStored != null) {
      email.value = emailStored;
      role.value = roleStored;
      isLoggedIn.value = true;

      print("AUTO LOGIN: User ditemukan: $emailStored ($roleStored)");

      if (roleStored == "admin") {
        Get.offAll(AdminPage());
      } else if (roleStored == "ustadz") {
        Get.offAll(Ustadzpage());
      } else if (roleStored == "wali") {
        Get.offAll(WaliSantriPage());
      }
    } else {
      print("AUTO LOGIN: Tidak ada user login.");
    }

    isLoaded.value = true;
  }

  // ================================
  // GET DATA USTADZ
  // ================================
Future<void> getData() async {
    loading.value = true;
    ustadzList.clear();

    final db = FirebaseDatabase.instance.ref("ustadz");

    try {
      final snapshot = await db.get();

      if (!snapshot.exists) {
        print("Firebase: NO DATA");
        loading.value = false;
        return;
      }

      final raw = snapshot.value;

      print("🔥 Firebase RAW TYPE: ${raw.runtimeType}");

      // ===================================================
      // JIKA DATA BERFORMAT MAP
      // ===================================================
      if (raw is Map) {
        raw.forEach((key, value) {
          if (value != null && value is Map) {
            ustadzList.add(
              User(
                email: value["email"]?.toString() ?? "",
                password: value["password"]?.toString() ?? "",
                role: value["role"]?.toString() ?? "ustadz",
              ),
            );
          }
        });
      }
      // ===================================================
      // JIKA DATA BERFORMAT LIST
      // ===================================================
      else if (raw is List) {
        for (var item in raw) {
          if (item != null && item is Map) {
            ustadzList.add(
              User(
                email: item["email"]?.toString() ?? "",
                password: item["password"]?.toString() ?? "",
                role: item["role"]?.toString() ?? "ustadz",
              ),
            );
          }
        }
      }

      print("USTADZ LOADED: ${ustadzList.length}");
    } catch (e) {
      print("❌ ERROR Firebase GET: $e");
    }

    loading.value = false;
  }

  // ================================
  // LOGIN
  // ================================
Future<User?> login(String emailInput, String passwordInput) async {
    loading.value = true;

    await getData(); // ambil data ustadz dari firebase

    User? user;

    // ADMIN
    if (emailInput == "admin@pesantren.com" && passwordInput == "123") {
      user = User(email: emailInput, role: "admin", password: passwordInput);
    }

    // USTADZ DARI FIREBASE
    for (var u in ustadzList) {
      if (emailInput == u.email && passwordInput == u.password) {
        user = User(email: u.email, role: u.role, password: u.password);
      }
    }

    // WALI
    if (emailInput == "wali@pesantren.com" && passwordInput == "123") {
      user = User(email: emailInput, role: "wali", password: passwordInput);
    }

    if (user == null) {
      print("LOGIN GAGAL: Email / password salah");
      loading.value = false;
      return null;
    }

    // SIMPAN USER KE STORAGE
    await _storage.write(key: 'email', value: user.email);
    await _storage.write(key: 'password', value: user.password);
    await _storage.write(key: 'role', value: user.role);

    isLoggedIn.value = true;
    email.value = user.email;
    role.value = user.role;

    loading.value = false;

    return user;
  }

  // ================================
  // LOGOUT
  // ================================
  Future<void> logout() async {
    await _storage.deleteAll();

    isLoggedIn.value = false;
    email.value = "";
    role.value = "";

    Get.offAll(LoginPage());
  }

  // ================================
  // NAVIGASI SETELAH LOGIN
  // ================================
  void navigateAfterLogin(String role) {
    if (role == "admin") {
      Get.offAllNamed("/admin");
    } else if (role == "wali") {
      Get.offAllNamed("/wali");
    } else if (role == "ustadz") {
      Get.offAllNamed("/ustadz");
    } else {
      Get.offAllNamed("/login");
    }
  }
}

class UserService {
  final String url = "https://example.com/api/users";

  Future<List<User>> getUsers() async {
    print("STATUS: Mengambil user dari API eksternal...");
    try {
      final response = await http.get(Uri.parse(url));
      print("STATUS: Response diterima kode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print("STATUS: Data berhasil diterima, jumlah: ${data.length}");
        return data.map((e) => User.fromJson(e)).toList();
      } else {
        print("STATUS: Error mengambil data (kode: ${response.statusCode})");
        throw Exception("Gagal mengambil data");
      }
    } catch (e) {
      print("STATUS ERROR GET API: $e");
      return [];
    }
  }
}

// class AuthController extends GetxController {
//   final FlutterSecureStorage _storage = FlutterSecureStorage();

//   var loading = false.obs;
//   var ustadzList = <User>[].obs;

//   // ============================
//   // GET DATA USTADZ DARI FIREBASE
//   // ============================
//   Future<void> getData() async {
//     loading.value = true;

//     final url = Uri.parse(
//       "https://coba1-5f863-default-rtdb.asia-southeast1.firebasedatabase.app/ustadz.json",
//     );

//     try {
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);

//         ustadzList.clear();

//         // Cek kalau data NULL
//         if (jsonData == null) {
//           print("Firebase mengembalikan null");
//           loading.value = false;
//           return;
//         }

//         // Jika Firebase mengembalikan MAP
//         if (jsonData is Map) {
//           jsonData.forEach((key, value) {
//             if (value != null) {
//               ustadzList.add(
//                 User(
//                   email: value['email'],
//                   password: value['password'],
//                   role: value["role"],
//                 ),
//               );
//             }
//           });
//         }
//         // Jika Firebase mengembalikan LIST (jarang tapi bisa terjadi)
//         else if (jsonData is List) {
//           for (var value in jsonData) {
//             if (value != null) {
//               ustadzList.add(
//                 User(
//                   email: value['email'],
//                   password: value['password'],
//                   role: value["role"],
//                 ),
//               );
//             }
//           }
//         } else {
//           print("Format JSON tidak diketahui: ${jsonData.runtimeType}");
//         }
//       }
//     } catch (e) {
//       print("Error GET API: $e");
//     }

//     loading.value = false;
//   }

//   // ============================
//   // LOGIN
//   // ============================
//   Future<User?> login(String email, String password) async {
//     await getData();

//     User? user;

//     // LOGIN ADMIN
//     if (email == "admin@pesantren.com" && password == "123") {
//       user = User(email: email, role: "admin", password: password);
//     }

//     // LOGIN USTADZ DARI FIREBASE
//     for (var ustadz in ustadzList) {
//       if (email == ustadz.email && password == ustadz.password) {
//         print("Login ustadz berhasil");
//         user = User(email: email, role: ustadz.role, password: password);
//       }
//     }

//     // LOGIN WALI SANTRI
//     if (email == "wali@pesantren.com" && password == "123") {
//       user = User(email: email, role: "wali", password: password);
//     }

//     // SIMPAN KE STORAGE JIKA USER VALID
//     if (user != null) {
//       await _storage.write(key: 'email', value: user.email);
//       await _storage.write(key: 'role', value: user.role);

//       // Password opsional – HINDARI jika tidak perlu!
//       await _storage.write(key: 'password', value: user.password);
//     }

//     return user;
//   }

//   // ============================
//   // CEK USER YANG SUDAH LOGIN
//   // ============================
//   Future<User?> getLoggedInUser() async {
//     final email = await _storage.read(key: 'email');
//     final role = await _storage.read(key: 'role');
//     final password = await _storage.read(key: 'password');

//     if (email != null && role != null && password !=null) {
//       return User(email: email, role: role, password: password);
//     }
//     return null;
//   }

//   // ============================
//   // LOGOUT
//   // ============================
//   Future<void> logout() async {
//     await _storage.delete(key: 'email');
//     await _storage.delete(key: 'role');
//     await _storage.delete(key: 'password');
//   }
// }
