<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Access-Control-Allow-Methods: GET, POST, DELETE, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = "localhost";
$user = "root";
$pass = "";
$db   = "db_readlexia";
$port = 3307;

try {
    $conn = new mysqli($host, $user, $pass, $db, $port);
    if ($conn->connect_error) {
        die(json_encode(["status" => "error", "message" => "Database connection failed: " . $conn->connect_error]));
    }
} catch (Exception $e) {
    die(json_encode(["status" => "error", "message" => "Database exception: " . $e->getMessage()]));
}
?>