include:
  - php55

imagemagick:
  pkg.installed:
    - pkgs:
      - php5-imagick
      - imagemagick
    - require:
      - pkg: php55
