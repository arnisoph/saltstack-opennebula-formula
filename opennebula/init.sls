#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('opennebula', saltenv, ['yaml'])['yaml'] %}

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
