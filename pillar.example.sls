opennebula:
  lookup:
    oned:
      config:
        oned_conf:
          template_path: False
        one_auth:
          manage: True
          content: 'oneadmin:myinitialpasswhichwillbechangedafterfirstlogin'
    sunstone:
      config:
        sunstone_server:
          content:
            :tmpdir: /var/tmp
            :one_xmlrpc: http://localhost:2633/RPC2
            :host: 0.0.0.0
            :port: 9869
            :sessions: memory
            :memcache_host: localhost
            :memcache_port: 11211
            :memcache_namespace: opennebula.sunstone
            :debug_level: 3
            :auth: sunstone
            :core_auth: cipher
            :vnc_proxy_port: 29876
            :vnc_proxy_support_wss: no
            :vnc_proxy_cert:
            :vnc_proxy_key:
            :vnc_proxy_ipv6: false
            :lang: en_US
            :table_order: desc
            :marketplace_url: http://marketplace.c12g.com/appliance
            :oneflow_server: http://localhost:2474/
            :routes:
              - oneflow
