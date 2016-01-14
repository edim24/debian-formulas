include:
  - php55

composer-curl:
  pkg.installed:
    - name: curl

composer-get:
  cmd.run:
    - name: 'CURL=`which curl`; $CURL -sS https://getcomposer.org/installer | php'
    - unless: test -f /usr/local/bin/composer
    - cwd: /root/
    - require:
      - pkg: composer-curl
      - sls: php55

composer-setup:
  cmd.wait:
    - name: mv /root/composer.phar /usr/local/bin/composer
    - cwd: /root/
    - watch:
      - cmd: composer-get
