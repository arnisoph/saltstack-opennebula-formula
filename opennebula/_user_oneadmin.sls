#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('opennebula', saltenv, ['yaml'])['yaml'] %}

oneadmin:
  user:
    - present
    - name: {{ datamap.oneadmin.name|default('oneadmin') }}
    - uid: {{ datamap.oneadmin.uid|default(9869) }}
    - gid: {{ datamap.oneadmin.uid|default(9869) }}
    - optional_groups: {{ datamap.oneadmin.optional_groups|default([]) }}
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
    - name: {{ datamap.oneadmin.home }}/.one
    - mode: {{ datamap.oneadmin.onedir_mode|default('700') }}
    - user: {{ datamap.oneadmin.onedir_owner|default('oneadmin') }}
    - group: {{ datamap.oneadmin.onedir_group|default('oneadmin') }}
    - require:
      - user: oneadmin

oneadmin_sshdir:
  file:
    - directory
    - name: {{ datamap.oneadmin.home }}/.ssh
    - mode: {{ datamap.oneadmin.sshdir_mode|default('700') }}
    - user: {{ datamap.oneadmin.sshdir_owner|default('oneadmin') }}
    - group: {{ datamap.oneadmin.sshdir_group|default('oneadmin') }}
    - require:
      - user: oneadmin

oneadmin_sshauthkeys:
  file:
    - managed
    - name: {{ datamap.oneadmin.home }}/.ssh/authorized_keys
    - mode: {{ datamap.oneadmin.sshauthkeysfile_mode|default('600') }}
    - user: {{ datamap.oneadmin.name|default('oneadmin') }}
    - group: {{ datamap.oneadmingroup.name|default('oneadmin') }}
    - require:
      - file: oneadmin_sshdir

{% if datamap.oneadmin.regenerate_ssh_keypair|default(False) %}
oneadmin_ssh_keypair:
  cmd:
    - run
    - name: {{ datamap.oneadmin.regenerate_ssh_keypair_cmd|default('ssh-keygen -q -b ' ~ datamap.oneadmin.ssh_bits|default('8192') ~ ' -t rsa -f ' ~ datamap.oneadmin.ssh_prvkey ~' -N "" && cat ' ~ datamap.oneadmin.ssh_pubkey ~ ' >> ' ~ datamap.oneadmin.home ~ '/.ssh/authorized_keys') }}
    - user: {{ datamap.oneadmin.name|default('oneadmin') }}
    - unless: test -e {{ datamap.oneadmin.ssh_prvkey }}
    - require:
      - user: oneadmin
      - file: oneadmin_sshauthkeys
{% endif %}

{% if datamap.oneadmin.manage_remotes|default(False) %}
  {% for remote in datamap.oneadmin.remotes.versions|default({}) %}
oneadmin_remotes_{{ remote.rev }}:
  git:
    - latest
    - name: {{ remote.src }}
    - user: {{ datamap.oneadmin.name|default('oneadmin') }}
    - rev: {{ datamap.oneadmin.remotes.rev|default('master') }}
    - target: {{ datamap.oneadmin.home }}/remotes_{{ remote.rev }}
  {% endfor %}

oneadmin_remotes_link_current:
  file:
    - symlink
    - name: {{ datamap.oneadmin.home }}/remotes
    - target: {{ datamap.oneadmin.home }}/remotes_{{ datamap.oneadmin.remotes.current_version }}/remotes
    - user: {{ datamap.oneadmin.name|default('oneadmin') }}
    - group: {{ datamap.oneadmingroup.name|default('oneadmin') }}
{% endif %}
