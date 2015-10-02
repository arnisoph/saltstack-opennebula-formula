#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('opennebula', saltenv) %}

{% if datamap.orchestrate.hostlist.manage|default(False) %}
  {% set hosts = salt['publish.publish'](datamap.orchestrate.hostlist.tgt|default('*'), 'grains.item', ['fqdn'], 'compound') %}

  {% for k, v in hosts|dictsort %}
    {# TODO: support IPv6 #}
    {% set ipaddr = salt['dig.A'](v.fqdn)[0] %}
host_{{ v.fqdn }}_{{ ipaddr }}:
  host:
    - present
    - name: {{ v.fqdn }}
    - ip: {{ ipaddr }}
  {% endfor %}
{% endif %}

{% if datamap.orchestrate.hostpubkeys.manage|default(False) %}
  {% set keys = salt['publish.publish'](datamap.orchestrate.hostpubkeys.tgt|default('*'), 'grains.item', ['fqdn'], 'compound')|default({}) %}

  {% for k, v in keys|dictsort %}
knownhost_{{ v.fqdn }}: {# TODO move to saltstack-ssh-formula? #}
  ssh_known_hosts:
    - present
    - name: {{ v.fqdn }}
    - user: {{ datamap.oneadmin.name|default('oneadmin') }}
    #- port: {# TODO ssh port #}
    #- enc: {# TODO key enc type #}
  {% endfor %}
{% endif %}

{% set f_osc = datamap.oneadmin.sshconfig|default({}) %}
{% if f_osc.manage|default(True) and datamap.orchestrate.hostnames.manage|default(False) %}
  {% set hostnames = salt['publish.publish'](datamap.orchestrate.hostnames.tgt|default('*'), 'grains.item', ['fqdn', 'host'], 'compound')|default({}) %}
oneadmin_sshconfig:
  file:
    - managed
    - name: {{ datamap.oneadmin.home }}/.ssh/config
    - mode: {{ f_osc.mode|default('640') }}
    - user: {{ f_osc.user|default('oneadmin') }}
    - group: {{ f_osc.group|default('oneadmin') }}
    - require:
      - file: {{ datamap.oneadmin.home }}/.ssh
    - contents: |
    {%- for k, v in hostnames|dictsort %}
        Host {{ v.host }} {{ v.fqdn }}
          HostName {{ v.fqdn }}
    {% endfor %}
{% endif %}

{% if datamap.orchestrate.controller_sshpubkeys.manage|default(False) %}
  {% set d = datamap.orchestrate.controller_sshpubkeys|default({}) %}
  {% set controllers = salt['mine.get'](d.tgt, d.fun, d.exprform|default('glob')) %}
{% else %}
  {% set controllers = datamap.orchestrate.controller_sshpubkeys.static|default({}) %}
{% endif %}

{# TODO remove replace when https://github.com/saltstack/salt/issues/20708 is resolved #}
{% for host, pubkey in controllers|dictsort %}
ssh_auth_onecontroller_{{ datamap.oneadmin.name|default('oneadmin') }}_{{ host }}_{{ pubkey['oneadmin']['id_rsa_one.pub'][-30:]|replace('\n', '') }}:
  ssh_auth:
    - present
    - name: {{ pubkey['oneadmin']['id_rsa_one.pub']|replace('\n', '') }}
    - user: {{ datamap.oneadmin.name|default('oneadmin') }}
    - require:
      - file: {{ datamap.oneadmin.home }}/.ssh/authorized_keys
{% endfor %}
