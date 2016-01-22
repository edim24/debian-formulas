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
    - require_in:
      - service: rabbitmq-server

rabbitmq-lock-file:
  file.touch:
    - name: /srv/locks/rabbitmq.{{ rabbitmq.version }}.lock
    - makedirs: true
    - require:
      - pkg: rabbitmq-install

{% endif %}

rabbitmq-server:
  service.running

{% for user in rabbitmq.users %}

rabbitmq-user-{{ user.name }}:
  rabbitmq_user.present:
    - name: {{ user.name }}
    - password: {{ user.password }}
    - force: True
    - perms:
      - '/':
        - '.*'
        - '.*'
        - '.*'
    - runas: root
    - require:
      - service: rabbitmq-server

{% endfor %}