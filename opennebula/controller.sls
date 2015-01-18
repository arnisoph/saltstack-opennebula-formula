#!jinja|yaml

{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}

{% set config = datamap.controller.config|default({}) %}
{% set service = datamap.controller.service|default({}) %}

include:
  - opennebula
  - opennebula._user_oneadmin

controller:
  pkg:
    - installed
    - pkgs: {{ datamap.controller.pkgs }}
  service:
    - running
    - name: {{ service.name|default('opennebula') }}
    - enable: {{ service.enable|default(True) }}
    - watch:
      - file: oned_conf
    - require:
      - sls: opennebula._user_oneadmin
      - file: /usr/share/one
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

{% set f_o = config.oned_conf|default({}) %}
oned_conf:
  file:
    - managed
    - name: {{ f_o.path|default('/etc/one/oned.conf') }}
    - source: {{ f_o.template_path|default('salt://opennebula/files/oned.conf') }}
    - template: {{ f_o.template_renderer|default('jinja') }}
    - user: {{ f_o.user|default('root') }}
    - group: {{ f_o.group|default('oneadmin') }}
    - mode: {{ f_o.mode|default('640') }}

{% set f_ovek = config.one_vmm_exec_kvm|default({}) %}
{% if f_ovek.manage|default(False) %}
one_vmm_exec_kvm:
  file:
    - managed
    - name: {{ f_ovek.path|default('/etc/one/vmm_exec/vmm_exec_kvm.conf') }}
    - source: {{ f_ovek.template_path|default('salt://opennebula/files/vmm_exec/vmm_exec_kvm.conf') }}
    - user: {{ f_ovek.user|default('root') }}
    - group: {{ f_ovek.group|default('root') }}
    - mode: {{ f_ovek.mode|default('644') }}
    - watch_in:
      - service: controller
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

{% set f_oa = config.one_auth|default({}) %}
{% if f_oa.manage|default(False) %}
one_auth:
  file:
    - managed
    - name: {{ f_oa.path|default('/var/lib/one/.one/one_auth') }}
    - contents_pillar: opennebula:lookup:controller:config:one_auth:content
    - user: {{ f_oa.user|default('oneadmin') }}
    - group: {{ f_oa.group|default('oneadmin') }}
    - mode: {{ f_oa.mode|default('600') }}
    - require_in:
      - pkg: controller
    - require:
      - sls: opennebula._user_oneadmin
{% endif %}
