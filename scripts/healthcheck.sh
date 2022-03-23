#!/bin/bash

# clean sessions
/usr/lib/php/sessionclean

su - www-data -c php -f /var/www/nextcloud/cron.php

# Check status.php
wget -O- --no-check-certificate http://localhost/nextcloud/status.php|grep -q ".installed.:true,.maintenance.:false,.needsDbUpgrade.:false,.version.:.${NEXTCLOUD_VERSION}."
exit $?
