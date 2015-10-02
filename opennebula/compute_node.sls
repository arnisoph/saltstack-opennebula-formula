#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('opennebula', saltenv) %}

include: {{ salt['pillar.get']('opennebula:lookup:compute_node:sls_include', ['._user_oneadmin', '.orchestrate', '._datastores']) }}
extend: {{ salt['pillar.get']('opennebula:lookup:compute_node:sls_extend', '{}') }}

one_compute_node:
  pkg:
    - installed
    - pkgs: {{ datamap.compute_node.pkgs }}

#File /etc/udev/rules.d/80-kvm.rules
#File /etc/sudoers.d/10_oneadmin
