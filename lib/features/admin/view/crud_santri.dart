import 'package:flutter/material.dart';
import 'package:Santri/features/admin/controllers/crud_santri_controller.dart';
import 'package:Santri/features/admin/model/santri_model.dart';
import 'package:provider/provider.dart';

class CrudSantri extends StatefulWidget {
  const CrudSantri({super.key});

  @override
  State<CrudSantri> createState() => _CrudSantriState();
}

class _CrudSantriState extends State<CrudSantri> {
  final _formKey = GlobalKey<FormState>();
  final _nisController = TextEditingController();
  final _namaController = TextEditingController();
  final _kamarController = TextEditingController();
  final _angkatanController = TextEditingController();
  Santri? _editingSantri;

  @override
  void dispose() {
    _nisController.dispose();
    _namaController.dispose();
    _kamarController.dispose();
    _angkatanController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nisController.clear();
    _namaController.clear();
    _kamarController.clear();
    _angkatanController.clear();
    _editingSantri = null;
  }

  void _submitForm(SantriProvider provider) {
    if (_formKey.currentState!.validate()) {
      final santri = Santri(
        id: _editingSantri?.id,
        nis: _nisController.text,
        nama: _namaController.text,
        kamar: _kamarController.text,
        angkatan: int.tryParse(_angkatanController.text) ?? 0,
      );
      provider.deleteSantri(0);

      if (_editingSantri == null) {
        provider.addSantri(santri);
      } else {
        provider.updateSantri(santri);
      }

      _resetForm();
    }
  }

  void _editSantri(Santri santri) {
    setState(() {
      _editingSantri = santri;
      _nisController.text = santri.nis;
      _namaController.text = santri.nama;
      _kamarController.text = santri.kamar;
      _angkatanController.text = santri.angkatan.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SantriProvider(),
      child: Scaffold(
        appBar: AppBar(title: Text("CRUD Santri")),
        body: Consumer<SantriProvider>(
          builder: (context, provider, _) => Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nisController,
                        decoration: InputDecoration(labelText: "NIS"),
                        validator: (value) =>
                            value!.isEmpty ? "NIS tidak boleh kosong" : null,
                      ),
                      TextFormField(
                        controller: _namaController,
                        decoration: InputDecoration(labelText: "Nama"),
                        validator: (value) =>
                            value!.isEmpty ? "Nama tidak boleh kosong" : null,
                      ),
                      TextFormField(
                        controller: _kamarController,
                        decoration: InputDecoration(labelText: "Kamar"),
                        validator: (value) =>
                            value!.isEmpty ? "Kamar tidak boleh kosong" : null,
                      ),
                      TextFormField(
                        controller: _angkatanController,
                        decoration: InputDecoration(labelText: "Angkatan"),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty
                            ? "Angkatan tidak boleh kosong"
                            : null,
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            child: Text(
                              _editingSantri == null ? "Tambah" : "Update",
                            ),
                            onPressed: () => _submitForm(provider),
                          ),
                          SizedBox(width: 10),
                          if (_editingSantri != null)
                            OutlinedButton(
                              onPressed: _resetForm,
                              child: Text("Batal"),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(height: 30),
                // List Santri
                Expanded(
                  child: provider.santriList.isEmpty
                      ? Center(child: Text("Belum ada data santri"))
                      : ListView.builder(
                          itemCount: provider.santriList.length,
                          itemBuilder: (_, index) {
                            print(provider.santriList[index]);
                            final santri = provider.santriList[index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(
                                  "${santri.nama} (ID: ${santri.id})",
                                ), // <--- tampilkan ID
                                subtitle: Text(
                                  "ID: ${santri.id} | NIS: ${santri.nis} | Kamar: ${santri.kamar} | Angkatan: ${santri.angkatan}",
                                ),
                                onTap: () => _editSantri(santri),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () =>
                                      provider.deleteSantri(santri.id!),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
