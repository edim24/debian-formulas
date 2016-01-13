{% from "rabbitmq/map.jinja" import rabbitmq with context %}

{% if 1 == salt['cmd.retcode']('test -f /srv/locks/rabbitmq.' + rabbitmq.version +'.lock') %}

rabbitmq-wget:
  pkg.installed
    - name: wget

/usr/local/src/rabbitmq:
  file.directory:
    - makedirs: True
    - clean: True

rabbitmq-source:
  cmd.run:
    - name: wget http://www.rabbitmq.com/releases/rabbitmq-server/v{{ rabbitmq.version }}/rabbitmq-server-{{ rabbitmq.version }}.tar.gz
    - cwd: /usr/local/src/rabbitmq/
    - require:
      - pkg: rabbitmq-wget
      - file: /usr/local/src/rabbitmq

rabbitmq-untar:
  cmd.run:
    - name: tar xzf rabbitmq-server-{{ rabbitmq.version }}.tar.gz
    - cwd: /usr/local/src/rabbitmq/
    - require:
      - cmd: rabbitmq-source

rabbitmq-configure:
  cmd.run:
    - name: ./configure
    - cwd: /usr/local/src/rabbitmq/rabbitmq-server-{{ rabbitmq.version }}/
    - require:
      - cmd: rabbitmq-untar

rabbitmq-make:
  cmd.run:
    - name: make
    - cwd: /usr/local/src/rabbitmq/rabbitmq-server-{{ rabbitmq.version }}/
    - require:
      - cmd: rabbitmq-configure

rabbitmq-make-install:
  cmd.run:
    - name: make install
    - cwd: /usr/local/src/rabbitmq/rabbitmq-server-{{ rabbitmq.version }}/
    - require:
      - cmd: rabbitmq-make

rabbitmq-lock-file:
  file.touch:
    - name: /srv/locks/rabbitmq.{{ rabbitmq.version }}.lock
    - makedirs: true
    - require:
      - cmd: rabbitmq-make-install

rabbitmq-server:
  service.running:
    - require:
      - cmd: rabbitmq-make-install

{% endif %}
