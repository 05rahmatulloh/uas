import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';

// =======================
// MODEL
// =======================
class UserModel {
  String nama;
  String password;
  String role;

  UserModel({required this.nama, required this.password, required this.role});

  Map<String, dynamic> toJson() {
    return {"email": nama, "password": password, "role": role};
  }
}

// =======================
// GETX CONTROLLER
// =======================
class UserController extends GetxController {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref(
    "ustadz",
  ); // → folder "ustadz"

  var loading = false.obs;

  Future<void> tambahUser(UserModel user) async {
    loading.value = true;

    try {
      // push() → auto generate key
      await dbRef.push().set(user.toJson());

      Get.snackbar(
        "Berhasil",
        "User berhasil ditambahkan!",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }

    loading.value = false;
  }
}

// =======================
// UI / HALAMAN INPUT
// =======================
class InputUserPageUstadz extends StatelessWidget {
  final namaController = TextEditingController();
  final passwordController = TextEditingController();

  final userCtrl = Get.put(UserController());

  final RxString selectedRole = "ustadz".obs;

  final List<String> roles = ["admin", "ustadz"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tambah User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // INPUT NAMA
            TextField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: "Nama",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // INPUT PASSWORD
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // DROPDOWN ROLE
            Obx(
              () => DropdownButtonFormField(
                value: selectedRole.value,
                items: roles
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                decoration: InputDecoration(
                  labelText: "Role",
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => selectedRole.value = v!,
              ),
            ),

            SizedBox(height: 24),

            // BUTTON SIMPAN
            Obx(
              () => userCtrl.loading.value
                  ? CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (namaController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Nama dan password tidak boleh kosong",
                            );
                            return;
                          }

                          UserModel user = UserModel(
                            nama: namaController.text,
                            password: passwordController.text,
                            role: selectedRole.value,
                          );

                          userCtrl.tambahUser(user);

                          namaController.clear();
                          passwordController.clear();
                          selectedRole.value = "ustadz";
                        },
                        child: Text("SIMPAN"),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
