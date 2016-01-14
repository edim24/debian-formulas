composer-curl:
  pkg.installed:
    - name: curl

composer-php5:
  pkg.installed:
    - name: php5
  require:
    - sls: dotdeb-php55

composer-get:
  cmd.run:
    - name: 'CURL=`which curl`; $CURL -sS https://getcomposer.org/installer | php'
    - unless: test -f /usr/local/bin/composer
    - cwd: /root/
  require:
    - pkg: composer-curl

composer-install:
  cmd.wait:
    - name: mv /root/composer.phar /usr/local/bin/composer
    - cwd: /root/
    - watch:
      - cmd: composer-get
