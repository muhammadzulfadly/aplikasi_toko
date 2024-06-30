<?php
function dbconnection()
{
    $con = mysqli_connect("localhost", "u885503629_cahayalowa", "@Kidssuper6", "u885503629_aplikasi_toko");
    return $con;
}
