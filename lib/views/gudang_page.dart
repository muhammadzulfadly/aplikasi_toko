import 'package:aplikasi_toko/views/histori_page.dart';
import 'package:flutter/material.dart';
import 'package:aplikasi_toko/views/edit_page.dart';
import 'package:aplikasi_toko/views/tambah_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart'; // Pastikan Anda telah menambahkan paket intl di pubspec.yaml

class Gudang extends StatefulWidget {
  @override
  _GudangState createState() => _GudangState();
}

class _GudangState extends State<Gudang> {
  List produkList = [];
  List filteredProdukList = [];
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  int? toggledProductId;
  final numberFormatter =
      NumberFormat('#,##0', 'id_ID'); // Formatter untuk harga

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    final response = await http.get(
        Uri.parse('http://shop.mzverse.my.id/api/view_data.php'));

    if (response.statusCode == 200) {
      setState(() {
        produkList = json.decode(response.body);
        filteredProdukList = produkList;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void searchProduk(String query) {
    final results = produkList.where((produk) {
      final namaLower = produk['nama_barang'].toLowerCase();
      final queryLower = query.toLowerCase();

      return namaLower.contains(queryLower);
    }).toList();

    setState(() {
      filteredProdukList = results;
      isSearching = query.isNotEmpty;
    });
  }

  void toggleRepeat(int id) {
    setState(() {
      if (toggledProductId == id) {
        toggledProductId = null;
      } else {
        toggledProductId = id;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 45,
                child: TextField(
                  controller: searchController,
                  onChanged: (query) {
                    searchProduk(query);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari Barang',
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoriPenjualan()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.history, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: filteredProdukList.isEmpty
                  ? Center(child: Text("Tidak ada barang ditemukan"))
                  : ListView.builder(
                      itemCount: filteredProdukList.length,
                      itemBuilder: (context, index) {
                        final produk = filteredProdukList[index];
                        final id = int.parse(produk['id']);
                        final isToggled = toggledProductId == id;
                        final harga = isToggled
                            ? produk['harga_eceran_besar']
                            : produk['harga_eceran'];
                        final stok = isToggled
                            ? produk['stok_besar_barang']
                            : produk['stok_barang'];
                        final satuan = isToggled
                            ? produk['satuan_besar_barang']
                            : produk['satuan_barang'];
                        return InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProduk(id: id),
                              ),
                            );
                            if (result == true) {
                              fetchProduk();
                            }
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produk['nama_barang'],
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Rp. ${numberFormatter.format(int.parse(harga))}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text('STOK : $stok'),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            toggleRepeat(id);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: CircleBorder(),
                                          ),
                                          child: Icon(Icons.repeat,
                                              color: Colors.blue),
                                        ),
                                      ),
                                      Text('$satuan')
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        height: 60.0,
        width: 60.0,
        child: FloatingActionButton(
          heroTag: 'tambah',
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TambahProduk()),
            );
            if (result == true) {
              fetchProduk();
            }
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
          backgroundColor: Colors.blue,
          shape: CircleBorder(),
        ),
      ),
    );
  }
}
