# HUB-FGT-IP
output "hub_fgt_ip" {
  value = google_compute_instance.hub_fgt_instance.network_interface.0.access_config.0.nat_ip
}

# HUB-FGT-Username
output "hub_fgt_username" {
  value = "admin"
}

# HUB-FGT-Password
output "hub_fgt_password" {
  value = var.password
}
