{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}
{% set config = datamap.oned.config|default({}) %}
{% set service = datamap.oned.service|default({}) %}

include:
  - opennebula
  - opennebula._oneuser

oned:
  pkg:
    - installed
    - pkgs:
{% for p in datamap['oned']['pkgs'] %}
      - {{ p }}
{% endfor %}
  service:
    - running
    - name: {{ service.name|default('opennebula') }}
    - enable: {{ service.enable|default(True) }}
    - watch:
      - file: oned_conf
    - require:
      - sls: opennebula._oneuser
      - file: oned_conf
      - file: /usr/share/one
      - file: /usr/share/one/hooks

{% if salt['grains.get']('os_family') == 'Debian' and datamap.gems_setup.enabled != False %}
install_gems: {# TODO: that fails, fix it! #}
  cmd:
    - wait
    - name: {{ datamap.gems_setup.cmd|default('/usr/share/one/install_gems') }}
    - watch:
      - pkg: oned
    - require_in:
      - service: oned
{% endif %}

{% set f_o = config.oned_conf|default({}) %}
oned_conf:
  file:
    - managed
    - name: {{ f_o.path|default('/etc/one/oned.conf') }}
    - source: {{ f_o.template_path|default('salt://opennebula/files/oned.conf') }}
    - template: {{ f_o.template_renderer|default('jinja') }}
    - mode: {{ f_o.mode|default('640') }}
    - user: {{ f_o.user|default('root') }}
    - group: {{ f_o.group|default('oneadmin') }}
    - require:
      - pkg: oned

{% set f_uso = config.usr_share_one|default({}) %}
/usr/share/one:
  file:
    - directory
    - name: {{ f_uso.path|default('/usr/share/one') }}
    - mode: {{ f_uso.mode|default('755') }}
    - user: {{ f_uso.user|default('oneadmin') }}
    - group: {{ f_uso.group|default('oneadmin') }}

{% set f_usoh = config.usr_share_one_hooks|default({}) %}
/usr/share/one/hooks:
  file:
    - recurse
    - name: {{ f_usoh.path|default('/usr/share/one/hooks') }}
    - source: {{ f_usoh.source|default('salt://opennebula/files/hookscripts') }}
    - file_mode: {{ f_usoh.file_mode|default('750') }}
    - dir_mode: {{ f_usoh.dir_mode|default('750') }}
    - user: {{ f_usoh.user|default('oneadmin') }}
    - group: {{ f_usoh.group|default('oneadmin') }}
    - clean: {{ f_usoh.clean|default(True) }}
    - recurse:
{% for r in datamap['f_usoh.recurse']|default(['user', 'group', 'file_mode', 'dir_mode']) %}
      - {{ r }}
{% endfor %}
