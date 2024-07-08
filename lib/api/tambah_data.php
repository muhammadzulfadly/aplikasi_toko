<?php

include("dbconnection.php");
$con = dbconnection();

$required_fields = [
    "nama_barang",
    "barcode_barang",
    "stok_barang",
    "harga_eceran",
    "satuan_barang",
    "stok_besar_barang",
    "jumlah_isi_barang",
    "harga_eceran_besar",
    "satuan_besar_barang",
    "harga_modal",
    "harga_grosir"
];

foreach ($required_fields as $field) {
    if (!isset($_POST[$field])) {
        $arr["success"] = "false";
        $arr["message"] = "$field is required";
        print(json_encode($arr));
        return;
    }
}

$nama_barang = $_POST["nama_barang"];
$barcode_barang = $_POST["barcode_barang"];
$stok_barang = $_POST["stok_barang"];
$harga_eceran = $_POST["harga_eceran"];
$satuan_barang = $_POST["satuan_barang"];
$stok_besar_barang = $_POST["stok_besar_barang"];
$jumlah_isi_barang = $_POST["jumlah_isi_barang"];
$harga_eceran_besar = $_POST["harga_eceran_besar"];
$satuan_besar_barang = $_POST["satuan_besar_barang"];
$harga_modal = $_POST["harga_modal"];
$harga_grosir = $_POST["harga_grosir"];

$query = "INSERT INTO `produks`(
    `nama_barang`, 
    `barcode_barang`, 
    `stok_barang`, 
    `harga_eceran`, 
    `satuan_barang`, 
    `stok_besar_barang`, 
    `jumlah_isi_barang`, 
    `harga_eceran_besar`, 
    `satuan_besar_barang`, 
    `harga_modal`, 
    `harga_grosir`
) VALUES (
    '$nama_barang',
    '$barcode_barang',
    '$stok_barang',
    '$harga_eceran',
    '$satuan_barang',
    '$stok_besar_barang',
    '$jumlah_isi_barang',
    '$harga_eceran_besar',
    '$satuan_besar_barang',
    '$harga_modal',
    '$harga_grosir'
)";

$exe = mysqli_query($con, $query);
$arr = [];

if ($exe) {
    $arr["success"] = "true";
} else {
    $arr["success"] = "false";
    $arr["message"] = "Error: " . mysqli_error($con);
}

print(json_encode($arr));
