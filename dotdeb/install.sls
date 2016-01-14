php-dotdeb:
  pkgrepo.managed:
    - name: deb http://packages.dotdeb.org wheezy-php55 all
    - file: /etc/apt/sources.list
    - key_url: http://www.dotdeb.org/dotdeb.gpg
