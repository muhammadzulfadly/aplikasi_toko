<?php
include("dbconnection.php");
$con = dbconnection();

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $produk_id = $_POST['produk_id'];
    $jumlah = $_POST['jumlah'];
    $harga_jual = $_POST['harga_jual'];

    // Debugging output
    error_log("Produk_ID: $produk_id, Jumlah: $jumlah, Harga_jual: $harga_jual");

    if (!$con) {
        error_log("Koneksi ke database gagal: " . mysqli_connect_error());
        echo json_encode(array('success' => false, 'message' => 'Koneksi ke database gagal'));
        exit;
    }

    // Mendapatkan informasi produk dari database
    $produk_query = $con->prepare("SELECT * FROM produks WHERE id = ?");
    $produk_query->bind_param("i", $produk_id);
    $produk_query->execute();
    $produk_result = $produk_query->get_result();

    if ($produk_result->num_rows == 0) {
        error_log("Produk tidak ditemukan. Produk_ID: $produk_id");
        echo json_encode(array('success' => false, 'message' => 'Produk tidak ditemukan'));
        exit;
    }

    $produk = $produk_result->fetch_assoc();

    // Update stok berdasarkan harga_jual
    $stok_besar_barang = $produk['stok_besar_barang'];
    $stok_barang = $produk['stok_barang'];

    if ($harga_jual == $produk['harga_eceran']) {
        // Jika harga_jual sesuai dengan harga_eceran, kembalikan stok_barang
        $stok_barang += $jumlah;
    } elseif ($harga_jual == $produk['harga_eceran_besar']) {
        // Jika harga_jual sesuai dengan harga_eceran_besar, kembalikan stok_besar_barang
        $stok_besar_barang += $jumlah;
    } else {
        error_log("Harga jual tidak valid. Harga_jual: $harga_jual");
        echo json_encode(array('success' => false, 'message' => 'Harga jual tidak valid'));
        exit;
    }

    // Query untuk mengupdate stok
    $update_query = $con->prepare("UPDATE produks SET stok_barang = ?, stok_besar_barang = ? WHERE id = ?");
    $update_query->bind_param("iii", $stok_barang, $stok_besar_barang, $produk_id);
    $update_result = $update_query->execute();

    if ($update_result) {
        echo json_encode(array('success' => true, 'message' => 'Stok produk berhasil dikembalikan'));
    } else {
        error_log("Gagal mengembalikan stok produk. Error: " . $con->error);
        echo json_encode(array('success' => false, 'message' => 'Gagal mengembalikan stok produk'));
    }
} else {
    echo json_encode(array('success' => false, 'message' => 'Invalid request method'));
}
