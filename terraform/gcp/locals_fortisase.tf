locals {

  prefix = var.prefix

  service_account = var.service_account
  region          = var.region
  zone            = var.zone

  fortigate_machine_type  = var.fortigate_machine_type
  fortigate_vm_image      = var.fortigate_vm_image
  fortigate_license_files = var.fortigate_license_files

  windows_machine_type = var.windows_machine_type
  windows_vm_image     = var.windows_vm_image

#######################
  # Static IPs
  compute_addresses = {
    "branch-fgt-static-ip" = {
      region       = local.region
      name         = "${local.prefix}-branch-fgt-static-ip-${random_string.string.result}"
      subnetwork   = null
      address      = null
      address_type = "EXTERNAL"
    }
    "hub-fgt-static-ip" = {
      region       = local.region
      name         = "${local.prefix}-hub-fgt-static-ip-${random_string.string.result}"
      subnetwork   = null
      address      = null
      address_type = "EXTERNAL"
    }
    "ztna-fgt-static-ip" = {
      region       = local.region
      name         = "${local.prefix}-ztna-fgt-static-ip-${random_string.string.result}"
      subnetwork   = null
      address      = null
      address_type = "EXTERNAL"
    }
    "hub-webserver-ip" = {
      region       = local.region
      name         = "${local.prefix}-hub-webserver-ip-${random_string.string.result}"
      subnetwork   = google_compute_subnetwork.compute_subnetwork["hub-trust-subnet"].id
      address      = cidrhost(google_compute_subnetwork.compute_subnetwork["hub-trust-subnet"].ip_cidr_range, 10)
      address_type = "INTERNAL"
    }
    "branch-webserver-ip" = {
      region       = local.region
      name         = "${local.prefix}-branch-webserver-ip-${random_string.string.result}"
      subnetwork   = google_compute_subnetwork.compute_subnetwork["branch-trust-subnet"].id
      address      = cidrhost(google_compute_subnetwork.compute_subnetwork["branch-trust-subnet"].ip_cidr_range, 10)
      address_type = "INTERNAL"
    }
    "ztna-webserver-ip" = {
      region       = local.region
      name         = "${local.prefix}-ztna-webserver-ip-${random_string.string.result}"
      subnetwork   = google_compute_subnetwork.compute_subnetwork["ztna-trust-subnet"].id
      address      = cidrhost(google_compute_subnetwork.compute_subnetwork["ztna-trust-subnet"].ip_cidr_range, 10)
      address_type = "INTERNAL"
    }
  }

  # Compute Networks
  compute_networks = {
    "hub-untrust-vpc" = {
      region                  = local.region
      name                    = "${local.prefix}-hub-untrust-vpc-${random_string.string.result}"
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
    }
    "hub-trust-vpc" = {
      region                  = local.region
      name                    = "${local.prefix}-hub-trust-vpc-${random_string.string.result}"
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
    }
    "branch-untrust-vpc" = {
      region                  = local.region
      name                    = "${local.prefix}-branch-untrust-vpc-${random_string.string.result}"
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
    }
    "branch-trust-vpc" = {
      region                  = local.region
      name                    = "${local.prefix}-branch-trust-vpc-${random_string.string.result}"
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
    }
    "ztna-untrust-vpc" = {
      region                  = local.region
      name                    = "${local.prefix}-ztna-untrust-vpc-${random_string.string.result}"
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
    }
    "ztna-trust-vpc" = {
      region                  = local.region
      name                    = "${local.prefix}-ztna-trust-vpc-${random_string.string.result}"
      auto_create_subnetworks = false
      routing_mode            = "REGIONAL"
    }
  }

  # Compute Subnets
  compute_subnetworks = {
    "hub-untrust-subnet" = {
      region        = local.region
      network       = google_compute_network.compute_network["hub-untrust-vpc"].id
      name          = "${local.prefix}-hub-untrust-subnet-${random_string.string.result}"
      ip_cidr_range = "10.15.0.0/24"
    }
    "hub-trust-subnet" = {
      region        = local.region
      network       = google_compute_network.compute_network["hub-trust-vpc"].id
      name          = "${local.prefix}-hub-trust-subnet-${random_string.string.result}"
      ip_cidr_range = "10.15.1.0/24"
    }
    "branch-untrust-subnet" = {
      region        = local.region
      network       = google_compute_network.compute_network["branch-untrust-vpc"].id
      name          = "${local.prefix}-branch-untrust-subnet-${random_string.string.result}"
      ip_cidr_range = "10.25.0.0/24"
    }
    "branch-trust-subnet" = {
      region        = local.region
      network       = google_compute_network.compute_network["branch-trust-vpc"].id
      name          = "${local.prefix}-branch-trust-subnet-${random_string.string.result}"
      ip_cidr_range = "10.25.1.0/24"
    }
    "ztna-untrust-subnet" = {
      region        = local.region
      network       = google_compute_network.compute_network["ztna-untrust-vpc"].id
      name          = "${local.prefix}-ztna-untrust-subnet-${random_string.string.result}"
      ip_cidr_range = "10.35.0.0/24"
    }
    "ztna-trust-subnet" = {
      region        = local.region
      network       = google_compute_network.compute_network["ztna-trust-vpc"].id
      name          = "${local.prefix}-ztna-trust-subnet-${random_string.string.result}"
      ip_cidr_range = "10.35.1.0/24"
    }
  }

  compute_firewalls = {
    "hub-untrust-vpc-ingress" = {
      name               = format("%s-ingress", google_compute_network.compute_network["hub-untrust-vpc"].name)
      network            = google_compute_network.compute_network["hub-untrust-vpc"].name
      direction          = "INGRESS"
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = null
      allow = [{
        protocol = "all"
      }]
    }
    "hub-trust-vpc-ingress" = {
      name               = format("%s-ingress", google_compute_network.compute_network["hub-trust-vpc"].name)
      network            = google_compute_network.compute_network["hub-trust-vpc"].name
      direction          = "INGRESS"
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = null
      allow = [{
        protocol = "all"
      }]
    }
    "hub-untrust-vpc-egress" = {
      name               = format("%s-egress", google_compute_network.compute_network["hub-untrust-vpc"].name)
      network            = google_compute_network.compute_network["hub-untrust-vpc"].name
      direction          = "EGRESS"
      source_ranges      = null
      destination_ranges = ["0.0.0.0/0"]
      allow = [{
        protocol = "all"
      }]
    }
    "hub-trust-vpc-egress" = {
      name               = format("%s-egress", google_compute_network.compute_network["hub-trust-vpc"].name)
      network            = google_compute_network.compute_network["hub-trust-vpc"].name
      direction          = "EGRESS"
      source_ranges      = null
      destination_ranges = ["0.0.0.0/0"]
      allow = [{
        protocol = "all"
      }]
    }
    "branch-untrust-vpc-ingress" = {
      name               = format("%s-ingress", google_compute_network.compute_network["branch-untrust-vpc"].name)
      network            = google_compute_network.compute_network["branch-untrust-vpc"].name
      direction          = "INGRESS"
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = null
      allow = [{
        protocol = "all"
      }]
    }
    "branch-trust-vpc-ingress" = {
      name               = format("%s-ingress", google_compute_network.compute_network["branch-trust-vpc"].name)
      network            = google_compute_network.compute_network["branch-trust-vpc"].name
      direction          = "INGRESS"
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = null
      allow = [{
        protocol = "all"
      }]
    }
    "branch-untrust-vpc-egress" = {
      name               = format("%s-egress", google_compute_network.compute_network["branch-untrust-vpc"].name)
      network            = google_compute_network.compute_network["branch-untrust-vpc"].name
      direction          = "EGRESS"
      source_ranges      = null
      destination_ranges = ["0.0.0.0/0"]
      allow = [{
        protocol = "all"
      }]
    }
    "branch-trust-vpc-egress" = {
      name               = format("%s-egress", google_compute_network.compute_network["branch-trust-vpc"].name)
      network            = google_compute_network.compute_network["branch-trust-vpc"].name
      direction          = "EGRESS"
      source_ranges      = null
      destination_ranges = ["0.0.0.0/0"]
      allow = [{
        protocol = "all"
      }]
    }
    "ztna-untrust-vpc-ingress" = {
      name               = format("%s-ingress", google_compute_network.compute_network["ztna-untrust-vpc"].name)
      network            = google_compute_network.compute_network["ztna-untrust-vpc"].name
      direction          = "INGRESS"
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = null
      allow = [{
        protocol = "all"
      }]
    }
    "ztna-trust-vpc-ingress" = {
      name               = format("%s-ingress", google_compute_network.compute_network["ztna-trust-vpc"].name)
      network            = google_compute_network.compute_network["ztna-trust-vpc"].name
      direction          = "INGRESS"
      source_ranges      = ["0.0.0.0/0"]
      destination_ranges = null
      allow = [{
        protocol = "all"
      }]
    }
    "ztna-untrust-vpc-egress" = {
      name               = format("%s-egress", google_compute_network.compute_network["ztna-untrust-vpc"].name)
      network            = google_compute_network.compute_network["ztna-untrust-vpc"].name
      direction          = "EGRESS"
      source_ranges      = null
      destination_ranges = ["0.0.0.0/0"]
      allow = [{
        protocol = "all"
      }]
    }
    "ztna-trust-vpc-egress" = {
      name               = format("%s-egress", google_compute_network.compute_network["ztna-trust-vpc"].name)
      network            = google_compute_network.compute_network["ztna-trust-vpc"].name
      direction          = "EGRESS"
      source_ranges      = null
      destination_ranges = ["0.0.0.0/0"]
      allow = [{
        protocol = "all"
      }]
    }
  }

  compute_disks = {
    "hub-fgt-logdisk" = {
      name = "hub-fgt-logdisk-${random_string.string.result}"
      size = 30
      type = "pd-standard"
      zone = local.zone
    }
    "branch-fgt-logdisk" = {
      name = "branch-fgt-logdisk-${random_string.string.result}"
      size = 30
      type = "pd-standard"
      zone = local.zone
    }
    "ztna-fgt-logdisk" = {
      name = "ztna-fgt-logdisk-${random_string.string.result}"
      size = 30
      type = "pd-standard"
      zone = local.zone
    }
  }

  # Compute Instances
  compute_instances = {
    hub_windows_server = {
      name         = "${local.prefix}-hub-ws-${random_string.string.result}"
      zone         = local.zone
      machine_type = local.windows_machine_type

      can_ip_forward = "false"
      tags           = ["hub-windows-server","hub-trust"]

      boot_disk_initialize_params_image = local.windows_vm_image

      attached_disk = []

      network_interface = [{
        network       = google_compute_network.compute_network["hub-trust-vpc"].name
        subnetwork    = google_compute_subnetwork.compute_subnetwork["hub-trust-subnet"].name
        network_ip    = google_compute_address.compute_address["hub-webserver-ip"].address
        access_config = []
      }]

      metadata = null

      service_account_email  = local.service_account
      service_account_scopes = ["cloud-platform"]

      allow_stopping_for_update = true
    }
    branch_windows_server = {
      name         = "${local.prefix}-branch-ws-${random_string.string.result}"
      zone         = local.zone
      machine_type = local.windows_machine_type

      can_ip_forward = "false"
      tags           = ["branch-windows-server","branch-trust"]

      boot_disk_initialize_params_image = local.windows_vm_image

      attached_disk = []

      network_interface = [{
        network       = google_compute_network.compute_network["branch-trust-vpc"].name
        subnetwork    = google_compute_subnetwork.compute_subnetwork["branch-trust-subnet"].name
        network_ip    = google_compute_address.compute_address["branch-webserver-ip"].address
        access_config = []
      }]

      metadata = null

      service_account_email  = local.service_account
      service_account_scopes = ["cloud-platform"]

      allow_stopping_for_update = true
    }
    ztna_windows_server = {
      name         = "${local.prefix}-ztna-ws-${random_string.string.result}"
      zone         = local.zone
      machine_type = local.windows_machine_type

      can_ip_forward = "false"
      tags           = ["ztna-windows-server","ztna-trust"]

      boot_disk_initialize_params_image = local.windows_vm_image

      attached_disk = []

      network_interface = [{
        network       = google_compute_network.compute_network["ztna-trust-vpc"].name
        subnetwork    = google_compute_subnetwork.compute_subnetwork["ztna-trust-subnet"].name
        network_ip    = google_compute_address.compute_address["ztna-webserver-ip"].address
        access_config = []
      }]

      metadata = null

      service_account_email  = local.service_account
      service_account_scopes = ["cloud-platform"]

      allow_stopping_for_update = true
    }
    hub_fgt_instance = {
      name         = "${local.prefix}-hub-fgt-${random_string.string.result}"
      zone         = local.zone
      machine_type = local.fortigate_machine_type

      can_ip_forward = "true"
      tags           = ["hub-fgt"]

      boot_disk_initialize_params_image = local.fortigate_vm_image

      attached_disk = [{
        source = google_compute_disk.compute_disk["hub-fgt-logdisk"].name
      }]

      network_interface = [{
        network    = google_compute_network.compute_network["hub-untrust-vpc"].name
        subnetwork = google_compute_subnetwork.compute_subnetwork["hub-untrust-subnet"].name
        network_ip = null
        access_config = [{
          nat_ip = google_compute_address.compute_address["hub-fgt-static-ip"].address
        }]
        },
        {
          network       = google_compute_network.compute_network["hub-trust-vpc"].name
          subnetwork    = google_compute_subnetwork.compute_subnetwork["hub-trust-subnet"].name
          network_ip    = null
          access_config = []
      }]

      metadata = {
        user-data = data.template_file.template_file["hub-fgt-template"].rendered
        license   = local.fortigate_license_files["hub_fgt_instance"].name != null ? file(local.fortigate_license_files["hub_fgt_instance"].name) : null
      }

      service_account_email  = local.service_account
      service_account_scopes = ["cloud-platform"]

      allow_stopping_for_update = true
    }

    branch_fgt_instance = {
      name         = "${local.prefix}-branch-fgt-${random_string.string.result}"
      zone         = local.zone
      machine_type = local.fortigate_machine_type

      can_ip_forward = "true"
      tags           = ["branch-fgt"]

      boot_disk_initialize_params_image = local.fortigate_vm_image

      attached_disk = [{
        source = google_compute_disk.compute_disk["branch-fgt-logdisk"].name
      }]

      network_interface = [{
        network    = google_compute_network.compute_network["branch-untrust-vpc"].name
        subnetwork = google_compute_subnetwork.compute_subnetwork["branch-untrust-subnet"].name
        network_ip = null
        access_config = [{
          nat_ip = google_compute_address.compute_address["branch-fgt-static-ip"].address
        }]
        },
        {
          network       = google_compute_network.compute_network["branch-trust-vpc"].name
          subnetwork    = google_compute_subnetwork.compute_subnetwork["branch-trust-subnet"].name
          network_ip    = null
          access_config = []
      }]

      metadata = {
        user-data = data.template_file.template_file["branch-fgt-template"].rendered
        license   = local.fortigate_license_files["branch_fgt_instance"].name != null ? file(local.fortigate_license_files["branch_fgt_instance"].name) : null
      }

      service_account_email  = local.service_account
      service_account_scopes = ["cloud-platform"]

      allow_stopping_for_update = true
    }
    ztna_fgt_instance = {
      name         = "${local.prefix}-ztna-fgt-${random_string.string.result}"
      zone         = local.zone
      machine_type = local.fortigate_machine_type

      can_ip_forward = "true"
      tags           = ["ztna-fgt"]

      boot_disk_initialize_params_image = local.fortigate_vm_image

      attached_disk = [{
        source = google_compute_disk.compute_disk["ztna-fgt-logdisk"].name
      }]

      network_interface = [{
        network    = google_compute_network.compute_network["ztna-untrust-vpc"].name
        subnetwork = google_compute_subnetwork.compute_subnetwork["ztna-untrust-subnet"].name
        network_ip = null
        access_config = [{
          nat_ip = google_compute_address.compute_address["ztna-fgt-static-ip"].address
        }]
        },
        {
          network       = google_compute_network.compute_network["ztna-trust-vpc"].name
          subnetwork    = google_compute_subnetwork.compute_subnetwork["ztna-trust-subnet"].name
          network_ip    = null
          access_config = []
      }]

      metadata = {
        user-data = data.template_file.template_file["ztna-fgt-template"].rendered
        license   = local.fortigate_license_files["ztna_fgt_instance"].name != null ? file(local.fortigate_license_files["ztna_fgt_instance"].name) : null
      }

      service_account_email  = local.service_account
      service_account_scopes = ["cloud-platform"]

      allow_stopping_for_update = true
    }
  }

  template_files = {
    "branch-fgt-template" = {
      fgt_name              = "BRANCH-FGT"
      template_file         = "vpn-fgt.tpl"
      admin_port            = var.admin_port
      fgt_password          = var.fgt_password
      peer_fgt_ip           = google_compute_address.compute_address["hub-fgt-static-ip"].address
      subnet_cidr_port1     = resource.google_compute_subnetwork.compute_subnetwork["branch-trust-subnet"].ip_cidr_range
      webserver_internal_ip = google_compute_address.compute_address["branch-webserver-ip"].address
      vpn_direction         = "toHub"
      local_as              = 65252
      remote_as             = 65251
      router_id             = "169.254.254.2"
      remote_ip             = "169.254.254.1"
    }
    "hub-fgt-template" = {
      fgt_name              = "HUB-FGT"
      template_file         = "vpn-fgt.tpl"
      admin_port            = var.admin_port
      fgt_password          = var.fgt_password
      peer_fgt_ip           = google_compute_address.compute_address["branch-fgt-static-ip"].address
      subnet_cidr_port1     = resource.google_compute_subnetwork.compute_subnetwork["hub-trust-subnet"].ip_cidr_range
      webserver_internal_ip = google_compute_address.compute_address["hub-webserver-ip"].address
      vpn_direction         = "toBranch"
      local_as              = 65251
      remote_as             = 65252
      router_id             = "169.254.254.1"
      remote_ip             = "169.254.254.2"
    }
    "ztna-fgt-template" = {
      fgt_name              = "ZTNA-FGT"
      template_file         = "ztna-fgt.tpl"
      admin_port            = var.admin_port
      fgt_password          = var.fgt_password
      peer_fgt_ip           = null
      subnet_cidr_port1     = resource.google_compute_subnetwork.compute_subnetwork["ztna-trust-subnet"].ip_cidr_range
      webserver_internal_ip = google_compute_address.compute_address["ztna-webserver-ip"].address
      vpn_direction         = null
      local_as              = null
      remote_as             = null
      router_id             = null
      remote_ip             = null
    }
  }
  trust_routes = {
    "hub-trust-route" = {
      name = "${local.prefix}hub-trust-route-${random_string.string.result}"
      network = google_compute_network.compute_network["hub-trust-vpc"].name
      next_hop_ip = google_compute_instance.compute_instance["hub_fgt_instance"].network_interface[1].network_ip
      zone = local.zone
      tags = ["hub-trust"]
    }
    "branch-trust-route" = {
      name = "${local.prefix}branch-trust-route-${random_string.string.result}"
      network = google_compute_network.compute_network["branch-trust-vpc"].name
      next_hop_ip = google_compute_instance.compute_instance["branch_fgt_instance"].network_interface[1].network_ip
      zone = local.zone
      tags = ["branch-trust"]
    }
    "ztna-trust-route" = {
      name = "${local.prefix}ztna-trust-route-${random_string.string.result}"
      network = google_compute_network.compute_network["ztna-trust-vpc"].name
      next_hop_ip = google_compute_instance.compute_instance["ztna_fgt_instance"].network_interface[1].network_ip
      zone = local.zone
      tags = ["ztna-trust"]
    }
  }
}
