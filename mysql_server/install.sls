{% from "mysql_server/map.jinja" import mysql_server with context %}

mysql-server-pkgs:
  pkg:
    - installed
    - pkgs:
      - mysql-server
      - python-mysqldb

mysql-server-service:
  service.running:
    - name: mysql
    - enable: True
    - require:
      - pkg: mysql-server-pkgs

mysql-server-init:
  mysql_database.present:
    - name: {{ mysql_server.db }}
    - require:
      - pkg: mysql-server-pkgs
  mysql_user.present:
    - name: {{ mysql_server.user }}
    - password: {{ mysql_server.password }}
    - require:
      - pkg: mysql-server-pkgs
  mysql_grants.present:
    - database: {{ mysql_server.db }}.*
    - grant: ALL PRIVILEGES
    - user: {{ mysql_server.user }}
    - host: 'localhost'
    - require:
      - pkg: mysql-server-pkgs
