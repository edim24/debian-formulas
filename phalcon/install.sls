{% from "phalcon/map.jinja" import phalcon with context %}

{% if salt['file.file_exists']('/srv/locks/phalcon.' + phalcon.version + '.lock') == False %}

include:
  - curl
  - php

phalcon-deb:
  cmd.run:
    - name: wget -qO- https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh | sudo bash
    - require:
      - pkg: curl

phalcon-apt-update:
  cmd.run:
    - name: sudo apt-get update
    - require:
      - cmd: phalcon-deb

phalcon-install:
  pkg.installed:
    - name: php7.0-phalcon
    - version: {{ phalcon.version }}
    - require:
      - pkg: php
      - cmd: phalcon-apt-update

phalcon-lock-file:
  file.touch:
    - name: /srv/locks/phalcon.{{ phalcon.version }}.lock
    - makedirs: true
    - require:
      - pkg: phalcon-install

{% endif %}
