{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}

{% if datamap.repo.manage|default(True) == True %}
opennebula_repo: {# TODO: whack the hack #}
  pkgrepo:
    - managed
  {% if salt['grains.get']('os_family') == 'Debian' %}
    - name: deb {{ datamap.repo.url }} {{ datamap.repo.dist }} {{ datamap.repo.comps }}
    - file: /etc/apt/sources.list.d/opennebula.list
    - key_url: {{ datamap.repo.keyurl }}
  {% endif %}
{% endif %}

#opennebula: TODO: dbus?
#  pkg:
#    - installed
#    - pkgs:
#{% for p in datamap['controller']['pkgs'] %}
#      - {{ p }}
#{% endfor %}

#Service dbus?

{% if 'hostlist' in salt['pillar.get']('opennebula:salt:collect', []) %}
  {% set hosts = salt['publish.publish'](salt['pillar.get']('opennebula:salt:collect_hostlist:tgt', '*'), 'grains.item', ['fqdn'], 'compound') %}

  {% for k, v in hosts.items() %}
    {# TODO: support IPv6 #}
    {% set ipaddr = salt['dig.A'](v.fqdn)|first %} {# This will conflict with Round Robin A records #}
host-{{ v.fqdn }}_{{ ipaddr }}:
  host:
    - present
    - ip: {{ ipaddr }}
    - name: {{ v.fqdn }}
  {% endfor %}
{% endif %}
