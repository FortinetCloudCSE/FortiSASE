# Configuration for Branch FGT Instance using data
data "template_file" "setup-br-fgt" {
  template = file("${path.module}/branch-fgt")
  vars = {
    admin_port               = var.admin_port
    fgt_password             = var.password
    hub_fgt_ip               = module.hub_static_ip.static_ip
    br_subnet_cidr_port1     = var.subnet_cidrs[3]
    br_webserver_internal_ip = google_compute_address.br_webserver_ip.address
  }
}
