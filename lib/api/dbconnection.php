<?php
function dbconnection()
{
    $con = mysqli_connect("localhost", "root", "", "aplikasi_toko");
    return $con;
}
