#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('opennebula', saltenv) %}
{% set service = datamap.onegate.service|default({}) %}

include: {{ salt['pillar.get']('opennebula:lookup:onegate:sls_include', ['.controller']) }}
extend: {{ salt['pillar.get']('opennebula:lookup:onegate:sls_extend', '{}') }}

one_onegate:
  pkg:
    - installed
    - pkgs: {{ datamap.onegate.pkgs }}
    - require:
      - service: one_controller
  #TODO: use init script (http://dev.opennebula.org/issues/2183)
  #service:
    #- running
    #- name: {{ service.name|default('onegate-server') }}
    #- enable: {{ service.enable|default(True) }}
    #TODO need to have executed install_gems
