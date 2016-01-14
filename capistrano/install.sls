# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "capistrano/map.jinja" import capistrano with context %}

{% if 1 == salt['cmd.retcode']('test -f /srv/locks/capistrano.' + capistrano.version +'.lock') %}

ruby:
  pkg.installed:
    - name: ruby1.9.3

rubygems:
  pkg.installed:
    - name: rubygems

net-ssh:
  gem.installed:
    - name: net-ssh
    - version : 2.9.2
    - require:
      - pkg: ruby
      - pkg: rubygems

capistrano:
  gem.installed:
    - name : capistrano
    - version : {{ capistrano.version }}
    - require:
      - gem: net-ssh

capistrano-lock-file:
  file.touch:
    - name: /srv/locks/capistrano.{{ capistrano.version }}.lock
    - makedirs: true
    - require:
      - gem: capistrano

{% endif %}
