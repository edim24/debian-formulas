{% from "nginx/map.jinja" import nginx with context %}

include:
  - php5x

nginx:
  pkg.installed:
    - require_in:
      - pkg: php5x
  service.running:
    - require:
      - pkg: nginx
    - watch:
      - file: /etc/nginx/nginx.conf

/etc/nginx/nginx.conf:
  file.managed:
    - source: {{ nginx.config }}
    - user: root
    - group: root
    - require:
      - pkg: nginx
