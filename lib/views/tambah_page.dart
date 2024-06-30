import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahProduk extends StatelessWidget {
  final TextEditingController namaBarangController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final TextEditingController hargaModalController = TextEditingController();
  final TextEditingController hargaEceranController = TextEditingController();
  final TextEditingController hargaGrosirController = TextEditingController();

  Future<void> tambahBarang(BuildContext context) async {
    final String apiUrl = "http://shop.mzverse.my.id/api/tambah_data.php";
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "nama_barang": namaBarangController.text,
        "barcode_barang": barcodeController.text,
        "stok_barang": stokController.text,
        "harga_modal": hargaModalController.text,
        "harga_eceran": hargaEceranController.text,
        "harga_grosir": hargaGrosirController.text,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData["success"] == "true") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Barang berhasil ditambahkan"),
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
            content: Text("Barang gagal ditambahkan"),
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
          content: Text("Barang gagal ditambahkan"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
          backgroundColor: Colors.red,
        ),
      );
    }
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
          'Tambah Barang',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
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
                labelText: 'STOK',
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
              controller: hargaEceranController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'HARGA ECERAN',
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
        child: ElevatedButton(
          onPressed: () {
            tambahBarang(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child: Text(
            'TAMBAH BARANG',
            style: TextStyle(color: Colors.white),
          ),
        ),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
