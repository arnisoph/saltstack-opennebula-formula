#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('opennebula', saltenv, ['yaml'])['yaml'] %}

include: {{ salt['pillar.get']('opennebula:lookup:compute_node:sls_include', ['opennebula', 'opennebula._user_oneadmin', 'opennebula._datastores']) }}
extend: {{ salt['pillar.get']('opennebula:lookup:compute_node:sls_extend', '{}') }}

one_compute_node:
  pkg:
    - installed
    - pkgs: {{ datamap.compute_node.pkgs }}

#TODO: require libvirt config + service

#File /etc/libvirt/libvirtd.conf
#File libvirtd_cfg
#File /etc/udev/rules.d/80-kvm.rules
#File /var/lib/one/.ssh/authorized_keys
#File /var/lib/one/.ssh/config
#File /etc/sudoers.d/10_oneadmin
#File /sbin/brctl
#File /etc/libvirt/qemu.conf
#FIle /var/lib/one/.virtinst
