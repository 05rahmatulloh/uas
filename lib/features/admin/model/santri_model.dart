class Santri {
  int? id;
  String nis;
  String nama;
  String kamar;
  int angkatan;

  Santri({
    this.id,
    required this.nis,
    required this.nama,
    required this.kamar,
    required this.angkatan,
  });

  // Convert object to map (for insert/update)
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'nis': nis,
      'nama': nama,
      'kamar': kamar,
      'angkatan': angkatan,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // Convert map to object
  factory Santri.fromMap(Map<String, dynamic> map) {
    return Santri(
      id: map['id'],
      nis: map['nis'],
      nama: map['nama'],
      kamar: map['kamar'],
      angkatan: map['angkatan'],
    );
  }
}
