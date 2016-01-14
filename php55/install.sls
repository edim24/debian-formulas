{% from "php55/map.jinja" import php55 with context %}

php55:
  pkg.installed:
    - name: php5 
    - require:
      - sls: dotdeb-php55

php55-extentions:
  pkg.installed:
    - pkgs: {{ php55.extensions }}
    - require:
      - pkg: php55

php55-www-conf:
  file.managed:
    - name: /etc/php5/fpm/pool.d/www.conf
    - source: salt://php55/www.conf
    - user: root
    - group: root
    - require:
      - pkg: php55

php55-fpm:
  service.running:
    - name: php5-fpm
    - watch:
      - file: php55-www-conf
    - require:
      - pkg: php55
