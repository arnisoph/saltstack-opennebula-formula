{% from "opennebula/defaults.yaml" import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('opennebula:lookup')) %}

{% if datamap['repo']['manage']|default(True) == True %}
  {% if salt['grains.get']('os_family') == 'Debian' %}
opennebula_repo: {# TODO: whack the hack #}
  pkgrepo:
    - managed
    - name: deb {{ datamap['repo']['url'] }} {{ datamap['repo']['dist'] }} {{ datamap['repo']['comps'] }}
    - file: /etc/apt/sources.list.d/opennebula.list
    - key_url: {{ datamap['repo']['keyurl'] }}
  {% endif %}
{% endif %}


#TODO: create user + group?

#opennebula: TODO: dbus?
#  pkg:
#    - installed
#    - pkgs:
#{% for p in datamap['oned']['pkgs'] %}
#      - {{ p }}
#{% endfor %}

#File /var/lib/one
#File /var/lib/one/.ssh
#Service dbus