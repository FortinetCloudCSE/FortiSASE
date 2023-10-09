data "template_file" "template_file" {
  for_each = local.template_files

  template = file("${path.module}/templates/${each.value.template_file}")
  vars = {
    fgt_name              = each.value.fgt_name
    admin_port            = var.admin_port
    fgt_password          = var.fgt_password
    peer_fgt_ip           = each.value.peer_fgt_ip
    subnet_cidr_port1     = each.value.subnet_cidr_port1
    webserver_internal_ip = each.value.webserver_internal_ip
    vpn_direction         = each.value.vpn_direction
    local_as              = each.value.local_as
    remote_as             = each.value.remote_as
    router_id             = each.value.router_id
    remote_ip             = each.value.remote_ip
  }
}