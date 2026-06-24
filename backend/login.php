<?php
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"));

    if (isset($data->google_id) && isset($data->email) && isset($data->name)) {
        $google_id = $conn->real_escape_string($data->google_id);
        $email = $conn->real_escape_string($data->email);
        $name = $conn->real_escape_string($data->name);

        // Check if parent exists
        $result = $conn->query("SELECT * FROM parents WHERE google_id = '$google_id'");
        
        if ($result && $result->num_rows > 0) {
            $parent = $result->fetch_assoc();
            echo json_encode(["status" => "success", "parent_id" => $parent['id'], "name" => $parent['name']]);
        } elseif ($result) {
            // Insert new parent
            if ($conn->query("INSERT INTO parents (google_id, email, name) VALUES ('$google_id', '$email', '$name')")) {
                echo json_encode(["status" => "success", "parent_id" => $conn->insert_id, "name" => $name]);
            } else {
                echo json_encode(["status" => "error", "message" => "Failed to insert parent"]);
            }
        } else {
            echo json_encode(["status" => "error", "message" => "Database error: " . $conn->error]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Missing parameters"]);
    }
}
?>
