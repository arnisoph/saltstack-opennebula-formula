{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}
{% set config = datamap.sunstone.config|default({}) %}
{% set service = datamap.sunstone.service|default({}) %}

include:
  - opennebula

sunstone:
  pkg:
    - installed
    - pkgs:
{% for p in datamap['sunstone']['pkgs'] %}
      - {{ p }}
{% endfor %}
  service:
    - running
    - name: {{ service.name|default('opennebula-sunstone') }}
    - enable: {{ service.enable|default(True) }}

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

#/etc/one/sunstone-server.conf:
#/etc/one/sunstone-views/admin.yaml:
#/etc/one/sunstone-views.yaml:
