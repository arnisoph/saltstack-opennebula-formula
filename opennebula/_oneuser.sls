{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}

include:
  - opennebula

oneadmin:
  user:
    - present
    - name: {{ datamap.oneadmin.name|default('oneadmin') }}
    - uid: {{ datamap.oneadmin.uid|default(9869) }}
    - gid: {{ datamap.oneadmin.uid|default(9869) }}
    - home: {{ datamap.oneadmin.home }}
    - shell: {{ datamap.oneadmin.shell|default('/bin/bash') }}
    - createhome: True
    - system: True
    - require:
      - group: oneadmin
  group:
    - present
    - name: {{ datamap.oneadmingroup.name|default('oneadmin') }}
    - gid: {{ datamap.oneadmin.name|default(9869) }}
    - system: True
  file:
    - directory
    - name: {{ datamap.oneadmin.home ~ '/.one' }}
    - mode: {{ datamap.oneadmin.onedir_mode|default('700') }}
    - user: {{ datamap.oneadmin.onedir_owner|default('oneadmin') }}
    - group: {{ datamap.oneadmin.onedir_group|default('oneadmin') }}
    - require:
      - user: oneadmin

{% if salt['file.file_exists'](datamap.oneadmin.ssh_pubkey) == False or
(datamap.oneadmin.regenerate_ssh_keypair|default(False) == True and salt['file.file_exists'](datamap.oneadmin.ssh_pubkey_old) == False) %}

  {% if salt['file.file_exists'](datamap.oneadmin.ssh_pubkey) == True %}
    {% do salt['file.rename'](datamap.oneadmin.ssh_pubkey, datamap.oneadmin.ssh_pubkey_old) %}
    {% do salt['file.rename'](datamap.oneadmin.ssh_prvkey, datamap.oneadmin.ssh_prvkey_old) %}
    {% do salt['file.set_mode'](datamap.oneadmin.ssh_prvkey_old, '600') %}
    {% do salt['file.set_mode'](datamap.oneadmin.ssh_pubkey_old, '644') %}
  {% endif %}

oneadmin_ssh_keypair:
  cmd:
    - run
    - name: {{ datamap.oneadmin.regenerate_ssh_keypair_cmd|default('ssh-keygen -q -b ' ~ datamap.oneadmin.ssh_bits|default('8192') ~ ' -t rsa -f ' ~ datamap.oneadmin.ssh_prvkey ~' -N ""') }} {# TODO require rng-tools running #}
    - user: {{ datamap.oneadmin.name|default('oneadmin') }}
    - require:
      - user: {{ datamap.oneadmin.name|default('oneadmin') }}
{% endif %}


