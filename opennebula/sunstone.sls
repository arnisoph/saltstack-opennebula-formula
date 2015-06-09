#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('opennebula', saltenv, ['yaml'])['yaml'] %}
{% set config = datamap.sunstone.config|default({}) %}
{% set service = datamap.sunstone.service|default({}) %}

include: {{ salt['pillar.get']('opennebula:lookup:sunstone:sls_include', ['._user_oneadmin']) }}
extend: {{ salt['pillar.get']('opennebula:lookup:sunstone:sls_extend', '{}') }}

one_sunstone:
  pkg:
    - installed
    - pkgs: {{ datamap.sunstone.pkgs }}
    - require:
      - user: oneadmin
  service:
    - {{ service.ensure|default('running') }}
    - name: {{ service.name|default('opennebula-sunstone') }}
    - enable: {{ service.enable|default(True) }}
    - require:
      - pkg: one_sunstone

one_sunstone_novnc:
  service:
    - {{ datamap.novnc.service.ensure|default('running') }}
    - name: {{ datamap.novnc.service.name|default('opennebula-novnc') }}
    - enable: {{ datamap.novnc.service.enable|default(True) }}

{% for c in config.manage|default([]) %}
  {% set f = config[c]|default({}) %}
one_sunstone_config_{{ c }}:
  file:
    - {{ f.ensure|default('serialize') }}
    - name: {{ f.path }}
    - dataset_pillar: opennebula:lookup:sunstone:config:{{ c }}:config
    - formatter: YAML
    - user: {{ f.user|default('root') }}
    - group: {{ f.group|default('oneadmin') }}
    - mode: {{ f.mode|default('640') }}
    - watch_in:
      - service: one_sunstone
{% endfor %}
