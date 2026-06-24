<?php
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (isset($_GET['child_id'])) {
        $child_id = (int)$_GET['child_id'];
        $result = $conn->query("SELECT * FROM stats WHERE child_id = $child_id ORDER BY timestamp ASC");
        
        $stats = [];
        while ($row = $result->fetch_assoc()) {
            $row['isSuccess'] = $row['is_success'] == 1; // convert to boolean for flutter
            $row['gameName'] = $row['game_name'];
            $row['gameId'] = $row['game_id'];
            $stats[] = $row;
        }
        echo json_encode(["status" => "success", "data" => $stats]);
    }
} elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"));
    
    if (isset($data->child_id) && isset($data->game_id) && isset($data->level) && isset($data->is_success)) {
        $child_id = (int)$data->child_id;
        $game_id = $conn->real_escape_string($data->game_id);
        $game_name = $conn->real_escape_string($data->game_name);
        $level = (int)$data->level;
        $is_success = $data->is_success ? 1 : 0;
        $details = $conn->real_escape_string($data->details);
        
        $sql = "INSERT INTO stats (child_id, game_id, game_name, level, is_success, details) 
                VALUES ($child_id, '$game_id', '$game_name', $level, $is_success, '$details')";
                
        if ($conn->query($sql)) {
            echo json_encode(["status" => "success"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Failed to save stat"]);
        }
    }
}
?>
