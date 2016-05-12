include:
  - php55

graphviz:
  pkg.installed

php5-xhprof:
  pkg:
    - installed
    - require:
      - pkg: graphviz
      - pkg: php55

{{ pillar['app_dir'] }}public/xhprof:
  file.symlink:
    - target: {{ pillar['app_dir'] }}vendor/lox/xhprof/xhprof_html/
    - user: {{ pillar['user'] }}
    - group: {{ pillar['group'] }}
    - require:
      - cmd: composer-install
