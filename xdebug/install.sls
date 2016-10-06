include:
  - php

xdebug-php-extention:
  pkg.installed:
    - name: php7.0-xdebug
    - require:
      - pkg: php

xdebug-ini-file:
  file.managed:
    - name: /etc/php/7.0/mods-available/xdebug.ini
    - user: root
    - group: root
    - mode: 644
    - source: salt://xdebug/xdebug.ini
    - require:
      - pkg: xdebug-php-extention
    - watch_in:
      - service: php-fpm-service
