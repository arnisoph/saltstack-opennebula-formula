==================
opennebula-formula
==================

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

Instructions
============

1. Add this repository as a `GitFS <http://docs.saltstack.com/topics/tutorials/gitfs.html>`_ backend in your Salt master config.

2. Configure your Pillar top file (``/srv/pillar/top.sls``), see pillar.example

3. Include this Formula within another Formula or simply define your needed states within the Salt top file (``/srv/salt/top.sls``).

Available states
================

.. contents::
    :local:

``opennebula``
-------------

Installs the official OpenNebula repository

``opennebula.oned``
-------------------

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

* Big thanks to the great work of the guys behind https://github.com/epost-dev/opennebula-puppet-module! They built a very nice looking module for Puppet.

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

* 2014.1.0

OS Compatibility
================

Tested with:

* GNU/ Linux Debian Wheezy
