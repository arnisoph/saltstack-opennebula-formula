#!jinja|yaml

{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}

{% set service = datamap.oneflow.service|default({}) %}

include:
  - opennebula
  - opennebula.controller
  - opennebula._user_oneadmin

oneflow:
  pkg:
    - installed
    - pkgs: {{ datamap.oneflow.pkgs }}
    - require:
      - service: controller
  #TODO: use init script (http://dev.opennebula.org/issues/2183)
  #service:
    #- running
    #- name: {{ service.name|default('oneflow-server') }}
    #- enable: {{ service.enable|default(True) }}
    #TODO need to have executed install_gems
