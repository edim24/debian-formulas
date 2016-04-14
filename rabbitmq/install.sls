{% from "rabbitmq/map.jinja" import rabbitmq with context %}

{% if salt['file.file_exists']('/srv/locks/rabbitmq.' + rabbitmq.version + '.lock') == False %}

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

{% if rabbitmq.get('enable_management_plugin', False) %}

rabbitmq-enable-management-plugin:
  cmd.run:
    - name: /usr/sbin/rabbitmq-plugins enable rabbitmq_management
    - unless: /usr/sbin/rabbitmq-plugins list -m -E rabbitmq_management | grep -q "^rabbitmq_management$"
    - runas: root
    - require:
      - service: rabbitmq-server

{% else %}

rabbitmq-disable-management-plugin:
  cmd.run:
    - name: /usr/sbin/rabbitmq-plugins disable rabbitmq_management
    - onlyif: /usr/sbin/rabbitmq-plugins list -m -E rabbitmq_management | grep -q "^rabbitmq_management$"
    - runas: root
    - require:
      - service: rabbitmq-server

{% endif %}

{% for user in rabbitmq.users %}

{#
@TODO Thr next state generates errors. Dont't use it until the bug is corrected.
@LINK https://github.com/saltstack/salt/issues/25125

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
#}

rabbitmq-add-user-{{ user.name }}:
  cmd.run:
    - name: /usr/sbin/rabbitmqctl add_user {{ user.name }} {{ user.password }}
    - unless: /usr/sbin/rabbitmqctl list_users -q | grep -q "^{{ user.name }}\s*\[.*\]$"
    - runas: root
    - require:
      - service: rabbitmq-server

rabbitmq-change-password-{{ user.name }}:
  cmd.run:
    - name: /usr/sbin/rabbitmqctl change_password {{ user.name }} {{ user.password }}
    - unless: /usr/sbin/rabbitmqctl authenticate_user -q {{ user.name }} {{ user.password }} | grep -qi "^success$"
    - runas: root
    - require:
      - cmd: rabbitmq-add-user-{{ user.name }}
      - service: rabbitmq-server

{% if user.get('permissions', False) %}

rabbitmq-set-permissions-{{ user.name }}:
  cmd.run:
    - name: /usr/sbin/rabbitmqctl set_permissions -p {{ user.permissions.get('vhostpath', '/') }} {{ user.name }} "{{ user.permissions.get('conf', '.*') }}" "{{ user.permissions.get('write', '.*') }}" "{{ user.permissions.get('read', '.*') }}"
    - unless: /usr/sbin/rabbitmqctl list_user_permissions -q {{ user.name }} | grep -qi "^{{ user.permissions.get('vhostpath', '/') }}\s{{ user.permissions.get('conf', '.*') }}\s{{ user.permissions.get('write', '.*') }}\s{{ user.permissions.get('read', '.*') }}$"
    - runas: root
    - require:
      - cmd: rabbitmq-add-user-{{ user.name }}
      - service: rabbitmq-server

{% endif %}

rabbitmq-set-tags-{{ user.name }}:
  cmd.run:
    - name: /usr/sbin/rabbitmqctl set_user_tags {{ user.name }} {% for tag in user.get('tags', []) %}{{ tag }} {% endfor %}
    - unless: /usr/sbin/rabbitmqctl list_users -q | grep -q "^{{ user.name }}\s*\[{% for tag in user.get('tags', []) %}{{ tag }}[, ]*{% endfor %}\]$"
    - runas: root
    - require:
      - cmd: rabbitmq-add-user-{{ user.name }}
      - service: rabbitmq-server


{% endfor %}
