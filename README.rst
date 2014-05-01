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
* modify default templates (e.g. /etc/one/vmm_exec/vmm_exec_kvm.conf: driver=>qcow?)
* deploy to sunstone host: serveradmin credentials

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

If you want to collect the list of e.g. compute nodes to be added to the static name lookup table (``/etc/hosts`` or other), you need to setup peer communication on your master:

Example:

.. code-block:: yaml
   peer:
     opennebula_controller.*\.domain\.local:
       - grains.get

You also need to enable the collection of those hosts in your pillars. See pillar.example.sls

``opennebula.oned``
-------------------

Sets OpenNebula daemon up

``opennebula.compute_node``
---------------------------

Sets OpenNebula computing node up

If you want to collect the public ssh key of the controller(s), you need to setup mine functions. See pillar.example.sls

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

None

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

* 2014.1.3

OS Compatibility
================

Tested with:

* GNU/ Linux Debian Wheezy
