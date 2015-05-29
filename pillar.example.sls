{# Controller Node #}
opennebula:
  lookup:
    controller:
      config:
        oned_conf:
          context:
            db_server: 127.0.0.1
            db_user: oneadmin
            db_passwd: oneadmin
            db_name: opennebula
    oneadmin:
      config:
        ec2_auth:
          contents: 'serveradmin:myinitialpasswhichwillbechangedafterfirstlogin'
        occi_auth:
          contents: 'serveradmin:myinitialpasswhichwillbechangedafterfirstlogin'
        one_auth:
          contents: 'oneadmin:myinitialpasswhichwillbechangedafterfirstlogin'
        oneflow_auth:
          contents: 'serveradmin:myinitialpasswhichwillbechangedafterfirstlogin'
        onegate_auth:
          contents: 'serveradmin:myinitialpasswhichwillbechangedafterfirstlogin'
        one_key:
          contents: 'myinitialpasswhichwillbechangedafterfirstlogin'
        sunstone_auth:
          contents: 'serveradmin:myinitialpasswhichwillbechangedafterfirstlogin'
      sshconfig:
        manage: True
      regenerate_ssh_keypair: True
      manage_remotes: True
      remotes:
        current_version: v4.10.1-1
        versions:
          - src: https://gitlab.domain.de/user/one-remotes.git
            rev: v4.10.1-1
    orchestrate:
      hostlist:
       tgt: I@saltenv:prod and ( I@roles:opennebula_controller or I@roles:opennebula_compute_node ) and I@entities:one_nc1
      hostpubkeys:
        manage: True
        tgt: I@saltenv:prod and ( I@roles:opennebula:controller:True or I@roles:opennebula:compute_node:True )
      hostnames:
        tgt: I@saltenv:prod and ( I@roles:opennebula_controller or I@roles:opennebula_compute_node ) and I@entities:one_nc1

mine_functions:
  oneadmin_pubkey:
    mine_function: ssh.user_keys
    user: oneadmin
    pubfile: /var/lib/one/.ssh/id_rsa.pub
    prvfile: False


{# Compute Node #}

{# Collecting oneadmin's sshpubkey on the controller and deploy on e.g. compute_node #}
opennebula:
  lookup:
    orchestrate:
      controller_sshpubkeys:
        manage: True
        tgt: I@saltenv:prod and I@roles:opennebula:controller:True
        fun: oneadmin_pubkey
        exprform: compound


{# (Web) frontend Node #}
opennebula:
  lookup:
    oneadmin:
      config:
        manage:
#          - one_auth
#          - one_key
          - sunstone_auth
#        one_auth:
#          contents: 'oneadmin:myinitialpasswhichwillbechangedafterfirstlogin'
#        one_key:
#          contents: 'myinitialpasswhichwillbechangedafterfirstlogin'
        sunstone_auth:
          contents: 'serveradmin:myinitialpasswhichwillbechangedafterfirstlogin'
    sunstone:
#      sls_include:
#        - crypto.x509
#      sls_extend:
#        crypto-x509-key-sunstone_key:
#          file:
#            - require:
#              - group: oneadmin
      config:
        sunstone_server:
          config:
            :tmpdir: /var/tmp
            :one_xmlrpc: 'http://127.0.0.1:2633/RPC2'
            :host: 127.0.0.1
            :port: 9869
            :sessions: memory
            :memcache_host: 127.0.0.1
            :memcache_port: 11211
            :memcache_namespace: opennebula.sunstone
            :debug_level: 3
            :auth: opennebula
            :core_auth: cipher
            :vnc_proxy_port: 29876
            :vnc_proxy_support_wss: only
            :vnc_proxy_cert: /etc/ssl/certs/32_62_C5_12_01_httpd_crt.crt.pem
            :vnc_proxy_key: /etc/ssl/private/32_62_C5_12_01_httpd_key.key.pem
            :vnc_proxy_ipv6: false
            :lang: en_US
            :table_order: desc
            :marketplace_url: 'http://marketplace.opennebula.systems/appliance'
            :oneflow_server: 'http://127.0.0.1:2474/'
            :routes:
                - :oneflow
                - :vcenter
                - :support
            :instance_types:
                - :name: small-x1
                  :cpu: 1
                  :vcpu: 1
                  :memory: 128
                  :description: Very small instance for testing purposes
                - :name: small-x2
                  :cpu: 2
                  :vcpu: 2
                  :memory: 512
                  :description: Small instance for testing multi-core applications
                - :name: medium-x2
                  :cpu: 2
                  :vcpu: 2
                  :memory: 1024
                  :description: General purpose instance for low-load servers
                - :name: medium-x4
                  :cpu: 4
                  :vcpu: 4
                  :memory: 2048
                  :description: General purpose instance for medium-load servers
                - :name: large-x4
                  :cpu: 4
                  :vcpu: 4
                  :memory: 4096
                  :description: General purpose instance for servers
                - :name: large-x8
                  :cpu: 8
                  :vcpu: 8
                  :memory: 8192
                  :description: General purpose instance for high-load servers
        sunstone_views:
          config:
            logo: images/opennebula-sunstone-v4.0.png
            available_tabs:
                - dashboard-tab
                - system-tab
                - users-tab
                - groups-tab
                - acls-tab
                - vresources-tab
                - vms-tab
                - templates-tab
                - images-tab
                - files-tab
                - infra-tab
                #- clusters-tab
                - hosts-tab
                - datastores-tab
                - vnets-tab
                #- zones-tab
                #- marketplace-tab
                #- oneflow-dashboard
                #- oneflow-services
                #- oneflow-templates
                - provision-tab
                #- support-tab
            groups:
                oneadmin:
                    - admin
                    - vdcadmin
                    - user
                    - cloud
                    - vcenter
            default:
                - cloud
        sunstone_view_cloud:
          config:
            provision_logo: images/one_small_logo.png
            enabled_tabs:
              provision-tab: true
            tabs:
              provision-tab:
                panel_tabs:
                  users: false
                  flows: false
                  templates: false
                actions:
                  Template.chmod: false
                  Template.delete: false
                dashboard:
                  quotas: true
                  vms: true
                  vdcquotas: false
                  vdcvms: false
                  users:  false
                create_vm:
                  capacity_select: false
                  network_select: false
      service:
        ensure: dead
        enable: False
