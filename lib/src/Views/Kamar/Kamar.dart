import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                stream: FirebaseFirestore.instance.collection('kamar').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var kamarList = snapshot.data!.docs;

                  if (kamarList.isEmpty) {
                    return const Center(child: Text('Belum ada kamar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
                  }

                  return ListView.builder(
                    itemCount: kamarList.length,
                    itemBuilder: (context, index) {
                      var kamar = kamarList[index];
                      String namaKamar = kamar['nama'] ?? 'Nama tidak tersedia';
                      String kodeKamar = kamar['kode_kamar'] ?? 'Kode tidak tersedia';
                      int jumlah = kamar['jumlah'] ?? 0;

                      return _buildKamarCard(context, kamar.id, namaKamar, kodeKamar, jumlah);
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
              icon: const Icon(Icons.add), // Ikon plus
              label: const Text("Tambah Kamar"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14 , horizontal: 24), // Padding vertical
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

  Widget _buildKamarCard(BuildContext context, String id, String namaKamar, String kodeKamar, int jumlah) {
    return GestureDetector(
      onTap: () => _showKamarOptions(context, id, namaKamar, kodeKamar, jumlah),
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
              Icon(Icons.hotel, color: Colors.blueAccent, size: 40), // Ikon kamar
              const SizedBox(width: 16), // Spasi antara ikon dan teks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaKamar,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kode Kamar: $kodeKamar',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tersedia: $jumlah',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKamarOptions(BuildContext context, String id, String namaKamar, String kodeKamar, int jumlah) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          width: double.infinity,
          height: 150,
          child: Column(
            children: [
              Text('Pilihan untuk $namaKamar', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Mendistribusikan ruang secara merata
                children: [
                  SizedBox(
                    width: 140, // Lebar tetap untuk tombol
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showEditKamarDialog(context, id, namaKamar, jumlah);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Edit Kamar'),
                    ),
                  ),
                  SizedBox(
                    width: 140, // Lebar tetap untuk tombol
                    child: ElevatedButton(
                      onPressed: () {
                        // Hapus kamar
                        FirebaseFirestore.instance.collection('kamar').doc(id).delete().then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kamar berhasil dihapus')));
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus kamar: $error')));
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

  void _showEditKamarDialog(BuildContext context, String id, String namaKamar, int jumlah) {
    final TextEditingController _namaController = TextEditingController(text: namaKamar);
    final TextEditingController _jumlahController = TextEditingController(text: jumlah.toString());

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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String namaKamar = _namaController.text;
                String jumlahTersedia = _jumlahController.text;

                // Validasi input
                if (namaKamar.isEmpty || jumlahTersedia.isEmpty || int.tryParse(jumlahTersedia) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama dan jumlah harus diisi dengan benar')),
                  );
                  return;
                }

                // Update data kamar di Firestore
                FirebaseFirestore.instance.collection('kamar').doc(id).update({
                  'nama': namaKamar,
                  'jumlah': int.parse(jumlahTersedia),
                }).then((value) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kamar berhasil diperbarui')));
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui kamar: $error')));
                });
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.blueAccent)),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String namaKamar = _namaController.text;
                String jumlahTersedia = _jumlahController.text;

                // Validasi input
                if (namaKamar.isEmpty || jumlahTersedia.isEmpty || int.tryParse(jumlahTersedia) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nama dan jumlah harus diisi dengan benar')),
                  );
                  return;
                }

                String kodeKamar = _generateRandomString(6); // Kode kamar acak

                // Simpan data kamar ke Firestore
                FirebaseFirestore.instance.collection('kamar').add({
                  'nama': namaKamar,
                  'kode_kamar': kodeKamar,
                  'jumlah': int.parse(jumlahTersedia),
                }).then((value) {
                  print('Kamar ditambahkan: $namaKamar, Kode: $kodeKamar, Jumlah: $jumlahTersedia');
                  Navigator.of(context).pop();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal menambahkan kamar: $error')),
                  );
                });
              },
              child: const Text('Tambah', style: TextStyle(color: Colors.blueAccent)),
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
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return List.generate(length, (index) => characters[random.nextInt(characters.length)]).join();
  }
}
