# -*- coding: utf-8 -*-
# vim: ft=sls

include:
  - php55

timezonedb:
  pecl.installed:
    - require:
      - pkg: php55

/etc/php5/mods-available/timezonedb.ini:
  file.managed:
    - user: root
    - group: root
    - contents:
      - extension=timezonedb.so
    - require:
      - pecl: timezonedb

timezonedb-mod-enable:
  cmd.run:
    - name: php5enmod timezonedb && service php5-fpm restart
    - onlyif: type php5enmod
    - unless: /usr/bin/php -m | grep -i timezonedb
    - require:
      - file: /etc/php5/mods-available/timezonedb.ini
