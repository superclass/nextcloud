FROM gandalf.endore:5000/webstack:10.11.0
MAINTAINER Andre van Dijk <andre.van.dijk@superclass.nl>
RUN wget -q -O- https://download.nextcloud.com/server/releases/nextcloud-22.2.3.tar.bz2 | tar xfvj - -C /var/www
RUN wget -q -O- https://github.com/nextcloud-releases/contacts/releases/download/v4.0.7/contacts-v4.0.7.tar.gz|tar xfvz - -C /var/www/nextcloud/apps
RUN wget -q -O- https://github.com/nextcloud-releases/calendar/releases/download/v3.0.5/calendar-v3.0.5.tar.gz|tar xfvz - -C /var/www/nextcloud/apps
RUN wget -q -O- https://github.com/nextcloud/bruteforcesettings/releases/download/v2.2.0/bruteforcesettings.tar.gz|tar xvfz - -C /var/www/nextcloud/apps
RUN wget -q -O- https://github.com/nextcloud/tasks/releases/download/v0.14.2/tasks.tar.gz |tar xfvz - -C /var/www/nextcloud/apps
RUN chown -R www-data.www-data /var/www/nextcloud;chmod o-rwx /var/www/nextcloud
ENV NEXTCLOUD_VERSION='22.2.3.0'
ENV NEXTCLOUD_instanceid=
ENV NEXTCLOUD_installed=false
ENV NEXTCLOUD_passwordsalt=
ENV NEXTCLOUD_secret=
ENV NEXTCLOUD_datadirectory='/data'
ENV NEXTCLOUD_trusted_domains=cloud.superclass.nl
ENV NEXTCLOUD_dbtype='mysql'
ENV NEXTCLOUD_dbname='owncloud'
ENV NEXTCLOUD_dbhost='mysql'
ENV NEXTCLOUD_dbtableprefix='oc_'
ENV NEXTCLOUD_dbuser='oc_owncloud'
ENV NEXTCLOUD_dbpassword='oc_owncloud'
ENV NEXTCLOUD_forcessl=false
ENV NEXTCLOUD_default_language='en'
ENV NEXTCLOUD_maintenance=false
ENV NEXTCLOUD_memcache_local='\\OC\\Memcache\\APCu'
ENV NEXTCLOUD_loglevel=2
ENV NEXTCLOUD_log_type='owncloud'
ENV NEXTCLOUD_logtimezone='Europe/Amsterdam'
ENV NEXTCLOUD_trashbin_retention_obligation='auto'
ENV NEXTCLOUD_updater_release_channel='stable'
ENV NEXTCLOUD_updater_secret=
ENV NEXTCLOUD_syslog=localhost
RUN mkdir /data && chown www-data:www-data /data
RUN rm -rf /var/www/html
COPY conf/nextcloud.conf /etc/apache2/sites-available/nextcloud.conf
RUN a2enmod proxy proxy_fcgi proxy_http proxy_html proxy_wstunnel filter rewrite substitute
RUN sed -i -e 's/\(upload_max_filesize\).*/\1=4G/' -e 's/\(post_max_size\).*/\1=4G/' -e 's/;\(opcache.enable=\).*/\11/' -e 's/;\(opcache.enable_cli=\).*/\11/' -e 's/;\(opcache.interned_strings_buffer=\).*/\18/' -e 's/;\(opcache.max_accelerated_files=\).*/\110000/' -e 's/;\(opcache.memory_consumption=\).*/\1128/' -e 's/;\(opcache.save_comments=\).*/\11/' -e 's/;\(opcache.revalidate_freq=\).*/\11/' -e 's/^\(max_execution_time\).*/\1 = 300/' -e 's/^\(max_input_time\).*/\1 = 300/' -e 's/^\(memory_limit\).*/\1 = 512M/' /etc/php/7.3/fpm/php.ini 
RUN sed -i -e 's/^\(pm.max_children\).*/\1 = 25/' -e 's/\(pm.start_servers\).*/\1 = 10/' -e 's/\(pm.min_spare_servers\).*/\1 = 5/' -e 's/^\(pm.max_spare_servers\).*/\1 = 10/' /etc/php/7.3/fpm/pool.d/www.conf
RUN rm /etc/apache2/sites-enabled/000-default.conf; ln -s /etc/apache2/sites-available/nextcloud.conf /etc/apache2/sites-enabled/
RUN echo "apc.enable_cli=1" >> /etc/php/7.3/mods-available/apcu.ini
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY scripts/healthcheck.sh /scripts/healthcheck.sh
RUN ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime && dpkg-reconfigure tzdata
RUN mkdir -m 2750 /var/log/nextcloud
RUN chown www-data:adm /var/log/nextcloud
RUN apt-get -y update && apt-get -y upgrade && apt-get -y clean
RUN chmod +x /var/www/nextcloud/occ
RUN chsh -s /bin/bash www-data
HEALTHCHECK --interval=10m --retries=1 --timeout=1m CMD /scripts/healthcheck.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
