{% from "optipng/map.jinja" import optipng with context %}

{% if salt['file.file_exists']('/srv/locks/optipng.' + optipng.version + '.lock') == False %}

optipng-libs:
  pkg.installed:
    - pkgs:
      - checkinstall

/usr/local/src/optipng:
  file.directory:
    - makedirs: True
    - clean: True

optipng-source:
  cmd.run:
    - name: wget http://downloads.sourceforge.net/project/optipng/OptiPNG/optipng-{{ optipng.version }}/optipng-{{ optipng.version }}.tar.gz
    - cwd: /usr/local/src/optipng/
    - require:
      - file: /usr/local/src/optipng

optipng-untar:
  cmd.run:
    - name: tar xvf optipng-{{ optipng.version }}.tar.gz
    - cwd: /usr/local/src/optipng/
    - require:
      - cmd: optipng-source

optipng-configure:
  cmd.run:
    - name: ./configure
    - cwd: /usr/local/src/optipng/optipng-{{ optipng.version }}/
    - require:
      - cmd: optipng-untar

optipng-make:
  cmd.run:
    - name: make
    - cwd: /usr/local/src/optipng/optipng-{{ optipng.version }}/
    - require:
      - cmd: optipng-configure

optipng-checkinstall:
  cmd.run:
    - name: sudo checkinstall -y
    - cwd: /usr/local/src/optipng/optipng-{{ optipng.version }}/
    - require:
      - cmd: optipng-make
      - pkg: optipng-libs

optipng-lock-file:
  file.touch:
    - name: /srv/locks/optipng.{{ optipng.version }}.lock
    - makedirs: true
    - require:
      - cmd: optipng-checkinstall

{% endif %}
