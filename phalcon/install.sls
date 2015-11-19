https://github.com/phalcon/cphalcon.git:
  git.latest:
    - target: /usr/local/src/phalcon
    - rev: {{ phalcon.version }}
    - depth: 1
    - require:
      - pkg: dev-apps

phalcon-build:
  cmd.run:
    - name: ./install
    - cwd: /usr/local/src/phalcon/ext/
    - require:
      - git: https://github.com/phalcon/cphalcon.git

/etc/php5/mods-available/phalcon.ini:
  file.managed:
    - user: root
    - group: root
    - source: salt://files/phalcon.ini
    - require:
      - cmd: phalcon-build

phalcon-mod-enable:
  cmd.run:
    - name: php5enmod phalcon && service php5-fpm restart && service nginx restart
    - onlyif: type php5enmod
    - require:
      - file: /etc/php5/mods-available/phalcon.ini
      - pkg: php55
      - pkg: nginx

phalcon-lock-file:
  file.touch:
    - name: /srv/locks/phalcon.{{ phalcon.version }}.lock
    - makedirs: true
    - require:
      - cmd: phalcon-mod-enable
