#!jinja|yaml

{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}

{% from "opennebula/files/sunstone/server.yaml" import f_ss_config_default with context %}
{% set config = datamap.sunstone.config|default({}) %}
{% set service = datamap.sunstone.service|default({}) %}

include:
  - opennebula
  - opennebula._user_oneadmin
{% for si in salt['pillar.get']('opennebula:lookup:sunstone:sls_include', []) %}
  - {{ si }}
{% endfor %}

extend: {{ salt['pillar.get']('opennebula:lookup:sunstone:sls_extend', '{}') }}
{#
{-% for k, v in salt['pillar.get']('opennebula:lookup:sunstone:sls_extend', {}).items() }-}
  {-{ k }-}: {-{ v }-}
{-% endfor }-}
#}


sunstone:
  pkg:
    - installed
    - pkgs:
{% for p in datamap.sunstone.pkgs %}
      - {{ p }}
{% endfor %}
    - require:
      - user: oneadmin
  service:
    - {{ service.state|default('running') }}
    - name: {{ service.name|default('opennebula-sunstone') }}
    - enable: {{ service.enable|default(True) }}
    {# TODO: service doesn't have a status command. Is this Debian specifc? #}
    - sig: {{ service.psname|default('sunstone-server.rb') }}
    - require:
      - pkg: sunstone

{% set f_ss = config.sunstone_server|default({}) %}
{% if f_ss.manage|default(True) == True %}
sunstone_server_conf: {# TODO: move to sunstone ^ ? #}
  file:
    #- serialize
    - managed
    - name: {{ f_ss.path|default('/etc/one/sunstone-server.conf') }}
    #- dataset: {# salt['pillar.get']('opennebula:lookup:sunstone:config:sunstone_server:content', f_ss_config_default) #}
    - contents_pillar: opennebula:lookup:sunstone:config:sunstone_server:content
    #- formatter: YAML
    - mode: {{ f_ss.mode|default('644') }}
    - user: {{ f_ss.user|default('root') }}
    - group: {{ f_ss.group|default('root') }}
    - watch_in:
      - service: sunstone
{% endif %}

{% set f_sv = config.sunstone_views|default({}) %}
{% if f_sv.manage|default(False) == True %}
sunstone_views_conf:
  file:
    - managed
    #TODO buggy: - serialize
    - name: {{ f_sv.path|default('/etc/one/sunstone-views.yaml') }}
    #- dataset: {# salt['pillar.get']('opennebula:lookup:sunstone:config:sunstone_views:content', f_sv_config_default)|yaml #}
    - contents_pillar: opennebula:lookup:sunstone:config:sunstone_views:content
    #- formatter: YAML
    - mode: {{ f_sv.mode|default('644') }}
    - user: {{ f_sv.user|default('root') }}
    - group: {{ f_sv.group|default('root') }}
    - watch_in:
      - service: sunstone
{% endif %}

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

{% set f_nv = datamap.novnc|default({}) %}
{% if f_nv.manage|default(True) == True %}
novnc_servicescript:
  file:
    - managed
    - name: {{ f_nv.service.servicepath|default('/etc/init.d/opennebula-novnc') }}
    - source: {{ f_nv.service.template_path|default('salt://opennebula/files/novnc/init_novnc') }}
    - mode: {{ f_nv.mode|default('755') }}
    - user: {{ f_nv.user|default('root') }}
    - group: {{ f_nv.group|default('root') }}
{% endif %}

novnc_service:
  service:
    - {{ f_nv.service.state|default('running') }}
    - name: {{ f_nv.service.name|default('opennebula-novnc') }}
    - enable: {{ f_nv.service.enable|default(True) }}
