include:
  - php
  - curl

composer-get:
  cmd.run:
    - name: 'CURL=`which curl`; $CURL -sS https://getcomposer.org/installer | php'
    - unless: test -f /usr/local/bin/composer
    - cwd: /root/
    - require:
      - pkg: curl
      - pkg: php

composer-zip-pkgs:
    pkg.installed:
    - pkgs:
      - zip
      - unzip

composer-setup:
  cmd.wait:
    - name: mv /root/composer.phar /usr/local/bin/composer
    - cwd: /root/
    - require:
      - pkg: composer-zip-pkgs
    - watch:
      - cmd: composer-get
