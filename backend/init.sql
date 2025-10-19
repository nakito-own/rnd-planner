CREATE DATABASE IF NOT EXISTS rnd_planner CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE rnd_planner;

CREATE USER IF NOT EXISTS 'rnd_user'@'%' IDENTIFIED BY 'rnd_password';
GRANT ALL PRIVILEGES ON rnd_planner.* TO 'rnd_user'@'%';
FLUSH PRIVILEGES;

SELECT 'R&D Planner database initialized successfully!' as status;
