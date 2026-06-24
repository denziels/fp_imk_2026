<?php
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (isset($data->child_id) && isset($data->profile_picture)) {
        $child_id = (int)$data->child_id;
        $profile_picture = $conn->real_escape_string($data->profile_picture);
        
        if ($conn->query("UPDATE children SET profile_picture = '$profile_picture' WHERE id = $child_id")) {
            echo json_encode(["status" => "success", "message" => "Profile picture updated successfully"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to update profile picture: " . $conn->error]);
        }
    } else {
        echo json_encode(["status" => "error", "message" => "Missing parameters"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Invalid request method"]);
}
?>
