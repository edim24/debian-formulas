{% from "phalcon/map.jinja" import phalcon with context %}

{% if 1 == salt['cmd.retcode']('test -f /srv/locks/phalcon.' + phalcon.version +'.lock') %}

include:
  - php55

https://github.com/phalcon/cphalcon.git:
  git.latest:
    - target: /usr/local/src/phalcon
    - rev: {{ phalcon.version }}
    - depth: 1

phalcon-libs:
  pkg.installed:
    - pkgs:
      - libpcre3-dev

phalcon-build:
  cmd.run:
    - name: ./install
    - cwd: /usr/local/src/phalcon/ext/
    - require:
      - git: https://github.com/phalcon/cphalcon.git
      - pkg: phalcon-libs
      - pkg: php55
      - service: php55-fpm-service

/etc/php5/mods-available/phalcon.ini:
  file.managed:
    - user: root
    - group: root
    - source: salt://phalcon/phalcon.ini
    - require:
      - cmd: phalcon-build

phalcon-mod-enable:
  cmd.run:
    - name: php5enmod phalcon && service php5-fpm restart
    - onlyif: type php5enmod
    - require:
      - file: /etc/php5/mods-available/phalcon.ini

phalcon-lock-file:
  file.touch:
    - name: /srv/locks/phalcon.{{ phalcon.version }}.lock
    - makedirs: true
    - require:
      - cmd: phalcon-mod-enable

{% endif %}
