include:
  - php55

php5-xdebug:
  pkg.installed:
    - require:
      - pkg: php55

/etc/php5/mods-available/xdebug.ini:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://xdebug/xdebug.ini
    - require:
      - pkg: php5-xdebug
    - watch_in:
      - service: php55-fpm-service
