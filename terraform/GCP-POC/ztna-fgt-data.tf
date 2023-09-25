# Configuration for ZTNA FGT Instance using data
data "template_file" "setup-ztna-fgt" {
  template = file("${path.module}/ztna-fgt")
  vars = {
    admin_port                 = var.admin_port
    fgt_password               = var.password
    ztna_subnet_cidr_port1     = var.subnet_cidrs[5]
    ztna_webserver_internal_ip = google_compute_address.ztna_webserver_ip.address
  }
}
