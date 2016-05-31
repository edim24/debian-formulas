{% from "nfs/map.jinja" import nfs with context %}

nfs-exports-file:
  file.managed:
    - name: /etc/exports
    - contents: {{ nfs.get(exports, []) }}

nfs-kernel-server:
  pkg.installed:
    - require:
      - file: nfs-exports-file

nfs-kernel-server:
  service.running:
    - enable: True
    - require:
      - pkg: nfs-kernel-server
    - watch:
      - file: /etc/exports
