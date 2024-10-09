<?php
// Prüfe, ob die notwendigen GET-Parameter gesetzt sind
if (!isset($_GET['url'])) {
    die('URL-Parameter fehlt.');
}

if (!isset($_GET['size'])) {
    $size = 4; // Standardgröße
} else {
    $size = intval($_GET['size']);
}

// Hole die URL aus den GET-Parametern
$url = $_GET['url'];

// Lade die phpqrcode-Bibliothek
require_once 'phpqrcode/qrlib.php';

// Setze den Content-Type auf image/png
header('Content-Type: image/png');

// Generiere den QR-Code und gebe ihn direkt aus
QRcode::png($url, false, QR_ECLEVEL_L, $size, 2);
?>
