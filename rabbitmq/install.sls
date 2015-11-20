rabbitmq-repo:
  pkgrepo.managed:
    - name: "deb http://www.rabbitmq.com/debian/ testing main"
    - key_url: "http://www.rabbitmq.com/rabbitmq-signing-key-public.asc"

rabbitmq-server:
  pkg.latest:
    - require:
      - pkgrepo: rabbitmq-repo
  service.running:
    - require:
      - pkg: rabbitmq-server
