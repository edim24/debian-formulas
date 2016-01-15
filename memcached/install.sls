include:
  - php55

memcached:
  pkg.installed:
    - pkgs:
      - memcached
      - php5-memcache
    - require:
      - pkg: php55
