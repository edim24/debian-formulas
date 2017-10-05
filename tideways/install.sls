include:
  - php

tideways-repo:
  pkgrepo.managed:
    - name: deb http://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages debian main
    - file: /etc/apt/sources.list.d/tideways.list
    - key_url: https://s3-eu-west-1.amazonaws.com/qafoo-profiler/packages/EEB5E8F4.gpg

tideways:
  pkg.installed:
    - pkgs:
      - tideways-php
      - tideways-cli
      - graphviz
    - require:
      - pkgrepo: tideways-repo
      - pkg: php
    - watch_in:
      - service: php-fpm-service
