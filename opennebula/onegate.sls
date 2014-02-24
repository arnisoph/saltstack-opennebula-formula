{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}
{% set service = datamap.onegate.service|default({}) %}

include:
  - opennebula
  - opennebula.oned
  - opennebula._oneuser

onegate:
  pkg:
    - installed
    - pkgs:
{% for p in datamap['onegate']['pkgs'] %}
      - {{ p }}
{% endfor %}
    - require:
      - service: oned
  #TODO: use init script (http://dev.opennebula.org/issues/2183)
  #service:
    #- running
    #- name: {{ service.name|default('onegate-server') }}
    #- enable: {{ service.enable|default(True) }}
    #TODO need to have executed install_gems
