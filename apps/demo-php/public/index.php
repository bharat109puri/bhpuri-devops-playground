<?php
declare(strict_types=1);

header('Content-Type: application/json');
if ($_SERVER['REQUEST_URI'] === '/healthz') {
    echo json_encode(['status' => 'healthy']);
    exit;
}
echo json_encode(['service' => 'demo-php', 'status' => 'ok']);
