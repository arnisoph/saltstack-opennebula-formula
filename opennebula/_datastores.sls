{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}

include:
  - opennebula
  - opennebula._oneuser

{% for d in salt['pillar.get']('opennebula:datastores', []) %}
  {% if d.type == 'nfs' %}
{{ d.name }}:
  file:
    - directory
    - name: {{ d.name }}
    - mode: {{ d.dirmode|default('755') }}
    - user: {{ d.user|default('oneadmin') }}
    - group: {{ d.group|default('oneadmin') }}
    - makedirs: {{ d.makedirs|default(True) }}
  mount:
    - mounted
    - name: {{ d.name }}
    - device: {{ d.source }}
    - fstype: {{ d.type }}
    - opts: {{ d.mount_opts|default('auto') }}
    - persist: {{ d.persist|default(True) }}
  {% endif %}
{% endfor %}
