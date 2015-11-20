{% if 1 == salt['cmd.retcode']('test -f /srv/locks/nodesource.lock') %}

add-nodejs-repo:
  cmd.run:
    - name: 'curl -sL https://deb.nodesource.com/setup | bash -'

nodejs-lock-file:
  file.touch:
    - name: /srv/locks/nodesource.lock
    - makedirs: true
    - require:
      - cmd: add-nodejs-repo

{% endif %}

nodejs:
  pkg.installed:
    - pkgs:
      - nodejs

npm-modules:
  npm:
    - installed
    - names:
      - grunt-cli
      - bower
      - uglify-js
    - runas: root
    - require:
      - pkg: nodejs
