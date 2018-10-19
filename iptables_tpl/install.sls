{% from "iptables_tpl/map.jinja" import iptables_tpl with context %}

iptables_packages:
  pkg.installed:
  - pkgs:
    - iptables
    - iptables-persistent

iptables-rules-v4:
  file.managed:
  - name: /etc/iptables/rules.v4
  - source: {{ iptables_tpl.rules_v4_path }}
  - user: root
  - group: root
  - mode: 644
  - require:
    - pkg: iptables_packages

iptables-rules-v6:
  file.managed:
  - name: /etc/iptables/rules.v6
  - source: {{ iptables_tpl.rules_v6_path }}
  - user: root
  - group: root
  - mode: 644
  - require:
    - pkg: iptables_packages

iptables-restart:
  cmd.run:
  - name: service iptables-persistent restart
  - require:
    - file: iptables-rules-v4
    - file: iptables-rules-v6
