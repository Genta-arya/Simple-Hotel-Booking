import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';
class CheckInForm extends StatefulWidget {
  @override
  _CheckInFormState createState() => _CheckInFormState();
}

class _CheckInFormState extends State<CheckInForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _checkInController = TextEditingController();
  final TextEditingController _checkOutController = TextEditingController();
  String? _selectedKamar;
  int? _selectedKamarStok;
  int? _selectedJumlahKamar;

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // Mengatur tanggal awal ke hari ini
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent,
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
            colorScheme: ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getKamarList() async {
    final List<Map<String, dynamic>> kamarList = [];
    final snapshot = await FirebaseFirestore.instance.collection('kamar').get();
    for (var doc in snapshot.docs) {
      kamarList.add({
        'nama': doc['nama'],
        'jumlah': doc['jumlah'],
      });
    }
    return kamarList;
  }

  Future<void> _showKamarSelection() async {
    List<Map<String, dynamic>> kamarList = await _getKamarList();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: kamarList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(kamarList[index]['nama']),
              subtitle: Text("Tersedia: ${kamarList[index]['jumlah']} kamar"),
              onTap: () {
                setState(() {
                  _selectedKamar = kamarList[index]['nama'];
                  _selectedKamarStok = kamarList[index]['jumlah'];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _showJumlahKamarSelection() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _selectedKamarStok ?? 0,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text("Jumlah: ${index + 1}"),
              onTap: () {
                setState(() {
                  _selectedJumlahKamar = index + 1;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }




Future<void> _simpanData() async {
  // Menghasilkan nomor kamar acak antara 1 dan 1000
  int noKamar = Random().nextInt(1000) + 1; // +1 agar tidak mulai dari 0

  // Menyimpan data ke Firestore
  await FirebaseFirestore.instance.collection('checkin').add({
    'nama': _namaController.text,
    'nik': _nikController.text,
    'checkIn': _checkInController.text,
    'checkOut': _checkOutController.text,
    'kamar': _selectedKamar,
    'jumlahKamar': _selectedJumlahKamar,
    'noKamar': noKamar, // Simpan noKamar yang telah ditentukan
  });

  // Mengurangi stok kamar
  if (_selectedKamar != null && _selectedJumlahKamar != null) {
    final kamarDoc = await FirebaseFirestore.instance
        .collection('kamar')
        .where('nama', isEqualTo: _selectedKamar)
        .limit(1)
        .get();
    if (kamarDoc.docs.isNotEmpty) {
      var doc = kamarDoc.docs.first;
      int updatedStok = doc['jumlah'] - _selectedJumlahKamar!;
      await doc.reference.update({'jumlah': updatedStok});
    }
  }
}


  bool _validateDates() {
    DateTime? checkInDate = _checkInController.text.isNotEmpty
        ? DateFormat('dd-MM-yyyy').parse(_checkInController.text)
        : null;
    DateTime? checkOutDate = _checkOutController.text.isNotEmpty
        ? DateFormat('dd-MM-yyyy').parse(_checkOutController.text)
        : null;

    if (checkInDate == null || checkOutDate == null) {
      return false; // Tanggal tidak valid
    }

    

    if (checkOutDate.isBefore(checkInDate)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Tanggal Check-Out tidak boleh kurang dari Check-In.'),
        backgroundColor: Colors.red,
      ));
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white), // Warna panah putih
        title: Row(
          children: [
            Icon(Icons.hotel, color: Colors.white),
            SizedBox(width: 8),
            Text("Form Check-In"),
          ],
        ),
        elevation: 4,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.blueAccent.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _namaController,
                              decoration: InputDecoration(
                                labelText: 'Nama',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan nama';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            TextFormField(
                              controller: _nikController,
                              decoration: InputDecoration(
                                labelText: 'NIK',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.credit_card),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Masukkan NIK';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.0),
                            GestureDetector(
                              onTap: () =>
                                  _selectDate(context, _checkInController),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _checkInController,
                                  decoration: InputDecoration(
                                    labelText: 'Tanggal Check-In',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Masukkan tanggal check-in';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            GestureDetector(
                              onTap: () =>
                                  _selectDate(context, _checkOutController),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _checkOutController,
                                  decoration: InputDecoration(
                                    labelText: 'Tanggal Check-Out',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Masukkan tanggal check-out';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            GestureDetector(
                              onTap: _showKamarSelection,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: _selectedKamar ?? 'Pilih Kamar',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.bed),
                                  ),
                                  validator: (value) {
                                    if (_selectedKamar == null) {
                                      return 'Pilih kamar';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 16.0),
                            GestureDetector(
                              onTap: _selectedKamarStok != null
                                  ? _showJumlahKamarSelection
                                  : null,
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: _selectedJumlahKamar != null
                                        ? 'Jumlah Kamar: $_selectedJumlahKamar'
                                        : 'Pilih Jumlah Kamar',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.confirmation_num),
                                  ),
                                  validator: (value) {
                                    if (_selectedJumlahKamar == null) {
                                      return 'Pilih jumlah kamar';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.0),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (_formKey.currentState!.validate() && _validateDates()) {
                            await _simpanData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white), // Ikon ceklis
                                    SizedBox(
                                        width: 8), // Spasi antara ikon dan teks
                                    Text('Data berhasil disimpan',
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                backgroundColor: Colors
                                    .green, // Warna hijau untuk pesan berhasil
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10)), // SnackBar melayang dengan sudut membulat
                                duration: Duration(
                                    seconds: 2), // Durasi tampil SnackBar
                              ),
                            );

                            _formKey.currentState!.reset();
                            _namaController.clear();
                            _nikController.clear();
                            _checkInController.clear();
                            _checkOutController.clear();
                            setState(() {
                              _selectedKamar = null;
                              _selectedJumlahKamar = null;
                              _selectedKamarStok = null;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        icon: Icon(Icons.check_circle, color: Colors.white),
                        label: Text(
                          'Check-In',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
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
}
