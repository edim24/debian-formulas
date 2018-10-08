{% from "nginx/map.jinja" import nginx with context %}

include:
  - php55

nginx:
  pkg.installed:
    - require_in:
      - pkg: php55
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
