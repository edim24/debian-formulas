include:
  - php

nginx:
  pkg.installed:
    - require_in:
      - pkg: php
  service.running:
    - require:
      - pkg: nginx
    - watch:
      - file: /etc/nginx/nginx.conf

/etc/nginx/nginx.conf:
  file.managed:
    - source: salt://nginx/nginx.conf
    - user: root
    - group: root
    - require:
      - pkg: nginx
