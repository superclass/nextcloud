#!/bin/bash

echo "Configuring Nextcloud"

cat > /var/www/nextcloud/config/config.php << EOF
<?php
\$CONFIG = array (
  'instanceid' => '${NEXTCLOUD_instanceid}',
  'passwordsalt' => '${NEXTCLOUD_passwordsalt}',
  'secret' => '${NEXTCLOUD_secret}',
  'trusted_domains' => 
  array (
    0 => '${NEXTCLOUD_trusted_domains}',
  ),
  'datadirectory' => '${NEXTCLOUD_datadirectory}',
  'overwrite.cli.url' => 'https://${NEXTCLOUD_trusted_domains}/nextcloud',
  'dbtype' => '${NEXTCLOUD_dbtype}',
  'version' => '${NEXTCLOUD_VERSION}',
  'dbname' => '${NEXTCLOUD_dbname}',
  'dbhost' => '${NEXTCLOUD_dbhost}',
  'dbtableprefix' => '${NEXTCLOUD_dbtableprefix}',
  'dbuser' => '${NEXTCLOUD_dbuser}',
  'dbpassword' => '${NEXTCLOUD_dbpassword}',
  'installed' => ${NEXTCLOUD_installed},
  'forcessl' => ${NEXTCLOUD_forcessl},
  'default_language' => '${NEXTCLOUD_default_language}',
  'theme' => '',
  'maintenance' => ${NEXTCLOUD_maintenance},
  'memcache.local' => '${NEXTCLOUD_memcache_local}',
  'loglevel' => ${NEXTCLOUD_loglevel},
  'log_type' => '${NEXTCLOUD_log_type}',
  'logfile' => '/var/log/nextcloud/nextcloud.log',
  'logtimezone' => '${NEXTCLOUD_logtimezone}',
  'trashbin_retention_obligation' => '${NEXTCLOUD_trashbin_retention_obligation}',
  'updater.release.channel' => '${NEXTCLOUD_updater_release_channel}',
  'updater.secret' => '${NEXTCLOUD_updater_secret}',
  'mysql.utf8mb4' => true,
  'filelocking.enabled' => false,
  'trusted_proxies'   => ['sslproxy'],
  'overwritehost'     => '${NEXTCLOUD_trusted_domains}',
  'overwriteprotocol' => 'https',
);
EOF
chown www-data:www-data /var/www/nextcloud/config/config.php
chmod 640 /var/www/nextcloud/config/config.php
rm /var/www/nextcloud/config/config.sample.php

#sed -i -e "s/NEXTCLOUD_SYSLOG/$NEXTCLOUD_syslog/" /etc/apache2/sites-available/nextcloud.conf
/etc/init.d/php7.3-fpm start
exec /usr/local/bin/httpd-foreground
