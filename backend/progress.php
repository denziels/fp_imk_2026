<?php
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (isset($_GET['child_id'])) {
        $child_id = (int)$_GET['child_id'];
        $result = $conn->query("SELECT game_id, unlocked_level FROM progress WHERE child_id = $child_id");
        
        $progress = [];
        while ($row = $result->fetch_assoc()) {
            $progress[$row['game_id']] = (int)$row['unlocked_level'];
        }
        echo json_encode(["status" => "success", "data" => $progress]);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (isset($data->child_id) && isset($data->game_id) && isset($data->level)) {
        $child_id = (int)$data->child_id;
        $game_id = $conn->real_escape_string($data->game_id);
        $level = (int)$data->level;
        
        // Insert or update
        $sql = "INSERT INTO progress (child_id, game_id, unlocked_level) 
                VALUES ($child_id, '$game_id', $level) 
                ON DUPLICATE KEY UPDATE unlocked_level = GREATEST(unlocked_level, $level)";
                
        if ($conn->query($sql)) {
            echo json_encode(["status" => "success"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to save progress"]);
        }
    }
}
?>
