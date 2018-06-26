{% from "php55/map.jinja" import php55 with context %}

php55-dotdeb:
  pkgrepo.managed:
    - name: deb http://packages.dotdeb.org wheezy-php55 all
    - file: /etc/apt/sources.list
    - key_url: http://www.dotdeb.org/dotdeb.gpg

php55:
  pkg.installed:
    - pkgs:
      - php5-common
      - php5-cli
      - php5-fpm
      - php5-dev
    - require:
      - pkgrepo: php55-dotdeb

php55-extentions:
  pkg.installed:
    - pkgs: {{ php55.extensions }}
    - require:
      - pkg: php55

php55-www-conf:
  file.managed:
    - name: /etc/php5/fpm/pool.d/www.conf
    - source: {{ php55.www_conf.get(environment) }}
    - user: root
    - group: root
    - require:
      - pkg: php55

php55-fpm-service:
  service.running:
    - name: php5-fpm
    - watch:
      - pkg: php55-extentions
      - file: php55-www-conf
    - require:
      - pkg: php55

{% if php55.get('enable_short_open_tag', False) %}

php55-fpm-enable-short-tag:
  file.replace:
    - name: /etc/php5/fpm/php.ini
    - pattern: short_open_tag = Off
    - repl: short_open_tag = On
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: php55
    - watch_in:
      - service: php55-fpm-service

php55-cli-enable-short-tag:
  file.replace:
    - name: /etc/php5/cli/php.ini
    - pattern: short_open_tag = Off
    - repl: short_open_tag = On
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: php55
    - watch_in:
      - service: php55-fpm-service

{% endif %}

php55-fpm-upload-max-filesize:
  file.replace:
    - name: /etc/php5/fpm/php.ini
    - pattern: upload_max_filesize = [0-9]{1,}[KMG]$
    - repl: upload_max_filesize = {{ php55.get('upload_max_filesize', '2M') }}
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: php55
    - watch_in:
      - service: php55-fpm-service
