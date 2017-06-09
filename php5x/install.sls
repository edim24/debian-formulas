{% from "php5x/map.jinja" import php5x with context %}

php5x-dotdeb:
  pkgrepo.managed:
    - name: {{ php5x.php_pkgrepo }}
    - file: /etc/apt/sources.list
    - key_url: http://www.dotdeb.org/dotdeb.gpg

php5x:
  pkg.installed:
    - pkgs:
      - php5-common
      - php5-cli
      - php5-fpm
      - php5-dev
    - require:
      - pkgrepo: php5x-dotdeb

php5x-extentions:
  pkg.installed:
    - pkgs: {{ php5x.extensions }}
    - require:
      - pkg: php5x

php5x-www-conf:
  file.managed:
    - name: /etc/php5/fpm/pool.d/www.conf
    - source: salt://php5x/www.conf
    - user: root
    - group: root
    - require:
      - pkg: php5x

php5x-fpm-service:
  service.running:
    - name: php5-fpm
    - watch:
      - pkg: php5x-extentions
      - file: php5x-www-conf
    - require:
      - pkg: php5x

{% if php5x.get('enable_short_open_tag', False) %}

php5x-fpm-enable-short-tag:
  file.replace:
    - name: /etc/php5/fpm/php.ini
    - pattern: short_open_tag = Off
    - repl: short_open_tag = On
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: php5x
    - watch_in:
      - service: php5x-fpm-service

php5x-cli-enable-short-tag:
  file.replace:
    - name: /etc/php5/cli/php.ini
    - pattern: short_open_tag = Off
    - repl: short_open_tag = On
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: php5x
    - watch_in:
      - service: php5x-fpm-service

{% endif %}

php5x-fpm-upload-max-filesize:
  file.replace:
    - name: /etc/php5/fpm/php.ini
    - pattern: upload_max_filesize = [0-9]{1,}[KMG]$
    - repl: upload_max_filesize = {{ php5x.get('upload_max_filesize', '2M') }}
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: php5x
    - watch_in:
      - service: php5x-fpm-service
