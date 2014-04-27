{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}
{% from "opennebula/files/sunstone/server.yaml" import f_ss_config_default with context %}
{% set config = datamap.sunstone.config|default({}) %}
{% set service = datamap.sunstone.service|default({}) %}

include:
  - opennebula
  - opennebula._oneuser

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
    - serialize
    - name: {{ f_ss.path|default('/etc/one/sunstone-server.conf') }}
    - dataset: {{ salt['pillar.get']('opennebula:lookup:sunstone:config:sunstone_server:content', f_ss_config_default) }}
    - formatter: YAML
    - mode: {{ f_ss.mode|default('644') }}
    - user: {{ f_ss.user|default('root') }}
    - group: {{ f_ss.group|default('root') }}
    - watch_in:
      - service: sunstone
    - require_in:
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

# flow/gate:
#/etc/one/sunstone-server.conf:
#/etc/one/sunstone-views/admin.yaml:
#/etc/one/sunstone-views.yaml:
