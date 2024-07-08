import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoriPenjualan extends StatefulWidget {
  @override
  _HistoriPenjualanState createState() => _HistoriPenjualanState();
}

class _HistoriPenjualanState extends State<HistoriPenjualan> {
  List historiList = [];

  @override
  void initState() {
    super.initState();
    fetchHistori();
  }

  Future<void> fetchHistori() async {
    final response = await http.get(Uri.parse(
        'http://shop.mzverse.my.id/api/histori_penjualan.php'));

    if (response.statusCode == 200) {
      setState(() {
        historiList = json.decode(response.body);
      });
    } else {
      print("Failed to fetch data");
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
          'Histori Penjualan',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: historiList.isEmpty
          ? Text('Tidak ada penjualan')
          : ListView.builder(
              itemCount: historiList.length,
              itemBuilder: (context, index) {
                final histori = historiList[index];
                return ListTile(
                  title: Text(histori['nama_barang']),
                  subtitle: Text(
                      '${histori['jumlah']} x Rp. ${histori['harga_jual']}'),
                  trailing: Text(histori['tanggal_penjualan']),
                );
              },
            ),
    );
  }
}
