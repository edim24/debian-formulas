{% from "php/map.jinja" import php with context %}

php-deps:
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - ca-certificates

php-repo:
  pkgrepo.managed:
    - name: deb https://packages.sury.org/php/ jessie main
    - file: /etc/apt/sources.list.d/php.list
    - key_url: https://packages.sury.org/php/apt.gpg
    - require:
      - pkg: php-deps

php:
  pkg.installed:
    - pkgs:
      - php7.1-fpm
      - php7.1-cli
      - php7.1-dev
    - require:
      - pkgrepo: php-repo

php-extentions:
  pkg.installed:
    - pkgs: {{ php.extensions }}
    - require:
      - pkg: php

php-www-conf:
  file.managed:
    - name: /etc/php/7.1/fpm/pool.d/www.conf
    - source: salt://php/www.conf
    - user: root
    - group: root
    - require:
      - pkg: php

php-fpm-service:
  service.running:
    - name: php7.1-fpm
    - watch:
      - pkg: php-extentions
      - file: php-www-conf
    - require:
      - pkg: php

{% if php.get('enable_short_open_tag', False) %}

php-fpm-enable-short-tag:
  file.replace:
    - name: /etc/php/7.1/fpm/php.ini
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
    - name: /etc/php/7.1/cli/php.ini
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
    - name: /etc/php/7.1/fpm/php.ini
    - pattern: upload_max_filesize = [0-9]{1,}[KMG]$
    - repl: upload_max_filesize = {{ php.get('upload_max_filesize', '2M') }}
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: php
    - watch_in:
      - service: php-fpm-service
