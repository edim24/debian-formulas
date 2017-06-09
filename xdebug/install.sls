include:
  - php5x

php5-xdebug:
  pkg.installed:
    - require:
      - pkg: php5x

/etc/php5/mods-available/xdebug.ini:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://xdebug/xdebug.ini
    - require:
      - pkg: php5-xdebug
    - watch_in:
      - service: php5x-fpm-service
