#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('opennebula', saltenv, ['yaml'])['yaml'] %}
{% set config = datamap.controller.config|default({}) %}
{% set service = datamap.controller.service|default({}) %}

include: {{ salt['pillar.get']('opennebula:lookup:controller:sls_include', ['opennebula', 'opennebula._user_oneadmin']) }}
extend: {{ salt['pillar.get']('opennebula:lookup:controller:sls_extend', '{}') }}

one_controller:
  pkg:
    - installed
    - pkgs: {{ datamap.controller.pkgs }}
  service:
    - running
    - name: {{ service.name|default('opennebula') }}
    - enable: {{ service.enable|default(True) }}
    - require:
      - sls: opennebula._user_oneadmin
      - file: /usr/share/one/hooks


{% if salt['grains.get']('os_family') == 'Debian' and datamap.gems_setup.enabled != False %}
#install_gems: {# TODO: that fails, install the gems/pkgs yourself! #}
#  cmd:
#    - wait
#    - name: {{ datamap.gems_setup.cmd|default('/usr/share/one/install_gems') }}
#    - watch:
#      - pkg: controller
#    - require_in:
#      - service: controller
{% endif %}


{% set f_uso = config.usr_share_one|default({}) %}
/usr/share/one:
  file:
    - directory
    - name: {{ f_uso.path|default('/usr/share/one') }}
    - user: {{ f_uso.user|default('oneadmin') }}
    - group: {{ f_uso.group|default('oneadmin') }}
    - mode: {{ f_uso.mode|default('755') }}


{% set f_usoh = config.usr_share_one_hooks|default({}) %}
/usr/share/one/hooks:
  file:
    - recurse
    - name: {{ f_usoh.path|default('/usr/share/one/hooks') }}
    - source: {{ f_usoh.source|default('salt://opennebula/files/hookscripts') }}
    - user: {{ f_usoh.user|default('oneadmin') }}
    - group: {{ f_usoh.group|default('oneadmin') }}
    - file_mode: {{ f_usoh.file_mode|default('750') }}
    - dir_mode: {{ f_usoh.dir_mode|default('750') }}
    - clean: {{ f_usoh.clean|default(True) }}
    - exclude_pat: .gitignore
    - recurse: {{ datamap['f_usoh.recurse']|default(['user', 'group', 'file_mode', 'dir_mode']) }}
    - require:
      - file: /usr/share/one


{% for c in config['manage']|default([]) %}
  {% set f = config[c]|default({}) %}
one_controller_config_{{ c }}:
  file:
    - {{ f.ensure|default('managed') }}
    - name: {{ f.path }}
  {% if 'source' in f %}
    - source: {{ f.source }}
    - context: {{ f.context|default({}) }}
    - template: jinja
  {% else %}
    - contents_pillar: opennebula:lookup:controller:config:{{ c }}:contents
  {% endif %}
    - user: {{ f.user|default('oneadmin') }}
    - group: {{ f.group|default('oneadmin') }}
    - mode: {{ f.mode|default('644') }}
    - require:
      - sls: opennebula._user_oneadmin
    - watch_in:
      - service: one_controller
{% endfor %}
