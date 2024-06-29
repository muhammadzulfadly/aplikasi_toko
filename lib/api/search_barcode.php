<?php

include("dbconnection.php");
$con = dbconnection();

if (isset($_POST['barcode'])) {
    $barcode = $_POST['barcode'];
    $searchQuery = "SELECT id, nama_barang, barcode_barang, stok_barang, harga_modal, harga_eceran, harga_grosir, created_at, updated_at 
                    FROM produks 
                    WHERE barcode_barang = '$barcode'";
    $exe = mysqli_query($con, $searchQuery);

    $arr = [];
    while ($row = mysqli_fetch_assoc($exe)) {
        $arr[] = $row;
    }

    print(json_encode($arr));
} else {
    print(json_encode([]));
}
