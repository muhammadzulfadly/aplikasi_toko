import 'package:aplikasi_toko/views/histori_page.dart';
import 'package:aplikasi_toko/views/keranjang_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class Penjualan extends StatefulWidget {
  final String? barcode;

  const Penjualan({Key? key, this.barcode}) : super(key: key);

  @override
  _PenjualanState createState() => _PenjualanState();
}

class _PenjualanState extends State<Penjualan> {
  final TextEditingController searchController = TextEditingController();
  List produkList = [];
  bool isSearching = false;
  late Box keranjangBox;
  int? toggledProductId;
  final numberFormatter =
      NumberFormat('#,##0', 'id_ID'); // Formatter untuk harga

  @override
  void initState() {
    super.initState();
    keranjangBox = Hive.box('keranjang');
    if (widget.barcode != null) {
      searchByBarcode(widget.barcode!);
    }
  }

  @override
  void didUpdateWidget(Penjualan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.barcode != null && widget.barcode != oldWidget.barcode) {
      searchByBarcode(widget.barcode!);
    }
  }

  Future<void> searchProduk(String query) async {
    if (query.isEmpty) {
      setState(() {
        produkList = [];
        isSearching = false;
      });
      return;
    }

    final String apiUrl = "http://shop.mzverse.my.id/api/search_data.php";
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'query': query,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        produkList = json.decode(response.body);
        isSearching = true;
      });
    } else {
      print("Failed to fetch data");
    }
  }

  Future<void> searchByBarcode(String barcode) async {
    //final String apiUrl = "http://shop.mzverse.my.id/api/search_barcode.php";
    final String apiUrl =
        "http://192.168.1.12/aplikasi_toko/lib/api/search_barcode.php";
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'barcode': barcode,
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        produkList = json.decode(response.body);
        isSearching = true;
      });
    } else {
      print("Failed to fetch data");
    }
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

  Future<void> addToKeranjang(
      BuildContext context, Map<String, dynamic> produk) async {
    if (double.parse(produk['stok_barang']) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Barang habis"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      bool alreadyInCart = keranjangBox.values.any((item) {
        Map<String, dynamic> mapItem = Map<String, dynamic>.from(item as Map);
        return mapItem['id'] == produk['id'];
      });

      if (alreadyInCart) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Barang sudah ada di keranjang"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        keranjangBox.add({
          'id': produk['id'],
          'nama_barang': produk['nama_barang'],
          'barcode_barang': produk['barcode_barang'],
          'stok_barang': produk['stok_barang'],
          'harga_modal': produk['harga_modal'],
          'harga_eceran': produk['harga_eceran'],
          'harga_grosir': produk['harga_grosir'],
          'satuan_barang': produk['satuan_barang'],
          'stok_besar_barang': produk['stok_besar_barang'],
          'jumlah_isi_barang': produk['jumlah_isi_barang'],
          'harga_eceran_besar': produk['harga_eceran_besar'],
          'satuan_besar_barang': produk['satuan_besar_barang'],
          'jumlah': '1',
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ditambahkan ke keranjang"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.grey,
          ),
        );
        setState(() {
          searchController.clear();
          produkList = [];
          isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.white),
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
        child: isSearching
            ? produkList.isEmpty
                ? Center(child: Text("Tidak ada barang ditemukan"))
                : ListView.builder(
                    itemCount: produkList.length,
                    itemBuilder: (context, index) {
                      final produk = produkList[index];
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
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                produk['nama_barang'],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Rp. ${numberFormatter.format(int.parse(harga))}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text('STOK : $stok'),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
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
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        addToKeranjang(context, produk);
                                      },
                                      child: Text(
                                        'JUAL',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
            : Center(child: Text("Silahkan pilih barang")),
      ),
      floatingActionButton: Container(
        height: 60.0,
        width: 60.0,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Keranjang()),
            );
          },
          child: Icon(
            Icons.shopping_cart,
            color: Colors.white,
          ),
          backgroundColor: Color.fromARGB(255, 248, 89, 78),
          shape: CircleBorder(),
        ),
      ),
    );
  }
}
