FROM debian:stretch
MAINTAINER tim@haak.co

ENV DEBIAN_FRONTEND="noninteractive" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    TERM="xterm" \
    TZ="/usr/share/zoneinfo/UTC"

RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup && \
    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
    apt-get update && \
    apt-get install -qy locales && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    echo 'en_ZA.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    locale-gen en_ZA.UTF-8 && \
    apt-get -qy dist-upgrade && \
    apt-get install -y tzdata && \
    apt-get install -qy \
        apt-transport-https \
        bash-completion \
        build-essential \
        bzip2 \
        ca-certificates curl \
        dnsutils \
        gawk git \
        imagemagick inetutils-ping \
        lsb-release \
        make mysql-client \
        postgresql-client \
        nano \
        openssl \
        python python-pip python-setuptools software-properties-common procps psmisc \
        rsync rsyslog \
        software-properties-common ssl-cert strace sudo supervisor \
        tar telnet tmux traceroute tree \
        wget whois \
        unzip \
        vim \
        xz-utils \
        zsh && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN apt-get update && \
    apt-get -y install \
        geoip-bin geoip-database-extra geoip-database \
        && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

ADD ./files/GeoIP.conf /etc/GeoIP.conf

RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list && \
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg

ENV WEB_HOME_DIR="/site" \
    SITE_HOME_DIR="/site/web" \
    LOG_DIR="/site/logs" \
    APACHE_RUN_USER="wew" \
    APACHE_RUN_GROUP="web" \
    APACHE_PID_FILE="/var/run/apache2.pid" \
    APACHE_RUN_DIR="/var/run/apache2" \
    APACHE_LOCK_DIR="/var/lock/apache2" \
    APACHE_LOG_DIR="/site/logs/apache2"

RUN apt-get update && \
    apt-get -y install \
        \
        apache2 \
        apache2 apache2-suexec-pristine \
        libapache2-mod-php7.1 \
        \
        php7.1 php7.1-cli php7.1-fpm \
        \
        php7.1-bcmath php7.1-bz2 \
        php7.1-common php7.1-curl \
        php7.1-dev \
        php-geoip php7.1-gd php7.1-gmp \
        php7.1-imap php7.1-intl \
        php7.1-json \
        php7.1-mbstring php-mongodb \
        php7.1-mcrypt php7.1-mysql \
        php7.1-odbc php7.1-opcache \
        php7.1-pgsql \
        php7.1-readline  \
        php7.1-sqlite3 \
        php-xdebug php7.1-xml php7.1-xmlrpc php7.1-xsl\
        php7.1-zip \
        \
        php-dev php-pear php-redis \
        \
        libphp-predis \
        pear-channels \
        && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN sed -i "$ s|\-n||g" /usr/bin/pecl && \
    pear config-set auto_discover 1 && \
    pear upgrade pear && \
    pear channel-update pear.php.net || \
    pear channel-discover components.ez.no || \
    pear channel-discover pear.symfony.com || \
    pecl channel-update pecl.php.net

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \
    sed -i \
        -e "s/upload_max_filesize = .*/upload_max_filesize = 128M/" \
        -e "s/post_max_size = .*/post_max_size = 128M/"  \
        -e "s/short_open_tag = .*/short_open_tag = Off/" \
        -e "s/;date.timezone =/date.timezone = Africa\/Johannesburg/" \
        -e "s/memory_limit = .*/memory_limit = 8G/" \
        -e "s/max_execution_time = .*/max_execution_time = 300/" \
        -e "s/;default_charset = \"iso-8859-1\"/default_charset = \"UTF-8\"/" \
        -e "s/;realpath_cache_size = .*/realpath_cache_size = 16384K/" \
        -e "s/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/" \
        -e "s/;intl.default_locale =/intl.default_locale = en/" \
        -e "s/serialize_precision = .*/serialize_precision = 100/" \
        -e "s/expose_phpexpose_php = On/expose_php = Off/" \
        -e "s/;error_log = syslog/error_log = \/site\/logs\/php.log/" \
        -e "s/;opcache.enable=.*/opcache.enable=1/" \
        -e "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" \
        -e "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" \
        -e "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=16/" \
        -e "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=16229/" \
        -e "s/;opcache.revalidate_path=.*/opcache.revalidate_path=1/" \
        -e "s/;opcache.fast_shutdown=.*/opcache.fast_shutdown=0/" \
        -e "s/;opcache.enable_file_override=.*/opcache.enable_file_override=1/" \
        -e "s/;opcache.validate_timestamps=.*/;opcache.validate_timestamps=0/" \
        -e "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=0/" \
        /etc/php/7.1/apache2/php.ini && \
