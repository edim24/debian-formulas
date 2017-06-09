include:
  - php5x

imagemagick:
  pkg.installed:
    - pkgs:
      - php5-imagick
      - imagemagick
    - require:
      - pkg: php5x
