# Jarvis - Soapbox radio repository 

## The Jarvis liquidsoap scripts and PHP helper files

```
config.inc.php sample 

define('SHOUTCAST_HOST', 'http://host:port');          // url:port to your shoutcast server
define('SHOUTCAST_ADMIN_PASS', 'password');                     // admin password for accessing admin.cgi
define('SCROBBLER_API', 'scrobblerapi');    // API key from lastfm to query data
define('APPLICATION_NAME', 'Hawkwynd Radio');                   // Name of your website's application
define('NOW_PLAYING_TXT', 'Now Playing');                       // Content to display as Now Playing
define('SITE_URL', 'http://stream.hawkwynd.com');               // used in FB share link
define('MB_URL', '');                                           // not sure what this is for.
define('IPINFO_TOKEN', 'infotoken');					    // ipinfo token (future use)
define('SHOUTCAST_DEV_API', 'apikey');                // Shoutcast Directory API key (future possible use)

// Mysql credentials -- requires local MYSQL server
define('MYSQL_USER', 'root');
define('MYSQL_USER_PASSWORD', 'password');
define('MYSQL_DATABASE', 'keep');
define('MYSQL_HOST', 'localhost');
```
