import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInForm extends StatefulWidget {
  @override
  _CheckInFormState createState() => _CheckInFormState();
}

class _CheckInFormState extends State<CheckInForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _namaController = TextEditingController();
  TextEditingController _nikController = TextEditingController();
  TextEditingController _checkInController = TextEditingController();
  TextEditingController _checkOutController = TextEditingController();
  String? _selectedKamar;
  int? _selectedKamarStok;
  int? _selectedJumlahKamar;

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
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

  Future<void> _simpanData() async {
    // Simpan data check-in ke Firestore
    await FirebaseFirestore.instance.collection('checkin').add({
      'nama': _namaController.text,
      'nik': _nikController.text,
      'checkIn': _checkInController.text,
      'checkOut': _checkOutController.text,
      'kamar': _selectedKamar,
      'jumlahKamar': _selectedJumlahKamar,
    });

    // Kurangi stok kamar
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Form Check-In"),
        toolbarHeight: 50,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
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
              TextFormField(
                controller: _checkInController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Check-In',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _checkInController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan tanggal check-in';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _checkOutController,
                decoration: InputDecoration(
                  labelText: 'Tanggal Check-Out',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectDate(context, _checkOutController),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan tanggal check-out';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getKamarList(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Pilih Kamar',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedKamar,
                    items: snapshot.data!.map((kamarData) {
                      return DropdownMenuItem<String>(
                        value: kamarData['nama'] as String,
                        child: Text(kamarData['nama']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKamar = value;
                        _selectedKamarStok = snapshot.data!
                            .firstWhere((kamarData) =>
                                kamarData['nama'] == value)['jumlah'];
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih kamar';
                      }
                      return null;
                    },
                  );
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Jumlah Kamar',
                  border: OutlineInputBorder(),
                ),
                value: _selectedJumlahKamar,
                items: _selectedKamarStok != null
                    ? List.generate(
                        _selectedKamarStok!,
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text((index + 1).toString()),
                        ),
                      )
                    : [],
                onChanged: (value) {
                  setState(() {
                    _selectedJumlahKamar = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih jumlah kamar';
                  } else if (value > _selectedKamarStok!) {
                    return 'Jumlah kamar tidak boleh lebih dari stok';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32.0),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedKamarStok != null &&
                          _selectedJumlahKamar != null &&
                          _selectedJumlahKamar! <= _selectedKamarStok!) {
                        await _simpanData(); // Simpan data dan update stok
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Data berhasil disimpan')),
                        );
                        // Reset form setelah menyimpan data
                        _formKey.currentState!.reset();
                        setState(() {
                          _selectedKamar = null;
                          _selectedJumlahKamar = null;
                          _selectedKamarStok = null;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Jumlah kamar melebihi stok yang tersedia')),
                        );
                      }
                    }
                  },
                  child: Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
