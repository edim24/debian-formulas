# -*- coding: utf-8 -*-
# vim: ft=sls

{% if grains['os_family'] == 'Debian' %}

include:
  - dotdeb.install

{% endif %}
