# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "crontab/map.jinja" import crontab with context %}

{% for user, crons in crontab %}

crontab-{{ user }}:
  cron.file:
    - name: salt://crontab/crontab.tpl
    - user: {{ user }}
    - template: jinja
    - context:
        crons: |{% for cron in crons %}
          {{ cron }}{% endfor %}

{% endfor %}
