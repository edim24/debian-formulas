sphinx-pkg:
  pkg.installed:
    - name: sphinxsearch

sphinx-autostart:
  file.replace:
    - name: /etc/default/sphinxsearch
    - pattern: START=no
    - repl: START=yes
    - flags: ['IGNORECASE']
    - append_if_not_found: True
    - backup: False
    - require:
      - pkg: sphinx-pkg
