include:
  - php5x

graphviz:
  pkg.installed

php5-xhprof:
  pkg:
    - installed
    - require:
      - pkg: graphviz
      - pkg: php5x
