#!/bin/bash
a2dissite webgrind.conf
php5dismod xdebug

apachectl -k restart
