{% from "locales/map.jinja" import locales with context %}

{% for locale in locales.get('all', []) %}

{{ locale }}_locale:
  locale.present:
    - name: {{ locale }}

{% endfor %}

default_locale:
  locale.system:
    - name: {{ locales.system }}
    - require:
      - locale: {{ locales.system }}_locale
