{% from "icu/map.jinja" import icu with context %}

{% if salt['file.file_exists']('/srv/locks/icu.' + icu.iana_tz_version_number + '.lock') == False %}

include:
  - php55

icu-packages:
  pkg.installed:
    - pkgs:
      - libicu-dev
      - gcc
      - g++
      - make
    - require:
      - pkg: php55-extentions

icu-src-clear:
  file.absent:
    - name: /usr/src/icu

icu-src:
  cmd.run:
    - name: wget http://download.icu-project.org/files/icu4c/4.8.1.1/icu4c-4_8_1_1-src.tgz
    - creates: /usr/src/icu4c-4_8_1_1-src.tgz
    - cwd: /usr/src
    - require:
      - file: /usr/src/icu

icu-untar:
  cmd.run:
    - name: tar xzf icu4c-4_8_1_1-src.tgz
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

/usr/src/icu/source/data/in/:
  file.directory:
    - makedirs: True
    - require:
      - cmd: icu-untar

icu-download-res-files:
  cmd.run:
    - names:
      - wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/zoneinfo64.res
      - wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/metaZones.res
      - wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/timezoneTypes.res
      - wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/windowsZones.res
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - file: /usr/src/icu/source/data/in/
      - cmd: icu-icupkg-make

icu-append-res-files:
  cmd.run:
    - names:
      - ../../bin/icupkg -a zoneinfo64.res icudt48l.dat
      - ../../bin/icupkg -a metaZones.res icudt48l.dat
      - ../../bin/icupkg -a timezoneTypes.res icudt48l.dat
      - ../../bin/icupkg -a windowsZones.res icudt48l.dat
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
    - name: rm /usr/lib/x86_64-linux-gnu/libicudata.so.48.1.1
    - require:
      - cmd: icu-make

icu-cp-so:
  cmd.run:
    - name: cp /usr/src/icu/source/lib/libicudata.so.48.1.1 /usr/lib/x86_64-linux-gnu/libicudata.so.48.1.1
    - require:
      - cmd: icu-rm-so

icu-rm-ln:
  cmd.run:
    - name: rm /usr/lib/x86_64-linux-gnu/libicudata.so.48
    - require:
      - cmd: icu-cp-so

icu-ln:
  cmd.run:
    - name: ln -s /usr/lib/x86_64-linux-gnu/libicudata.so.48.1.1 /usr/lib/x86_64-linux-gnu/libicudata.so.48
    - require:
      - cmd: icu-rm-ln

icu-lock-file:
  file.touch:
    - name: /srv/locks/icu.{{ icu.iana_tz_version_number }}.lock
    - makedirs: true
    - require:
      - cmd: icu-ln
    - watch_in:
      - service: php55-fpm-service

{% endif %}
