{% from "mongodb/map.jinja" import mongodb with context %}

mongodb-repo:
  pkgrepo.managed:
    - name: deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen
    - keyserver: keyserver.ubuntu.com
    - keyid: 7F0CEB10

/etc/default/locale:
  file.managed:
    - user: root
    - group: root
    - contents:
      - LANG="en_US.UTF-8"
      - LANGUAGE="en_US:en"
      - LC_ALL="en_US.UTF-8"

mongodb-all:
  pkg.installed:
    - version: {{ mongodb.version }}
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
