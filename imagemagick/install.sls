include:
  - php

imagemagick:
  pkg.installed:
    - pkgs:
      - php7.1-imagick
      - imagemagick
    - require:
      - pkg: php
