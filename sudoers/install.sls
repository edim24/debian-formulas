{% from "sudoers/map.jinja" import sudoers with context %}

sudoers:
  file.managed:
    - name: /etc/sudoers
    - user: root
    - group: root
    - mode: 440

sudoers-block:
  file.blockreplace:
    - name: /etc/sudoers
    - marker_start: "# START SALT SUDOERS BLOCK -DO-NOT-EDIT-"
    - marker_end: "# END SALT SUDOERS BLOCK --"
    - content: |{% for username, commands in sudoers.commands.items() %}
        {{ username }} ALL=(ALL) NOPASSWD: {{ commands }}{% endfor %}
    - append_if_not_found: True
    - backup: False
    - show_changes: False
    - require:
      - file: sudoers
