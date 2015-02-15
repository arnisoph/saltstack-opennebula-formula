#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('opennebula', saltenv, ['yaml'])['yaml'] %}

include:
  - opennebula._user_oneadmin

{% for d in datamap.datastores|default([]) if d.type == 'nfs'%}
one_datastore_{{ d.name }}:
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
    - opts: {{ d.opts|default('auto') }}
    - persist: {{ d.persist|default(True) }}
{% endfor %}
