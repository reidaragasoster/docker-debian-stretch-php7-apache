#!/bin/sh
mkdir -p /site/web
mkdir -p /site/logs/php
mkdir -p /site/logs/nginx
mkdir -p /site/logs/supervisor
mkdir -p /run/php

if [ "${WORKERS}" != "0" ]; then
  cat /supervisor_workers.conf | sed -E -e 's/^numprocs=0/numprocs='${WORKERS}'/' >>   /supervisord.conf
fi

#curl --insecure https://localhost/playback_schedule
#su - web -c 'cd  /site/web/;git pull; composer install -o'

if [ "${CRONTAB_ACTIVE}" = "TRUE" ]; then
  (echo "* * * * * su web -c '/usr/bin/php /site/web/artisan schedule:run' 2>&1 | /usr/bin/logger -t LARAVEL_SCHEDULE" ) | crontab -
fi

if [ "${ENABLE_DEBUG}" = "TRUE" ]; then
  sed -E -i -e 's/;//' /etc/php/7.0/mods-available/xdebug.ini
  echo "xdebug.remote_enable=1
xdebug.remote_host=localhost
xdebug.remote_connect_back=1
xdebug.remote_port=9000" >> /etc/php/7.0/mods-available/xdebug.ini
fi

chown -R web: /site  &

/usr/bin/supervisord -n -c /supervisord.conf
