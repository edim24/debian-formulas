{% from "phalcon/map.jinja" import phalcon with context %}

{% if salt['file.file_exists']('/srv/locks/phalcon.' + phalcon.version + '.lock') == False %}

include:
  - curl
  - php

phalcon-deb:
  cmd.run:
    - name: curl -s https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | sudo bash
    - require:
      - pkg: curl

phalcon-install:
  pkg.installed:
    - name: php7.1-phalcon
    - version: {{ phalcon.version }}
    - require:
      - pkg: php
      - cmd: phalcon-deb
    - watch_in:
      - service: php-fpm-service

phalcon-lock-file:
  file.touch:
    - name: /srv/locks/phalcon.{{ phalcon.version }}.lock
    - makedirs: true
    - require:
      - pkg: phalcon-install

{% endif %}
