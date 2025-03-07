<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json");

include 'db_config.php';

if ($_SERVER["REQUEST_METHOD"] === "OPTIONS") {
    http_response_code(200);
    exit();
}

$action = isset($_POST['action']) ? $_POST['action'] : '';

if ($action === 'login') {
    $email = $_POST['email'];
    $password = $_POST['password'];

    $query = "SELECT * FROM users WHERE email=? OR uname=?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ss", $email, $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        $hashedPassword = $row['password'];
        if (password_verify($password, $hashedPassword)) {
            echo json_encode(["status" => "success", "message" => "Login successful"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Password is incorrect"]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "User not found"]);
    }
    
    $stmt->close();
} elseif ($action === 'register') {
    $uname = trim($_POST['uname']);
    $email = trim($_POST['email']);
    $password = $_POST['password'];

    if (empty($uname) || empty($email) || empty($password)) {
        echo json_encode(["success" => false, "message" => "All fields are required", "error_field" => "general"]);
        exit();
    }

    $checkQuery = "SELECT * FROM users WHERE uname = ? OR email = ?";
    $stmt = $conn->prepare($checkQuery);
    $stmt->bind_param("ss", $uname, $email);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($row = $result->fetch_assoc()) {
        if ($row['uname'] === $uname) {
            echo json_encode(["success" => false, "message" => "Username already exists", "error_field" => "uname"]);
        } else {
            echo json_encode(["success" => false, "message" => "Email already exists", "error_field" => "email"]);
        }
        exit();
    }

    if (strlen($password) < 6 || !preg_match("/[A-Za-z]/", $password) || !preg_match("/\d/", $password)) {
        echo json_encode(["success" => false, "message" => "Password must be at least 6 characters long and include both letters and numbers", "error_field" => "password"]);
        exit();
    }

    $hashedPassword = password_hash($password, PASSWORD_DEFAULT);
    $sql = "INSERT INTO users (uname, email, password) VALUES (?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sss", $uname, $email, $hashedPassword);

    if ($stmt->execute()) {
        echo json_encode(["success" => true, "message" => "User registered!"]);
    } else {
        echo json_encode(["success" => false, "message" => "Error: " . $conn->error]);
    }
    
    $stmt->close();
}

$conn->close();
?>
