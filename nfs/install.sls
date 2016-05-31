{% from "nfs/map.jinja" import nfs with context %}

nfs-exports-file:
  file.managed:
    - name: /etc/exports
    - contents_pillar: nfs:exports

nfs-kernel-server:
  pkg.installed:
    - require:
      - file: nfs-exports-file
  service.running:
    - enable: True
    - require:
      - pkg: nfs-kernel-server
    - watch:
      - file: /etc/exports
