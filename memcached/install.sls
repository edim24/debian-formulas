# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "memcached/map.jinja" import memcached with context %}

{% if memcached.server.installed == True %}

memcached:
  pkg.installed

memcached-service:
  service.running:
    - name: memcached
    - require:
      - pkg: memcached

/etc/memcached.conf:
  file.managed:
    - source: salt://memcached/memcached.conf
    - context:
      listen_addr: {{ memcached.server.listen_addr }}
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: memcached
    - watch_in:
      - service: memcached-service

{% endif %}

{% if memcached.client.installed == True %}

include:
  - php

memcached-php-extention:
  pkg.installed:
    - name: php7.0-memcached
    - require:
      - pkg: php

{% endif %}
