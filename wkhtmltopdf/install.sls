{% from "wkhtmltopdf/map.jinja" import wkhtmltopdf with context %}

wkhtmltopdf-fonts:
  pkg.installed:
    - pkgs:
      - xvfb
      - xfonts-75dpi

/usr/local/share/fonts/TrebuchetMS.ttf:
  file.managed:
    - source: salt://files/fonts/TrebuchetMS.ttf

/usr/local/share/fonts/TrebuchetMSBold.ttf:
  file.managed:
    - source: salt://files/fonts/TrebuchetMSBold.ttf

/usr/local/share/fonts/TrebuchetMSItalic.ttf:
  file.managed:
    - source: salt://files/fonts/TrebuchetMSItalic.ttf

/usr/local/share/fonts/TrebuchetMSBoldItalic.ttf:
  file.managed:
    - source: salt://files/fonts/TrebuchetMSBoldItalic.ttf

/usr/local/src/wkhtmltopdf:
  file.directory:
    - makedirs: True
    - clean: True

wkhtmltopdf-source:
  cmd.run:
    - name: wget {{ wkhtmltopdf.path }}{{ wkhtmltopdf.deb }}
    - unless: test -f {{ pillar['wkhtmltopdf']['deb'] }}
    - cwd: /usr/local/src/wkhtmltopdf
    - require_in:
      - file: /usr/local/src/wkhtmltopdf

wkhtmltopdf-install:
  pkg.installed:
    - unless: which wkhtmltopdf
    - sources:
      - wkhtmltopdf: /usr/local/src/wkhtmltopdf/{{ wkhtmltopdf.deb }}
    - require:
      - cmd: wkhtmltopdf-source
      - pkg: wkhtmltopdf-fonts
