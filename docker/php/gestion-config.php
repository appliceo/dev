<?
// Docker configuration file for Appliceo
// Copy this to config.php or config.local.php when running in Docker
// Nom de la base de données MySQL
define('DATABASE_NAME', 'appliceo_php');

// Utilisateur de la base de données MySQL
define('DATABASE_USER_NAME', 'appliceo');

// Mot de passe de la base de données MySQL
define('DATABASE_PASSWORD', 'appliceo123');

// Adresse du serveur de base de données MySQL
define('DATABASE_HOST_NAME', 'mysql');

// Jeu de caractères à utiliser par la base de données MySQL
define('DATABASE_CHARSET', 'utf8');

// Préfixe pour les tables de la base de données MySQL
define('DB_PREFIX', 'ap_');

// Chemin absolu du site
define('ABS_PATH_SITE', '/var/www/html');

// Chemin absolu du backoffice
define('ABS_PATH', '/var/www/html/gestion');

// Domaine
define('DOMAIN', 'localhost');

// Sous-domaine
define('SUBDOMAIN', '');

// Port (for Docker)
define('PORT', '8443');

// Protocol
define('PROTOCOL', 'https://');

// Absolute URLs
define('ABS_URL', 'https://localhost:8443/gestion');
define('ABS_URL_SITE', 'https://localhost:8443');

// Nom de l'application
define('APP_NAME', 'Appliceo');

// Version de l'application
define('APP_VERSION', '1.0.0');

// Security settings
define('MAX_CONN_ATTEMPTS', 5);
define('BLOCKED_IP_DURATION', 30);
define('RECOVERY_LINK_DURATION', 10);

// Email settings for Docker environment
define('SMTP_HOST', 'mailhog');  // You can add MailHog for email testing
define('SMTP_PORT', 1025);
define('SMTP_USER', '');
define('SMTP_PASS', '');
define('SMTP_SECURE', '');

// Environment detection
// Can be: 'development', 'staging', or 'production'
// If not manually set, will auto-detect based on HTTP_HOST
if (!defined('ENVIRONMENT')) {
	$host = isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : '';
	if ($host === 'localhost' || $host === 'localhost:8443' || strpos($host, 'localhost') !== false || strpos($host, '127.0.0.1') !== false || strpos($host, 'dev.appliceo.com') !== false) {
		define('ENVIRONMENT', 'development');
	} elseif (strpos($host, 'staging') !== false || strpos($host, 'stg.') !== false) {
		define('ENVIRONMENT', 'staging');
	} else {
		define('ENVIRONMENT', 'production');
	}
}

// Debug mode - automatically set based on environment
// Can be manually overridden by defining DEBUG_MODE before this file
if (!defined('DEBUG_MODE')) {
	define('DEBUG_MODE', ENVIRONMENT !== 'production');
}
if (!defined('DISPLAY_ERRORS')) {
	define('DISPLAY_ERRORS', ENVIRONMENT !== 'production');
}

// File upload settings
define('MAX_FILE_SIZE', 67108864); // 64MB
define('UPLOAD_PATH', '/var/www/html/gestion/uploads/');

// Log settings
define('LOG_PATH', '/var/www/html/gestion/logs/');
define('ERROR_LOG', '/var/www/html/gestion/logs/error.log');

// Guarantor settings
define('MAX_GUARANTORS_PER_LEASE', 4);

// Development auto-login settings
// WARNING: Only use in development! Never enable in production!
// When enabled, automatically logs in the specified user without authentication
define('DEV_AUTO_LOGIN', true);  // Set to false to disable auto-login
define('DEV_AUTO_LOGIN_USER_ID', 347);  // User ID to automatically log in as
?>
