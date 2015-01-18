#!jinja|yaml

{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}

{% set config = datamap.sunstone.config|default({}) %}
{% set service = datamap.sunstone.service|default({}) %}

include: {{ salt['pillar.get']('opennebula:lookup:sunstone:sls_include', ['opennebula', 'opennebula._user_oneadmin']) }}
extend: {{ salt['pillar.get']('opennebula:lookup:sunstone:sls_extend', '{}') }}

sunstone:
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
      - pkg: sunstone

sunstone_novnc:
  service:
    - {{ datamap.novnc.service.ensure|default('running') }}
    - name: {{ datamap.novnc.service.name|default('opennebula-novnc') }}
    - enable: {{ datamap.novnc.service.enable|default(True) }}


{% for c in config.manage|default([]) %}
  {% set f = config[c]|default({}) %}
sunstone_config_{{ c }}:
  file:
    - {{ f.ensure|default('serialize') }}
    - name: {{ f.path }}
    - contents_pillar: opennebula:lookup:sunstone:config:{{ c }}:settings
    - formatter: YAML
    - user: {{ f.user|default('root') }}
    - group: {{ f.group|default('root') }}
    - mode: {{ f.mode|default('644') }}
    - watch_in:
      - service: sunstone
{% endfor %}


#{% set f_ulos = config.usr_lib_one_sunstone|default({}) %}
#/usr/lib/one/sunstone:
#  file:
#    - directory
#    - name: {{ f_ulos.path|default('/usr/lib/one/sunstone') }}
#    - user: {{ f_ulos.user|default('oneadmin') }}
#    - group: {{ f_ulos.group|default('oneadmin') }}
#    - recurse:
#{% for r in datamap['f_ulos.recurse']|default(['user', 'group']) %}
#      - {{ r }}
#{% endfor %}

