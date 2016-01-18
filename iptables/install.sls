{% from "iptables/map.jinja" import iptables with context %}

iptables_packages:
  pkg.installed:
    - pkgs:
      - iptables
      - iptables-persistent

{% for address in iptables.allowed_addresses %}
iptables_allow_address_{{ address }}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - source: {{ address }}
    - save: True
    - require:
      - pkg: iptables_packages
    - require_in:
      - iptables: enable_reject_policy
{% endfor %}

iptables_allow_icmp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - proto: icmp
    - save: True
    - require:
      - pkg: iptables_packages

iptables_allow_established:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: conntrack
    - ctstate: 'RELATED,ESTABLISHED'
    - save: True
    - require:
      - pkg: iptables_packages

{% for port in iptables.allowed_ports %}
iptables_allow_port_{{ port }}:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - dport: {{ port }}
    - proto: tcp
    - save: True
    - require:
      - pkg: iptables_packages
    - require_in:
      - iptables: iptables_enable_reject_policy
{% endfor %}

iptables_enable_reject_policy:
  iptables.set_policy:
    - table: filter
    - chain: INPUT
    - policy: DROP
    - require:
      - iptables: iptables_allow_established
      - iptables: iptables_allow_icmp