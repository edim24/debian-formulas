mongodb-repo:
  pkgrepo.managed:
    - name: deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen
    - keyserver: keyserver.ubuntu.com
    - keyid: 7F0CEB10

/etc/default/locale:
  file.managed:
    - source: salt://files/locale
    - user: root
    - group: root

mongodb-all:
  pkg.installed:
    - version: {{ pillar['mongodb_version'] }}
    - require:
      - pkgrepo: mongodb-repo
      - file: /etc/default/locale
    - pkgs:
      - mongodb-org
      - mongodb-org-server
      - mongodb-org-shell
      - mongodb-org-mongos
      - mongodb-org-tools

mongod:
  service.running:
    - enable: True
    - require:
      - pkg: mongodb-all