\
    sed -i \
        -e "s/upload_max_filesize = .*/upload_max_filesize = 128M/" \
        -e "s/post_max_size = .*/post_max_size = 128M/"  \
        -e "s/short_open_tag = .*/short_open_tag = Off/" \
        -e "s/;date.timezone =/date.timezone = Africa\/Johannesburg/" \
        -e "s/memory_limit = .*/memory_limit = 8G/" \
        -e "s/max_execution_time = .*/max_execution_time = 300/" \
        -e "s/;default_charset = \"iso-8859-1\"/default_charset = \"UTF-8\"/" \
        -e "s/;realpath_cache_size = .*/realpath_cache_size = 16384K/" \
        -e "s/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/" \
        -e "s/;intl.default_locale =/intl.default_locale = en/" \
        -e "s/serialize_precision = .*/serialize_precision = 100/" \
        -e "s/expose_phpexpose_php = On/expose_php = Off/" \
        -e "s/;error_log = syslog/error_log = \/site\/logs\/php.log/" \
        -e "s/;opcache.enable=.*/opcache.enable=1/" \
        -e "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" \
        -e "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" \
        -e "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=16/" \
        -e "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=16229/" \
        -e "s/;opcache.revalidate_path=.*/opcache.revalidate_path=1/" \
        -e "s/;opcache.fast_shutdown=.*/opcache.fast_shutdown=0/" \
        -e "s/;opcache.enable_file_override=.*/opcache.enable_file_override=1/" \
        -e "s/;opcache.validate_timestamps=.*/;opcache.validate_timestamps=0/" \
        -e "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=0/" \
        /etc/php/7.1/cli/php.ini && \
\
    sed -i \
        -e "s/upload_max_filesize = .*/upload_max_filesize = 128M/" \
        -e "s/post_max_size = .*/post_max_size = 128M/"  \
        -e "s/short_open_tag = .*/short_open_tag = Off/" \
        -e "s/;date.timezone =/date.timezone = Africa\/Johannesburg/" \
        -e "s/memory_limit = .*/memory_limit = 8G/" \
        -e "s/max_execution_time = .*/max_execution_time = 300/" \
        -e "s/;default_charset = \"iso-8859-1\"/default_charset = \"UTF-8\"/" \
        -e "s/;realpath_cache_size = .*/realpath_cache_size = 16384K/" \
        -e "s/;realpath_cache_ttl = .*/realpath_cache_ttl = 7200/" \
        -e "s/;intl.default_locale =/intl.default_locale = en/" \
        -e "s/serialize_precision = .*/serialize_precision = 100/" \
        -e "s/expose_phpexpose_php = On/expose_php = Off/" \
        -e "s/;error_log = syslog/error_log = \/site\/logs\/php.log/" \
        -e "s/;opcache.enable=.*/opcache.enable=1/" \
        -e "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" \
        -e "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" \
        -e "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=16/" \
        -e "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=16229/" \
        -e "s/;opcache.revalidate_path=.*/opcache.revalidate_path=1/" \
        -e "s/;opcache.fast_shutdown=.*/opcache.fast_shutdown=0/" \
        -e "s/;opcache.enable_file_override=.*/opcache.enable_file_override=1/" \
        -e "s/;opcache.validate_timestamps=.*/;opcache.validate_timestamps=0/" \
        -e "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=0/" \
        /etc/php/7.1/fpm/php.ini && \
    \
    sed -E -i -e 's/^/;/' /etc/php/7.1/mods-available/xdebug.ini && \
    \
    sed -Ei \
        -e "s/\/var\/log/\/site\/logs/" \
        /etc/php/7.1/fpm/php-fpm.conf && \
    \
    sed -Ei \
        -e "s/^user = .*/user = web/" \
        -e "s/^group = .*/group = web/" \
        -e 's/listen\.owner.*/listen\.owner = web/' \
        -e 's/listen\.group.*/listen\.group = web/' \
        -e "s/pm.max_children = 5/pm.max_children = 20/" \
        -e 's/\/run\/php\/.*fpm.sock/\/run\/php\/fpm.sock/' \
        /etc/php/7.1/fpm/pool.d/www.conf && \
    \
    echo "request_terminate_timeout = 600" >> /etc/php/7.1/fpm/php-fpm.conf && \
    \
    php -r "readfile('http://getcomposer.org/installer');" | php -- --install-dir=bin --filename=composer && \
    composer global require hirak/prestissimo

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list  && \
    apt update && \
    apt-get -y install && \
    ACCEPT_EULA=Y apt-get -y install \
      autoconf \
      g++  gcc \
      libc-dev \
      make mcrypt msodbcsql mssql-tools \
      php-mbstring pkg-config \
      re2c  \
      unixodbc-dev \
      && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile && \
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc && \
    . ~/.bashrc && \
    pear config-set php_ini `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"` system && \
    sed -i "$ s|\-n||g" /usr/bin/pecl && \
    pecl install sqlsrv && \
    pecl install pdo_sqlsrv && \
    echo "extension=sqlsrv.so" >> /etc/php/7.1/apache2/php.ini && \
    echo "extension=pdo_sqlsrv.so" >> /etc/php/7.1/cli/php.ini && \
    echo "extension=pdo_sqlsrv.so" >> /etc/php/7.1/fpm/php.ini && \
    echo "extension=sqlsrv.so" >> /etc/php/7.1/apache2/php.ini && \
    echo "extension=pdo_sqlsrv.so" >> /etc/php/7.1/cli/php.ini && \
    echo "extension=pdo_sqlsrv.so" >> /etc/php/7.1/fpm/php.ini

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install nodejs && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

