import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'dart:convert';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:html' as html;

class Keranjang extends StatefulWidget {
  @override
  _KeranjangState createState() => _KeranjangState();
}

class _KeranjangState extends State<Keranjang> {
  late Box keranjangBox;
  List<Map<String, dynamic>> keranjangList = [];
  double totalHarga = 0;
  List<TextEditingController> controllers = [];
  final numberFormatter =
      NumberFormat('#,##0.##', 'id_ID'); // Formatter untuk harga

  @override
  void initState() {
    super.initState();
    keranjangBox = Hive.box('keranjang');
    fetchKeranjang();
  }

  Future<void> fetchKeranjang() async {
    final data = keranjangBox.values.toList();
    setState(() {
      keranjangList =
          data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      controllers = List.generate(keranjangList.length, (index) {
        return TextEditingController(text: keranjangList[index]['jumlah']);
      });
      hitungTotal();
    });
  }

  void hitungTotal() {
    double totalHargaBarang = 0;
    for (var produk in keranjangList) {
      totalHargaBarang +=
          double.parse(produk['harga_eceran']) * double.parse(produk['jumlah']);
    }
    setState(() {
      totalHarga = totalHargaBarang;
    });
  }

  Future<void> deleteProduk(int index) async {
    await keranjangBox.deleteAt(index);
    fetchKeranjang();
  }

