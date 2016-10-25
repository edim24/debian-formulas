{% from "wkhtmltopdf/map.jinja" import wkhtmltopdf with context %}

{% if salt['file.file_exists']('/srv/locks/wkhtmltopdf.' + wkhtmltopdf.version + '.lock') == False %}

wkhtmltopdf-src-clear:
  file.absent:
    - name: /usr/src/wkhtmltox

wkhtmltopdf-src:
  cmd.run:
    - name: wget http://download.gna.org/wkhtmltopdf/0.12/{{ wkhtmltopdf.version }}/wkhtmltox-{{ wkhtmltopdf.version }}_linux-generic-amd64.tar.xz
    - creates: /usr/src/wkhtmltox-{{ wkhtmltopdf.version }}_linux-generic-amd64.tar.xz
    - cwd: /usr/src
    - require:
      - file: wkhtmltopdf-src-clear

wkhtmltopdf-untar:
  cmd.run:
    - name: tar xvf wkhtmltox-{{ wkhtmltopdf.version }}_linux-generic-amd64.tar.xz
    - cwd: /usr/src
    - require:
      - cmd: wkhtmltopdf-src

wkhtmltopdf-rm-bin:
  cmd.run:
    - name: rm -f /usr/bin/wkhtmlto*
    - require:
      - cmd: wkhtmltopdf-untar

wkhtmltopdf-cp-bin:
  cmd.run:
    - name: cp /usr/src/wkhtmltox/bin/wkhtmlto* /usr/bin/
    - require:
      - cmd: wkhtmltopdf-rm-bin

/usr/local/share/fonts/TrebuchetMS.ttf:
  file.managed:
    - source: salt://wkhtmltopdf/fonts/TrebuchetMS.ttf

/usr/local/share/fonts/TrebuchetMSBold.ttf:
  file.managed:
    - source: salt://wkhtmltopdf/fonts/TrebuchetMSBold.ttf

/usr/local/share/fonts/TrebuchetMSItalic.ttf:
  file.managed:
    - source: salt://wkhtmltopdf/fonts/TrebuchetMSItalic.ttf

/usr/local/share/fonts/TrebuchetMSBoldItalic.ttf:
  file.managed:
    - source: salt://wkhtmltopdf/fonts/TrebuchetMSBoldItalic.ttf

wkhtmltopdf-lock-file:
  file.touch:
    - name: /srv/locks/wkhtmltopdf.{{ wkhtmltopdf.version }}.lock
    - makedirs: true
    - require:
      - cmd: wkhtmltopdf-cp-bin

{% endif %}
