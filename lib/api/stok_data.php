<?php
include("dbconnection.php");
$con = dbconnection();

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $id = $_POST['id'];
    $jumlah = $_POST['jumlah'];
    $satuan = $_POST['satuan'];

    // Debugging output
    error_log("ID: $id, Jumlah: $jumlah, Satuan: $satuan");

    if (!$con) {
        error_log("Koneksi ke database gagal: " . mysqli_connect_error());
        echo json_encode(array('success' => 'false', 'error' => 'Koneksi ke database gagal'));
        exit;
    }

    // Mendapatkan stok barang dari database
    $produk_query = "SELECT * FROM produks WHERE id = '$id'";
    $produk_result = mysqli_query($con, $produk_query);
    $produk = mysqli_fetch_assoc($produk_result);

    if (!$produk) {
        error_log("Produk tidak ditemukan.");
        echo json_encode(array('success' => 'false', 'error' => 'Produk tidak ditemukan'));
        exit;
    }

    // Menghitung stok baru berdasarkan satuan
    $stok_besar_barang = $produk['stok_besar_barang'];
    $stok_barang = $produk['stok_barang'];

    if ($satuan == $produk['satuan_barang']) {
        // Jika satuan kecil
        $stok_barang = $produk['stok_barang'] - $jumlah;
    } elseif ($satuan == $produk['satuan_besar_barang']) {
        // Jika satuan besar
        $stok_besar_barang = $produk['stok_besar_barang'] - $jumlah;
    } else {
        error_log("Satuan tidak valid.");
        echo json_encode(array('success' => 'false', 'error' => 'Satuan tidak valid'));
        exit;
    }

    // Query untuk mengupdate stok
    $query = "UPDATE produks SET stok_barang = '$stok_barang', stok_besar_barang = '$stok_besar_barang' WHERE id = '$id'";
    error_log("Query: $query");

    $result = mysqli_query($con, $query);

    if ($result) {
        if (mysqli_affected_rows($con) > 0) {
            // Menambahkan histori penjualan
            $nama_barang = $produk['nama_barang'];
            $harga_jual = ($satuan == $produk['satuan_besar_barang']) ? $produk['harga_eceran_besar'] : $produk['harga_eceran'];
            $total_harga = $harga_jual * $jumlah;

            $histori_query = "INSERT INTO histori_penjualan (produk_id, nama_barang, harga_jual, jumlah, total_harga) 
                              VALUES ('$id', '$nama_barang', '$harga_jual', '$jumlah', '$total_harga')";
            mysqli_query($con, $histori_query);

            echo json_encode(array('success' => 'true'));
        } else {
            error_log("Query berhasil, tetapi tidak ada baris yang diupdate.");
            echo json_encode(array('success' => 'false', 'error' => 'Tidak ada baris yang diupdate'));
        }
    } else {
        $error_message = mysqli_error($con);
        error_log("Query Error: " . $error_message);
        echo json_encode(array('success' => 'false', 'error' => $error_message));
    }
} else {
    echo json_encode(array('success' => 'false', 'message' => 'Invalid request method'));
}
