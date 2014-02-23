{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}

include:
  - opennebula

compute_node:
  pkg:
    - installed
    - pkgs:
{% for p in datamap['compute_node']['pkgs'] %}
      - {{ p }}
{% endfor %}

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
