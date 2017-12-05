# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "capistrano/map.jinja" import capistrano with context %}

include:
  - curl

ruby-gpg:
  cmd.run:
    - name: curl -sSL https://rvm.io/mpapis.asc | sudo gpg --import -
    - require:
      - pkg: curl

ruby-2.0.0:
  rvm.installed:
    - default: True
    - require:
      - cmd: ruby-gpg

capistrano:
  gem.installed:
    - version : {{ capistrano.version }}
    - ruby: ruby-2.0.0
    - require:
      - rvm: ruby-2.0.0
