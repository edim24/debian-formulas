# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "capistrano/map.jinja" import capistrano with context %}

ruby-2.0.0:
  rvm.installed:
    - default: True

capistrano:
  gem.installed:
    - version : {{ capistrano.version }}
    - ruby: ruby-2.0.0
    - require:
      - rvm: ruby-2.0.0
