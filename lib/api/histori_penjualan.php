<?php
include("dbconnection.php");
$con = dbconnection();

header('Content-Type: application/json');

$query = "SELECT * FROM histori_penjualan ORDER BY tanggal_penjualan DESC";
$result = mysqli_query($con, $query);

$historiList = array();
while($row = mysqli_fetch_assoc($result)) {
    $historiList[] = $row;
}

echo json_encode($historiList);
