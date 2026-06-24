CREATE DATABASE IF NOT EXISTS db_readlexia;
USE db_readlexia;

CREATE TABLE IF NOT EXISTS parents (
  id INT AUTO_INCREMENT PRIMARY KEY,
  google_id VARCHAR(255) UNIQUE,
  email VARCHAR(255),
  name VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS children (
  id INT AUTO_INCREMENT PRIMARY KEY,
  parent_id INT,
  name VARCHAR(255),
  age INT,
  profile_picture LONGTEXT,
  FOREIGN KEY (parent_id) REFERENCES parents(id)
);

CREATE TABLE IF NOT EXISTS progress (
  id INT AUTO_INCREMENT PRIMARY KEY,
  child_id INT,
  game_id VARCHAR(50),
  unlocked_level INT DEFAULT 1,
  FOREIGN KEY (child_id) REFERENCES children(id),
  UNIQUE KEY unique_progress (child_id, game_id)
);

CREATE TABLE IF NOT EXISTS stats (
  id INT AUTO_INCREMENT PRIMARY KEY,
  child_id INT,
  game_id VARCHAR(50),
  game_name VARCHAR(100),
  level INT,
  is_success TINYINT(1),
  details TEXT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (child_id) REFERENCES children(id)
);
