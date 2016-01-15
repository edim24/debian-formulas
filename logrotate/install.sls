{% from "logrotate/map.jinja" import environment with context %}
{% from "logrotate/map.jinja" import app_dir with context %}

logrotate:
  pkg.installed

logrotate_directory:
  file.directory:
    - name: /etc/logrotate.d
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - require:
      - pkg: logrotate

logrotate_config:
  file.managed:
    - name: /etc/logrotate.d/app
    - user: root
    - group: root
    - mode: 440
    - source: salt://logrotate/logrotate.conf
    - context:
      logs_path: {{ app_dir }}logs/*.log
      {% if environment == 'local' -%}
      logs_permissions: vagrant vagrant
      {%- else -%}
      logs_permissions: www-data www-data
      {%- endif %}
    - template: jinja
    - require:
      - file: logrotate_directory
