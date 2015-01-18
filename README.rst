============================
saltstack-opennebula-formula
============================

.. image:: https://api.flattr.com/button/flattr-badge-large.png
    :target: https://flattr.com/submit/auto?user_id=bechtoldt&url=https%3A%2F%2Fgithub.com%2Fbechtoldt%2Fsaltstack-opennebula-formula

Salt Stack Formula to set up and configure the cloud management platform OpenNebula

NOTICE BEFORE YOU USE
=====================

* This formula aims to follow the conventions and recommendations described at http://docs.saltstack.com/topics/conventions/formulas.html

TODO
====

* get ceph-formula working with this formula :) (prepare storage automatically)
* register new storage automatically
* register new frontends automatically
* register new nodes automatically
* deploy to sunstone host: serveradmin credentials
* ``chown oneadmin. /var/lib/libvirt/qemu``

Instructions
============

1. Add this repository as a `GitFS <http://docs.saltstack.com/topics/tutorials/gitfs.html>`_ backend in your Salt master config.

2. Configure your Pillar top file (``/srv/pillar/top.sls``), see pillar.example.sls

3. Include this Formula within another Formula or simply define your needed states within the Salt top file (``/srv/salt/top.sls``).

Available states
================

.. contents::
    :local:

``opennebula``
-------------

Installs the official OpenNebula repository

``opennebula.controller``
-------------------------

Sets OpenNebula daemon up

``opennebula.compute_node``
---------------------------

Sets OpenNebula computing node up

``opennebula.sunstone``
-----------------------

Sets OpenNebula Sunstone up

``opennebula.oneflow``
----------------------

Sets OpenNebula Oneflow up

``opennebula.onegate``
----------------------

Sets OpenNebula Onegate up

Additional resources
====================

Collecting ssh host keys
------------------------

If you want to collect the public ssh host key of the controller, you need to setup peer communication on your master (see ``Collecting hostnames for static name lookup``) and pillars. See pillar.example.sls

**WARNING**: There's currently no mechanism to purge old and unused host keys. There's also no check in the case host keys have changed. This is a potential security risk! Use it carefully!

Managing ssh configuration of oneadmin user
-------------------------------------------

If you want to configure oneadmin's ssh configuration file ~/.ssh/config, you need to setup peer communication on your master (see ``Collecting hostnames for static name lookup``) and pillars. See pillar.example.sls

Collecting oneadmin's (ONE frontend) ssh public key
---------------------------------------------------

If you want to collect the public ssh key of the controllers' oneadmin user, you need to setup mine functions and pillars. See pillar.example.sls

Collecting hostnames for static name lookup
-------------------------------------------

If you want to collect the list of e.g. compute nodes to be added to the static name lookup table (``/etc/hosts`` or other), you need to setup peer communication on your master:

Example:

.. code:: yaml

    peer:
      opennebula_controller.*\.domain\.local:
        - grains.item

You also need to enable the collection of those hosts in your pillars. See pillar.example.sls

Formula Dependencies
====================

None

Contributions
=============

Contributions are always welcome. All development guidelines you have to know are

* write clean code (proper YAML+Jinja syntax, no trailing whitespaces, no empty lines with whitespaces, LF only)
* set sane default settings
* test your code
* update README.rst doc

Salt Compatibility
==================

Tested with:

* 2014.1.x

OS Compatibility
================

Tested with:

* GNU/ Linux Debian Wheezy 7
* CentOS 6 (partly)

AUTHORS
-------

Please add yourself too when contributing (sorted alphabetically)!

* Arnold Bechtoldt <mail@arnoldbechtoldt.com>
