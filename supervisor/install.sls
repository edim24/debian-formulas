{% from "supervisor/map.jinja" import environment with context %}
{% from "supervisor/map.jinja" import app_dir with context %}
{% from "supervisor/map.jinja" import supervisor with context %}

supervisor:
  pkg:
    - installed
  service.running:
    - enable: True
    - require:
      - pkg: supervisor

/etc/supervisor/conf.d:
  file.directory:
    - clean: True

{% for worker, params in supervisor.get('workers', {}).items() %}
/etc/supervisor/conf.d/{{ worker }}.conf:
  file.managed:
    - source: salt://supervisor/worker.conf
    - context:
      program: {{ worker }}
      {% if environment == 'local' -%}
      directory: {{ app_dir }}
      {%- else -%}
      directory: {{ app_dir }}deploy/current/
      {%- endif %}
      command: {{ params['command'] }}
      numprocs: {{ params['numprocs'][environment] }}
      logs_dir: {{ supervisor.get('logs_dir') }}
    - template: jinja
    - makedirs: True
    - require_in:
      - file: /etc/supervisor/conf.d

{% endfor %}