  Future<void> jualBarang() async {
    bool success = true;
    for (var produk in keranjangList) {
      if (produk['id'] == null) {
        print("Produk tidak memiliki ID: $produk");
        continue;
      }

      String stok = produk['stok_barang'] ?? '0';
      String jumlah = produk['jumlah'] ?? '0';
      double currentStok = double.parse(stok);
      double jumlahJual = double.parse(jumlah);
      double newStok = currentStok - jumlahJual;

      if (newStok < 0) {
        print("Stok tidak cukup untuk produk: ${produk['nama_barang']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Stok tidak cukup untuk ${produk['nama_barang']}"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.red,
          ),
        );
        continue;
      }

      print("ID: ${produk['id']}, New Stok: $newStok");

      var response = await http.post(
        Uri.parse('http://shop.mzverse.my.id/api/stok_data.php'),
        body: {
          'id': produk['id'].toString(),
          'stok_barang': newStok.toString(),
          'jumlah': jumlahJual.toString(),
        },
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (response.statusCode == 200) {
        try {
          var responseData = json.decode(response.body);
          print("Response from API: $responseData");

          if (responseData['success'] != 'true') {
            success = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Gagal menjual ${produk['nama_barang']}"),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
                backgroundColor: Colors.red,
              ),
            );
            break;
          }
        } catch (e) {
          success = false;
          print("Error parsing JSON: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Gagal menjual ${produk['nama_barang']}, error parsing JSON"),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
              backgroundColor: Colors.red,
            ),
          );
          break;
        }
      } else {
        success = false;
        print("Server error: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Gagal menjual ${produk['nama_barang']}, server error"),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
            backgroundColor: Colors.red,
          ),
        );
        break;
      }
    }
    if (success) {
      _showPrintDialog();
    }
  }

  void _showPrintDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Print Struk"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      keranjangBox.clear();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text("Home", style: TextStyle(color: Colors.blue)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      generateAndDownloadPDF();
                      keranjangBox.clear();
                      fetchKeranjang();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Print",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

  Future<void> generateAndDownloadPDF() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy');
    final String formattedDate = formatter.format(now);
    final numberFormatter =
        NumberFormat('#,##0.##', 'id_ID'); // Formatter untuk harga

    // Menghitung tinggi kertas berdasarkan jumlah item di keranjang
    final double itemHeight = 25.0; // Tinggi setiap item dalam milimeter
    final double headerFooterHeight =
        30.0; // Tinggi header dan footer dalam milimeter
    final double contentHeight = keranjangList.length *
        itemHeight; // Tinggi konten berdasarkan jumlah item
    final double pageHeight = headerFooterHeight +
        contentHeight; // Tinggi total halaman dalam milimeter

    // Konversi ukuran dari milimeter ke points
    final double pageWidthPoints = 58 * 2.83465; // 1 mm = 2.83465 points
    final double pageHeightPoints = pageHeight * 2.83465;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          pageWidthPoints,
          pageHeightPoints,
          marginAll: 3 * 2.83465, // Mengatur margin 5 mm dalam points
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Column(
                  children: [
                    pw.Center(
                      child: pw.Text(
                        "CAHAYA LOWA",
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Center(
                      child: pw.Text(
                        "$formattedDate",
                        style: pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.ListView.builder(
                  itemCount: keranjangList.length,
                  itemBuilder: (context, index) {
                    final produk = keranjangList[index];
                    final double totalHargaProduk =
                        double.parse(produk['jumlah']) *
                            double.parse(produk['harga_eceran']);
                    final String jumlahDanHarga =
                        "${produk['jumlah']} x Rp. ${numberFormatter.format(double.parse(produk['harga_eceran']))}";
                    final double jumlahDanHargaFontSize =
                        jumlahDanHarga.length > 20 ? 7 : 9;
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    produk['nama_barang'],
                                    style: pw.TextStyle(fontSize: 10),
                                    overflow: pw.TextOverflow.clip,
                                  ),
                                  pw.Text(
                                    jumlahDanHarga,
                                    style: pw.TextStyle(
                                        fontSize: jumlahDanHargaFontSize),
                                  ),
                                ],
                              ),
                            ),
                            pw.Container(
                              alignment: pw.Alignment.centerRight,
                              width: pageWidthPoints / 2 -
                                  10, // Mengatur lebar maksimum untuk total_harga
                              child: pw.Text(
                                'Rp. ${numberFormatter.format(totalHargaProduk)}',
                                style: pw.TextStyle(
                                    fontSize:
                                        totalHargaProduk.toString().length > 10
                                            ? 8
                                            : 10),
                                textAlign: pw.TextAlign.right,
                                overflow: pw.TextOverflow.clip,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 5),
                      ],
                    );
                  },
                ),
              ),
              pw.Divider(),
              pw.Footer(
                title: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "TOTAL : ",
                      style: pw.TextStyle(
                          fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      "Rp. ${numberFormatter.format(totalHarga)}",
                      style: pw.TextStyle(
                          fontSize: totalHarga.toString().length > 10 ? 9 : 11,
                          fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    try {
      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'struk_penjualan.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print("Error generating or downloading PDF: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mencetak PDF: $e"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 20.0, right: 200.0),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> addToKeranjang(Map<String, dynamic> produk) async {
    if (produk['id'] == null) {
      print("Produk tidak memiliki ID: $produk");
      return; // Skip adding product if ID is null
    }

    produk['jumlah'] = '1';
    await keranjangBox.add(produk);
    fetchKeranjang();
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
          'Keranjang',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: keranjangList.isEmpty
            ? Center(child: Text("Keranjang kosong"))
            : ListView.builder(
                itemCount: keranjangList.length,
                itemBuilder: (context, index) {
                  final produk = keranjangList[index];
                  final controller = controllers[index];

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Wrap(
                                  children: [
                                    Text(
                                      produk['nama_barang'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.clip,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  deleteProduk(index);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            'RP. ${numberFormatter.format(double.parse(produk['harga_eceran']))}',
                            style: TextStyle(fontSize: 18),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    double currentValue =
                                        double.parse(controller.text);
                                    if (currentValue > 0.5) {
                                      currentValue -= 0.5;
                                      controller.text = currentValue.toString();
                                      produk['jumlah'] =
                                          currentValue.toString();
                                      keranjangBox.putAt(index, produk);
                                      hitungTotal();
                                    }
                                  });
                                },
                                icon: Icon(Icons.remove),
                                color: Colors.blue,
                              ),
                              Container(
                                width: 50,
                                child: TextField(
                                  controller: controller,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 5),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value.isEmpty) {
                                        produk['jumlah'] = '0';
                                      } else {
                                        double newValue = double.parse(value);
                                        if (newValue < 0.5) {
                                          produk['jumlah'] = '0.5';
                                        } else {
                                          produk['jumlah'] =
                                              newValue.toString();
                                        }
                                      }
                                      keranjangBox.putAt(index, produk);
                                      hitungTotal();
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    double currentValue =
                                        double.parse(controller.text);
                                    currentValue += 0.5;
                                    controller.text = currentValue.toString();
                                    produk['jumlah'] = currentValue.toString();
                                    keranjangBox.putAt(index, produk);
                                    hitungTotal();
                                  });
                                },
                                icon: Icon(Icons.add),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Text(
                      'Rp. ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '${numberFormatter.format(totalHarga)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  if (keranjangList.isNotEmpty) {
                    jualBarang();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Keranjang kosong"),
                        duration: Duration(seconds: 1),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  minimumSize: Size(150, 50), // Button size
                ),
                child: Text(
                  'JUAL',
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
