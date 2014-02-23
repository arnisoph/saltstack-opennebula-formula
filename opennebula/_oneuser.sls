{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}

include:
  - opennebula

oneuser_home:
  file:
    - directory
    - name: {{ datamap.oneuser.home }}
    - mode: {{ datamap.oneuser.home_mode|default('755') }}
    - user: {{ datamap.oneuser.home_owner|default('oneadmin') }}
    - group: {{ datamap.oneuser.home_group|default('oneadmin') }}

{% if salt['file.file_exists'](datamap.oneuser.ssh_pubkey) == False or
(datamap.oneuser.regenerate_ssh_keypair == True and salt['file.file_exists'](datamap.oneuser.ssh_pubkey_old) == False) %}

  {% if salt['file.file_exists'](datamap.oneuser.ssh_pubkey) == True %}
    {% do salt['file.rename'](datamap.oneuser.ssh_pubkey, datamap.oneuser.ssh_pubkey_old) %}
    {% do salt['file.rename'](datamap.oneuser.ssh_prvkey, datamap.oneuser.ssh_prvkey_old) %}
    {% do salt['file.set_mode'](datamap.oneuser.ssh_prvkey_old, '600') %}
    {% do salt['file.set_mode'](datamap.oneuser.ssh_pubkey_old, '644') %}
  {% endif %}

oneuser_ssh_keypair:
  cmd:
    - run
    - name: {{ datamap.oneuser.regenerate_ssh_keypair_cmd|default('ssh-keygen -q -b ' ~ datamap.oneuser.ssh_bits|default('8192') ~ ' -t rsa -f ' ~ datamap.oneuser.ssh_prvkey ~' -N ""') }} {# TODO require rng-tools running #}
    - user: {{ datamap.oneuser.name|default('oneadmin') }}
    - require:
      - file: oneuser_home
{% endif %}