#  --unsafe-perm work around for npm bug
RUN npm install --unsafe-perm -g \
      @angular/cli \
      azure-cli \
      babel-cli bower browser-sync \
      cordova cordova-check-plugins \
      firebase-tools fuse \
      http-server \
      iconv-lite \
      nodemon npm-check-updates node-gyp \
      sass-lint \
      semver \
      tslint typings typescript \
      uglify-js \
      webpack webpack-dev-server \
      yarn && \
    npm cache clean --force && \
    rm -rf /root/.npm

# Allows for mounting cloud drives
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.zip -O /rclone-current-linux-amd64.zip && \
    unzip /rclone-current-linux-amd64.zip -d / && \
    mv /rclone-v* /rclone && \
    cp /rclone/rclone /usr/local/bin/ && \
    rm -rf /rclone* && \
    apt-get -y update && \
    apt dist-upgrade  -y && \
    apt install -y fuse && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

#    echo "web:`date +%s | sha256sum | base64 | head -c 32`" | chpasswd && \
RUN adduser --home /site --uid 1000 --gecos "" --disabled-password  --shell /bin/bash web && \
    mkdir -p /site/web && \
    mkdir -p /site/logs/php && \
    mkdir -p /site/logs/apache && \
    mkdir -p /site/logs/supervisor && \
    rm -rf /etc/apache2/sites-enabled/000-default.conf && \
    rm -rf /etc/apache2/sites-enabled/000-default

#RUN rm /etc/localtime && \
#    ln -s /usr/share/zoneinfo/Africa/Johannesburg /etc/localtime

ADD ./files/apache2/apache.env /apache.env

ADD ./files/apache2/sites_config_apache24/web.conf /etc/apache2/sites-available/web.conf
ADD ./files/apache2/sites-available/10_not_a_server.conf /etc/apache2/sites-available/10_not_a_server.conf
ADD ./files/apache2/new_conf.d /etc/apache2/new_conf.d

#ADD ./files/composer/auth.json /root/.composer/auth.json
#ADD ./files/composer/auth.json /site/.composer/auth.json
ADD ./files/start.sh /start.sh
ADD ./files/supervisord.conf /supervisord.conf

ADD ./files/rsyslog.conf /etc/rsyslog.conf
ADD ./files/rsyslog.d/50-default.conf /etc/rsyslog.d/50-default.conf
ADD ./files/artisan-bash-prompt /etc/bash_completion.d/artisan-bash-prompt

RUN echo 'cd /site/web' >> /site/.bashrc && \
    chown root: /etc/bash_completion.d/artisan-bash-prompt && \
    chmod u+rw /etc/bash_completion.d/artisan-bash-prompt && \
    chmod go+r /etc/bash_completion.d/artisan-bash-prompt && \
    chown -R web: ${WEB_HOME_DIR} && \
    a2ensite web.conf

RUN chmod u+x /start.sh && \
    mkdir -p /run/php

#VOLUME ["/site/web", "/var/log"]

WORKDIR /site/web

EXPOSE 80 9000

ENV WORKERS="0" \
    CRONTAB_ACTIVE="FALSE" \
    ENABLE_DEBUG="FALSE"

CMD ["/start.sh"]
