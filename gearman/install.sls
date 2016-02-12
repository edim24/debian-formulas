{% from "gearman/map.jinja" import gearman with context %}

{% if gearman.server.installed and 1 == salt['cmd.retcode']('test -f /srv/locks/gearman.' + gearman.server.version +'.lock') %}
include:
  - php55

gearman-job-server-packages:
  pkg.installed:
    - pkgs:
      - libboost-all-dev
      - gperf
      - libevent-dev
      - uuid-dev
      - gearman-tools
    - require:
      - pkg: php55

/usr/local/src/gearman-job-server:
  file.directory:
    - makedirs: True
    - clean: True

gearman-job-server-source:
  cmd.run:
    - name: wget https://launchpad.net/gearmand/1.2/{{ gearman.server.version }}/+download/gearmand-{{ gearman.server.version }}.tar.gz
    - cwd: /usr/local/src/gearman-job-server/
    - require:
      - pkg: gearman-job-server-packages
      - file: /usr/local/src/gearman-job-server

gearman-job-server-untar:
  cmd.run:
    - name: tar xzf gearmand-{{ gearman.server.version }}.tar.gz
    - cwd: /usr/local/src/gearman-job-server/
    - require:
      - cmd: gearman-job-server-source

gearman-job-server-configure:
  cmd.run:
    - name: ./configure
    - cwd: /usr/local/src/gearman-job-server/gearmand-{{ gearman.server.version }}/
    - require:
      - cmd: gearman-job-server-untar

gearman-job-server-make:
  cmd.run:
    - name: make
    - cwd: /usr/local/src/gearman-job-server/gearmand-{{ gearman.server.version }}/
    - require:
      - cmd: gearman-job-server-configure

gearman-job-server-make-install:
  cmd.run:
    - name: make install
    - cwd: /usr/local/src/gearman-job-server/gearmand-{{ gearman.server.version }}/
    - require:
      - cmd: gearman-job-server-make

/var/log/gearman-job-server:
  file.directory:
    - makedirs: True
    - clean: True
    - require:
      - cmd: gearman-job-server-make-install

/var/log/gearman-job-server/gearmand.log:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /var/log/gearman-job-server

/etc/init.d/gearman-job-server:
  file.managed:
    - user: root
    - group: root
    - mode: 755
    - source: salt://gearman/gearman-job-server
    - require:
      - file: /var/log/gearman-job-server/gearmand.log

gearman-job-server:
  service.running:
    - enable: True
    - require:
      - file: /etc/init.d/gearman-job-server

gearman-job-server-lock-file:
  file.touch:
    - name: /srv/locks/gearman-job-server.{{ gearman.server.version }}.lock
    - makedirs: true
    - require:
      - cmd: gearman-mod-enable

{% endif %}

{% if gearman.client.installed %}
gearman:
  pecl.installed

/etc/php5/mods-available/gearman.ini:
  file.managed:
    - user: root
    - group: root
    - source: salt://gearman/gearman.ini
    - require:
      - pecl: gearman

gearman-mod-enable:
  cmd.run:
    - name: php5enmod gearman && service php5-fpm restart
    - onlyif: type php5enmod
    - unless: /usr/bin/php -m | grep -i gearman
    - require:
      - file: /etc/php5/mods-available/gearman.ini
      - pkg: php55

{% endif %}
