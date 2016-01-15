{% from "wkhtmltopdf/map.jinja" import wkhtmltopdf with context %}

wkhtmltopdf-fonts:
  pkg.installed:
    - pkgs:
      - xvfb
      - xfonts-75dpi

/usr/local/src/wkhtmltopdf:
  file.directory:
    - makedirs: True
    - clean: True

wkhtmltopdf-source:
  cmd.run:
    - name: wget {{ wkhtmltopdf.path }}{{ wkhtmltopdf.deb }}
    - unless: test -f {{ pillar['wkhtmltopdf']['deb'] }}
    - cwd: /usr/local/src/wkhtmltopdf
    - require:
      - file: /usr/local/src/wkhtmltopdf

wkhtmltopdf-install:
  cmd.run:
    - name: sudo dpkg -i {{ wkhtmltopdf.deb }}
    - unless: which wkhtmltopdf
    - cwd: /usr/local/src/wkhtmltopdf
    - require:
      - cmd: wkhtmltopdf-source

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
