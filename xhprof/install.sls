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