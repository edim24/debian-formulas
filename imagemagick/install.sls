include:
  - php

imagemagick:
  pkg.installed:
    - pkgs:
      - php7.0-imagick
      - imagemagick
    - require:
      - pkg: php
