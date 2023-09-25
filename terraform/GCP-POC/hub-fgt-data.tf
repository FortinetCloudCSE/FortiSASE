# Configuration for Hub FGT Instance using data
data "template_file" "setup-hub-fgt" {
  template = file("${path.module}/hub-fgt")
  vars = {
    admin_port                = var.admin_port
    fgt_password              = var.password
    branch_fgt_ip             = module.branch_static_ip.static_ip
    hub_subnet_cidr_port1     = var.subnet_cidrs[1]
    hub_webserver_internal_ip = google_compute_address.hub_webserver_ip.address
  }
}
