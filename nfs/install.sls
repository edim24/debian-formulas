nfs-kernel-server:
  pkg.installed:
    - name: nfs-kernel-server
  file.managed:
    - name: /etc/exports
    - source: salt://files/exports
  service.running:
    - enable: True
    - name: nfs-kernel-server
    - require:
      - pkg: nfs-kernel-server
    - watch:
      - file: /etc/exports
