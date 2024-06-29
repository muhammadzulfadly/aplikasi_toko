<?php

include("dbconnection.php");
$con = dbconnection();

if (isset($_POST["nama_barang"])) {
    $nama_barang = $_POST["nama_barang"];
} else return;
if (isset($_POST["barcode_barang"])) {
    $barcode_barang = $_POST["barcode_barang"];
} else return;
if (isset($_POST["stok_barang"])) {
    $stok_barang = $_POST["stok_barang"];
} else return;
if (isset($_POST["harga_modal"])) {
    $harga_modal = $_POST["harga_modal"];
} else return;
if (isset($_POST["harga_eceran"])) {
    $harga_eceran = $_POST["harga_eceran"];
} else return;
if (isset($_POST["harga_grosir"])) {
    $harga_grosir = $_POST["harga_grosir"];
} else return;

$query = "INSERT INTO `produks`(`nama_barang`, `barcode_barang`, `stok_barang`, `harga_modal`, `harga_eceran`, `harga_grosir`) 
          VALUES ('$nama_barang','$barcode_barang','$stok_barang','$harga_modal','$harga_eceran','$harga_grosir')";
$exe = mysqli_query($con, $query);
$arr = [];

if ($exe) {
    $arr["success"] = "true";
} else {
    $arr["success"] = "false";
}

print(json_encode($arr));
