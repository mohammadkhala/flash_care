<?php

/**
 * Laravel - PHP built-in server router
 * Allows running the app with: php artisan serve
 */

$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? ''
);

// Serve static files directly from /public
if ($uri !== '/' && file_exists(__DIR__.'/public'.$uri)) {
    return false;
}

$_SERVER['SCRIPT_FILENAME'] = __DIR__.'/public/index.php';

require_once __DIR__.'/public/index.php';
