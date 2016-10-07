# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "capistrano/map.jinja" import capistrano with context %}

ruby:
  pkg.installed

capistrano:
  gem.installed:
    - version : {{ capistrano.version }}
    - require:
      - pkg: ruby
