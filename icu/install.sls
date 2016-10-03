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

icu-src:
  cmd.run:
    - name: wget http://download.icu-project.org/files/icu4c/4.8.1.1/icu4c-4_8_1_1-src.tgz
    - cwd: /usr/src

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

icu-zoneinfo64.res:
  cmd.run:
    - name: wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/zoneinfo64.res
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - file: /usr/src/icu/source/data/in/

icu-append-zoneinfo64.res:
  cmd.run:
    - name: ../../bin/icupkg -a zoneinfo64.res icudt48l.dat
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - cmd: icu-icupkg-make
      - cmd: icu-zoneinfo64.res

icu-metaZones.res:
  cmd.run:
    - name: wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/metaZones.res
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - file: /usr/src/icu/source/data/in/

icu-append-metaZones.res:
  cmd.run:
    - name: ../../bin/icupkg -a metaZones.res icudt48l.dat
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - cmd: icu-icupkg-make
      - cmd: icu-metaZones.res

icu-timezoneTypes.res:
  cmd.run:
    - name: wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/timezoneTypes.res
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - file: /usr/src/icu/source/data/in/

icu-append-timezoneTypes.res:
  cmd.run:
    - name: ../../bin/icupkg -a timezoneTypes.res icudt48l.dat
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - cmd: icu-icupkg-make
      - cmd: icu-timezoneTypes.res

icu-windowsZones.res:
  cmd.run:
    - name: wget http://source.icu-project.org/repos/icu/data/trunk/tzdata/icunew/{{ icu.iana_tz_version_number }}/44/{{ icu.platform_directory }}/windowsZones.res
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - file: /usr/src/icu/source/data/in/

icu-append-windowsZones.res:
  cmd.run:
    - name: ../../bin/icupkg -a windowsZones.res icudt48l.dat
    - cwd: /usr/src/icu/source/data/in/
    - require:
      - cmd: icu-icupkg-make
      - cmd: icu-windowsZones.res

icu-make:
  cmd.run:
    - name: make
    - cwd: /usr/src/icu/source/
    - require:
      - cmd: icu-append-zoneinfo64.res
      - cmd: icu-append-metaZones.res
      - cmd: icu-append-timezoneTypes.res
      - cmd: icu-append-windowsZones.res

icu-mv:
  cmd.run:
    - name: mv /usr/lib/x86_64-linux-gnu/libicudata.so.48.1.1 /usr/lib/x86_64-linux-gnu/libicudata.so.48.1.1.old
    - require:
      - cmd: icu-make

icu-rm:
  cmd.run:
    - name: rm /usr/lib/x86_64-linux-gnu/libicudata.so.48
    - require:
      - cmd: icu-mv

icu-cp:
  cmd.run:
    - name: cp /usr/src/icu/source/lib/libicudata.so.48.1.1 /usr/lib/x86_64-linux-gnu/libicudata.so.48.1.1
    - require:
      - cmd: icu-rm

icu-ln:
  cmd.run:
    - name: ln -s /usr/lib/x86_64-linux-gnu/libicudata.so.48.1.1 /usr/lib/x86_64-linux-gnu/libicudata.so.48
    - require:
      - cmd: icu-cp

icu-lock-file:
  file.touch:
    - name: /srv/locks/icu.{{ icu.iana_tz_version_number }}.lock
    - makedirs: true
    - require:
      - cmd: icu-ln
    - watch_in:
      - service: php55-fpm-service

{% endif %}
