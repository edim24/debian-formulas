{% if salt['file.file_exists']('/srv/locks/composer.lock') == False %}

include:
  - php

composer-installer:
  cmd.run:
    - name: php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    - cwd: /root
    - require:
      - pkg: php

composer-setup:
  cmd.run:
    - name: php composer-setup.php
    - env:
      - HOME: /root
    - cwd: /root
    - require:
      - cmd: composer-installer

composer-remove-installer:
  cmd.run:
    - name: rm -f composer-setup.php
    - cwd: /root
    - require:
      - cmd: composer-setup

composer-zip-pkgs:
    pkg.installed:
    - pkgs:
      - zip
      - unzip
      - php-pclzip

composer-mv:
  cmd.run:
    - name: mv /root/composer.phar /usr/local/bin/composer
    - require:
      - pkg: composer-zip-pkgs
      - cmd: composer-setup

composer-lock-file:
  file.touch:
    - name: /srv/locks/composer.lock
    - makedirs: true
    - require:
      - cmd: composer-mv
    - require_in:
      - file: composer-complete

{% endif %}

composer-complete:
  file.exists:
    - name: /usr/local/bin/composer
