{% from "php/map.jinja" import php with context %}

php-dotdeb:
  pkgrepo.managed:
    - name: deb http://packages.dotdeb.org jessie all
    - file: /etc/apt/sources.list
    - key_url: https://www.dotdeb.org/dotdeb.gpg

php:
  pkg.installed:
    - pkgs:
      - php7.0-common
      - php7.0-cli
      - php7.0-fpm
      - php7.0-dev
    - require:
      - pkgrepo: php-dotdeb

php-extentions:
  pkg.installed:
    - pkgs: {{ php.extensions }}
    - require:
      - pkg: php

php-www-conf:
  file.managed:
    - name: /etc/php/7.0/fpm/pool.d/www.conf
    - source: salt://php/www.conf
    - user: root
    - group: root
    - require:
      - pkg: php

php-fpm-service:
  service.running:
    - name: php7.0-fpm
    - watch:
      - pkg: php-extentions
      - file: php-www-conf
    - require:
      - pkg: php

{% if php.get('enable_short_open_tag', False) %}

php-fpm-enable-short-tag:
  file.replace:
    - name: /etc/php/7.0/fpm/php.ini
    - pattern: short_open_tag = Off
    - repl: short_open_tag = On
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: php
    - watch_in:
      - service: php-fpm-service

php-cli-enable-short-tag:
  file.replace:
    - name: /etc/php/7.0/cli/php.ini
    - pattern: short_open_tag = Off
    - repl: short_open_tag = On
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: php
    - watch_in:
      - service: php-fpm-service

{% endif %}

php-fpm-upload-max-filesize:
  file.replace:
    - name: /etc/php/7.0/fpm/php.ini
    - pattern: upload_max_filesize = [0-9]{1,}[KMG]$
    - repl: upload_max_filesize = {{ php.get('upload_max_filesize', '2M') }}
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: php
    - watch_in:
      - service: php-fpm-service
