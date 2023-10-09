config system global
    set admin-sport ${admin_port}
    set hostname ${fgt_name}
    set admintimeout 60
end
config system admin
    edit "admin"
        set password ${fgt_password}
    next
end
config router static
    edit 1
        set dst ${cidrhost(subnet_cidr_port1, 0)}/24
        set gateway ${cidrhost(subnet_cidr_port1, 1)}
        set device "port2"
    next
end
config system interface
    edit port1
        set description "untrust"
    next
    edit port2
        set description "trust"
        set allowaccess ping https
    next
    edit ${vpn_direction}
        set vdom "root"
        set ip ${router_id} 255.255.255.255
        set allowaccess ping https http
        set type tunnel
        set remote-ip ${remote_ip} 255.255.255.255
        set interface "port1"
    next
end
config vpn ipsec phase1-interface
    edit ${vpn_direction}
        set interface "port1"
        set peertype any
        set net-device disable
        set proposal aes128-sha256 aes256-sha256 aes128-sha1 aes256-sha1
        set comments "VPN: ${vpn_direction}"
        set wizard-type static-fortigate
        set remote-gw ${peer_fgt_ip}
        set psksecret Fortinet1!
    next
end
config vpn ipsec phase2-interface
    edit ${vpn_direction}
        set phase1name ${vpn_direction}
        set proposal aes128-sha1 aes256-sha1 aes128-sha256 aes256-sha256 aes128gcm aes256gcm chacha20poly1305
        set comments "VPN: ${vpn_direction}"
        set src-addr-type name
        set dst-addr-type name
        set src-name "all"
        set dst-name "all"
    next
end
config router bgp
    set as ${local_as}
    set router-id ${router_id}
    config neighbor
        edit "${remote_ip}"
            set next-hop-self enable
            set soft-reconfiguration enable
            set remote-as ${remote_as}
        next
    end
    config network
        edit 1
            set prefix ${cidrhost(subnet_cidr_port1, 0)}/24
        next
    end
end
config firewall vip
    edit "windows-server"
        set mappedip ${webserver_internal_ip}
        set extintf "port1"
        set portforward enable
        set extport 50102
        set mappedport 50102
    next
end
config firewall policy
    edit 1
        set name "${vpn_direction}_local"
        set srcintf "port2"
        set dstintf ${vpn_direction}
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set comments "VPN: ${vpn_direction}}"
    next
    edit 2
        set name "${vpn_direction}_remote"
        set srcintf ${vpn_direction}
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set comments "VPN: ${vpn_direction}"
    next
    edit 3
        set name "Inbound"
        set srcintf "port1"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "windows-server"
        set schedule "always"
        set service "ALL"
        set logtraffic all
        set nat enable
    next
end