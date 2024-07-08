import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProduk extends StatefulWidget {
  final int id;

  EditProduk({required this.id});

  @override
  _EditProdukState createState() => _EditProdukState();
}

class _EditProdukState extends State<EditProduk> {
  final TextEditingController namaBarangController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController hargaModalController = TextEditingController();
  final TextEditingController hargaEceranController = TextEditingController();
  final TextEditingController hargaGrosirController = TextEditingController();
  final TextEditingController satuanController = TextEditingController();
  final TextEditingController stokBesarController = TextEditingController();
  final TextEditingController jumlahIsiController = TextEditingController();
  final TextEditingController hargaEceranBesarController =
      TextEditingController();
  final TextEditingController satuanBesarController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    final String apiUrl = "http://shop.mzverse.my.id/api/view_data.php";

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'id': widget.id.toString(),
      },
    );

    if (response.statusCode == 200) {
      final List responseData = json.decode(response.body);
      if (responseData.isNotEmpty) {
        final produk = responseData.first;
        setState(() {
          namaBarangController.text = produk['nama_barang'] ?? '';
          barcodeController.text = produk['barcode_barang'] ?? '';
          stokController.text = produk['stok_barang']?.toString() ?? '';
          hargaModalController.text = produk['harga_modal']?.toString() ?? '';
          hargaEceranController.text = produk['harga_eceran']?.toString() ?? '';
          hargaGrosirController.text = produk['harga_grosir']?.toString() ?? '';
          satuanController.text = produk['satuan_barang'] ?? '';
          stokBesarController.text =
              produk['stok_besar_barang']?.toString() ?? '';
          jumlahIsiController.text =
              produk['jumlah_isi_barang']?.toString() ?? '';
          hargaEceranBesarController.text =
              produk['harga_eceran_besar']?.toString() ?? '';
          satuanBesarController.text = produk['satuan_besar_barang'] ?? '';
          isLoading = false;
        });
      } else {
        print("Data not found");
      }
    } else {
      print("Failed to fetch data");
    }
  }

  Future<void> updateProduk() async {
    final String apiUrl = "http://shop.mzverse.my.id/api/update_data.php";

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'id': widget.id.toString(),
        'nama_barang': namaBarangController.text,
        'barcode_barang': barcodeController.text,
        'stok_barang': stokController.text,
        'harga_modal': hargaModalController.text,
        'harga_eceran': hargaEceranController.text,
        'harga_grosir': hargaGrosirController.text,
        'satuan_barang': satuanController.text,
        'stok_besar_barang': stokBesarController.text,
        'jumlah_isi_barang': jumlahIsiController.text,
        'harga_eceran_besar': hargaEceranBesarController.text,
        'satuan_besar_barang': satuanBesarController.text,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Barang berhasil diupdate"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Gagal memperbarui barang: ${responseData['message']}"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memperbarui barang"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> hapusProduk() async {
    final String apiUrl = "http://shop.mzverse.my.id/api/hapus_data.php";

    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'id': widget.id.toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Barang berhasil dihapus"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menghapus barang: ${responseData['message']}"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menghapus barang"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Penghapusan"),
          content: Text("Apakah Anda yakin ingin menghapus barang ini?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                hapusProduk();
              },
              child: Text(
                "Hapus",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.blue,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Edit Barang',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: namaBarangController,
                    decoration: InputDecoration(
                      labelText: 'NAMA BARANG',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: barcodeController,
                    decoration: InputDecoration(
                      labelText: 'BARCODE',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: stokController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'STOK SATUAN',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: hargaEceranController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'HARGA SATUAN',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: satuanController,
                    decoration: InputDecoration(
                      labelText: 'SATUAN KECIL (PCS/METER/KG)',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Divider(),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: stokBesarController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'STOK BESAR (LUSIN/ROL/DUS)',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: jumlahIsiController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'JUMLAH ISI (LUSIN/ROL/DUS)',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide(
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: hargaEceranBesarController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'HARGA ECERAN BESAR',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: satuanBesarController,
                    decoration: InputDecoration(
                      labelText: 'SATUAN BESAR (LUSIN/ROL/DUS)',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Divider(),
                  SizedBox(height: 15),
                  TextField(
                    controller: hargaModalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'HARGA MODAL',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: hargaGrosirController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'HARGA GROSIR',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'HAPUS BARANG',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  updateProduk();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'EDIT BARANG',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
