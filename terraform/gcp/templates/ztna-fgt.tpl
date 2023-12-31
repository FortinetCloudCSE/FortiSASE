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