import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import ini untuk format angka

class KamarScreen extends StatelessWidget {
  const KamarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        titleTextStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('kamar').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var kamarList = snapshot.data!.docs;

                  if (kamarList.isEmpty) {
                    return const Center(
                        child: Text('Belum ada kamar',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)));
                  }

                  return ListView.builder(
                    itemCount: kamarList.length,
                    itemBuilder: (context, index) {
                      var kamar = kamarList[index];
                      String namaKamar = kamar['nama'] ?? 'Nama tidak tersedia';
                      String kodeKamar =
                          kamar['kode_kamar'] ?? 'Kode tidak tersedia';
                      int jumlah = kamar['jumlah'] ?? 0;
                      int harga =
                          kamar['harga'] ?? 0; // Ambil harga dari Firestore

                      return _buildKamarCard(context, kamar.id, namaKamar,
                          kodeKamar, jumlah, harga);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _showAddKamarDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text("Tambah Kamar"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKamarCard(BuildContext context, String id, String namaKamar,
      String kodeKamar, int jumlah, int harga) {
    return GestureDetector(
      onTap: () =>
          _showKamarOptions(context, id, namaKamar, kodeKamar, jumlah, harga),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.hotel,
                  color: Colors.blueAccent, size: 40), // Ikon kamar
              const SizedBox(width: 16), // Spasi antara ikon dan teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaKamar,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kode: $kodeKamar',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jumlah Tersedia: $jumlah',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      // convert ke rupiah
                      '${NumberFormat.currency(locale: 'id', symbol: 'Rp.').format(harga)} / malam', // Tampilkan harga
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                onPressed: () {
                  _showEditKamarDialog(context, id, namaKamar, jumlah, harga);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKamarOptions(BuildContext context, String id, String namaKamar,
      String kodeKamar, int jumlah, int harga) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          height: 150,
          child: Column(
            children: [
              Text('Pilihan untuk $namaKamar',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showEditKamarDialog(context, id, namaKamar, jumlah,
                            harga); // Pass harga
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Edit Kamar'),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: ElevatedButton(
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('kamar')
                            .doc(id)
                            .delete()
                            .then((_) {
                          // kasi warna
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Kamar berhasil dihapus'),
                              backgroundColor: Colors
                                  .red, // Ganti dengan warna yang Anda inginkan
                            ),
                          );
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Gagal menghapus kamar: $error')));
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Hapus Kamar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditKamarDialog(BuildContext context, String id, String namaKamar,
      int jumlah, int harga) {
    final TextEditingController _namaController =
        TextEditingController(text: namaKamar);
    final TextEditingController _jumlahController =
        TextEditingController(text: jumlah.toString());
    final TextEditingController _hargaController =
        TextEditingController(text: harga.toString()); // Controller untuk harga

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Kamar',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    hintText: "Nama Kamar",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _jumlahController,
                  decoration: InputDecoration(
                    hintText: "Jumlah Tersedia",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _hargaController,
                  decoration: InputDecoration(
                    hintText: "Harga (dalam IDR)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String namaKamar = _namaController.text;
                String jumlahTersedia = _jumlahController.text;
                String harga = _hargaController.text; // Ambil nilai harga

                // Validasi input
                if (namaKamar.isEmpty ||
                    jumlahTersedia.isEmpty ||
                    harga.isEmpty ||
                    int.tryParse(jumlahTersedia) == null ||
                    int.tryParse(harga) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Nama, jumlah, dan harga harus diisi dengan benar')),
                  );
                  return;
                }

                // Update data kamar di Firestore
                FirebaseFirestore.instance.collection('kamar').doc(id).update({
                  'nama': namaKamar,
                  'jumlah': int.parse(jumlahTersedia),
                  'harga': int.parse(harga), // Tambahkan update harga
                }).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Kamar berhasil diperbarui')));
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Gagal memperbarui kamar: $error')));
                });
              },
              child: const Text('Simpan',
                  style: TextStyle(color: Colors.blueAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  void _showAddKamarDialog(BuildContext context) {
    final TextEditingController _namaController = TextEditingController();
    final TextEditingController _jumlahController = TextEditingController();
    final TextEditingController _hargaController =
        TextEditingController(); // Controller untuk harga

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tambah Kamar',
                  style: TextStyle(color: Colors.blueAccent, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _namaController,
                  decoration: InputDecoration(
                    hintText: "Nama Kamar",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _jumlahController,
                  decoration: InputDecoration(
                    hintText: "Jumlah Tersedia",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _hargaController,
                  decoration: InputDecoration(
                    hintText: "Harga (dalam IDR)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String namaKamar = _namaController.text;
                String jumlahTersedia = _jumlahController.text;
                String harga = _hargaController.text; // Ambil nilai harga

                // Validasi input
                if (namaKamar.isEmpty ||
                    jumlahTersedia.isEmpty ||
                    harga.isEmpty ||
                    int.tryParse(jumlahTersedia) == null ||
                    int.tryParse(harga) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Nama, jumlah, dan harga harus diisi dengan benar')),
                  );
                  return;
                }

                String kodeKamar = _generateRandomString(6); // Kode kamar acak

                // Simpan data kamar ke Firestore
                FirebaseFirestore.instance.collection('kamar').add({
                  'nama': namaKamar,
                  'kode_kamar': kodeKamar,
                  'jumlah': int.parse(jumlahTersedia),
                  'harga': int.parse(harga), // Tambahkan harga
                }).then((value) {
                  print(
                      'Kamar ditambahkan: $namaKamar, Kode: $kodeKamar, Jumlah: $jumlahTersedia, Harga: $harga');
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menambahkan kamar: $error')),
                  );
                });
              },
              child: const Text('Tambah',
                  style: TextStyle(color: Colors.blueAccent)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  String _generateRandomString(int length) {
    const _randomChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(
            length, (_) => _randomChars[random.nextInt(_randomChars.length)])
        .join();
  }
}
