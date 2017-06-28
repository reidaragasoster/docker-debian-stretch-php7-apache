#!/bin/bash
a2ensite webgrind.conf
php5enmod xdebug

apachectl -k restart
