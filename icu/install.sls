{% from "icu/map.jinja" import icu with context %}

{% if salt['file.file_exists']('/srv/locks/icu.' + icu.iana_tz_version_number + '.lock') == False %}

include:
  - php

icu-packages:
  pkg.installed:
    - pkgs:
      - libicu-dev
      - gcc
      - g++
      - make
    - require:
      - pkg: php-extentions

icu-src-clear:
  file.absent:
    - name: /usr/src/icu

icu-src:
  cmd.run:
    - name: wget http://download.icu-project.org/files/icu4c/52.1/icu4c-52_1-src.tgz
    - creates: /usr/src/icu4c-52_1-src.tgz
    - cwd: /usr/src
    - require:
      - file: icu-src-clear

icu-untar:
  cmd.run:
    - name: tar xzf icu4c-52_1-src.tgz
    - cwd: /usr/src
    - require:
      - cmd: icu-src

/usr/src/icu/source/bin:
  file.directory:
    - makedirs: True
    - require:
      - cmd: icu-untar

icu-configure:
  cmd.run:
    - name: ./configure
    - cwd: /usr/src/icu/source
    - require:
      - pkg: icu-packages
      - file: /usr/src/icu/source/bin

icu-icupkg-make:
  cmd.run:
    - name: make
    - cwd: /usr/src/icu/source/tools/icupkg/
    - require:
      - cmd: icu-configure

icu-download-res-files:
  cmd.run:
    - names:
      - wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/zoneinfo64.res
      - wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/metaZones.res
      - wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/timezoneTypes.res
      - wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/windowsZones.res
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - cmd: icu-icupkg-make

icu-append-res-files:
  cmd.run:
    - names:
      - ../../bin/icupkg -a zoneinfo64.res icudt52l.dat
      - ../../bin/icupkg -a metaZones.res icudt52l.dat
      - ../../bin/icupkg -a timezoneTypes.res icudt52l.dat
      - ../../bin/icupkg -a windowsZones.res icudt52l.dat
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - cmd: icu-download-res-files

icu-make:
  cmd.run:
    - name: make
    - cwd: /usr/src/icu/source/
    - require:
      - cmd: icu-append-res-files

icu-rm-so:
  cmd.run:
    - name: rm /usr/lib/x86_64-linux-gnu/libicudata.so.52.1
    - require:
      - cmd: icu-make

icu-cp-so:
  cmd.run:
    - name: cp /usr/src/icu/source/lib/libicudata.so.52.1 /usr/lib/x86_64-linux-gnu/libicudata.so.52.1
    - require:
      - cmd: icu-rm-so

icu-lock-file:
  file.touch:
    - name: /srv/locks/icu.{{ icu.iana_tz_version_number }}.lock
    - makedirs: true
    - require:
      - cmd: icu-cp-so
    - watch_in:
      - service: php-fpm-service

{% endif %}
