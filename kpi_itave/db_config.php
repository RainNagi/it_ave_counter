<?php
$host = "localhost";
$user = "root"; // Default XAMPP user
$password = "";
$database = "kpi_db";

$conn = new mysqli($host, $user, $password, $database);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
