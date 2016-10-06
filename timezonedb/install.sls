# -*- coding: utf-8 -*-
# vim: ft=sls

include:
  - php

timezonedb:
  pecl.installed:
    - require:
      - pkg: php

/etc/php/7.0/mods-available/timezonedb.ini:
  file.managed:
    - user: root
    - group: root
    - contents:
      - extension=timezonedb.so
    - require:
      - pecl: timezonedb

timezonedb-mod-enable:
  cmd.run:
    - name: phpenmod timezonedb && service php7.0-fpm restart
    - onlyif: type phpenmod
    - unless: /usr/bin/php -m | grep -i timezonedb
    - require:
      - file: /etc/php/7.0/mods-available/timezonedb.ini
