{% from "rabbitmq/map.jinja" import rabbitmq with context %}

{% if 1 == salt['cmd.retcode']('test -f /srv/locks/rabbitmq.' + rabbitmq.version +'.lock') %}

rabbitmq-wget:
  pkg.installed:
    - name: wget

/usr/local/src/rabbitmq:
  file.directory:
    - makedirs: True
    - clean: True

rabbitmq-source:
  cmd.run:
    - name: wget https://www.rabbitmq.com/releases/rabbitmq-server/v{{ rabbitmq.version }}/rabbitmq-server_{{ rabbitmq.version }}-1_all.deb
    - cwd: /usr/local/src/rabbitmq/
    - require:
      - pkg: rabbitmq-wget
      - file: /usr/local/src/rabbitmq

rabbitmq-install:
  pkg.installed:
    - sources:
      - rabbitmq-server: /usr/local/src/rabbitmq/rabbitmq-server_{{ rabbitmq.version }}-1_all.deb
    - require:
      - cmd: rabbitmq-source

rabbitmq-lock-file:
  file.touch:
    - name: /srv/locks/rabbitmq.{{ rabbitmq.version }}.lock
    - makedirs: true
    - require:
      - cmd: rabbitmq-install

rabbitmq-server:
  service.running:
    - require:
      - cmd: rabbitmq-install

{% else %}

rabbitmq-server:
  service.running

{% endif %}
