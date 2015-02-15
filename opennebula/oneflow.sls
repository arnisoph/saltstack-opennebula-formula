#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('opennebula', saltenv, ['yaml'])['yaml'] %}
{% set service = datamap.oneflow.service|default({}) %}

include: {{ salt['pillar.get']('opennebula:lookup:oneflow:sls_include', ['.controller']) }}
extend: {{ salt['pillar.get']('opennebula:lookup:oneflow:sls_extend', '{}') }}

one_oneflow:
  pkg:
    - installed
    - pkgs: {{ datamap.oneflow.pkgs }}
    - require:
      - service: one_controller
  #TODO: use init script (http://dev.opennebula.org/issues/2183)
  #service:
    #- running
    #- name: {{ service.name|default('oneflow-server') }}
    #- enable: {{ service.enable|default(True) }}
    #TODO need to have executed install_gems
