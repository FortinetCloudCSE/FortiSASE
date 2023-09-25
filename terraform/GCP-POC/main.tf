terraform {
  required_version = ">= 0.13.1"

  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file_path)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

module "random" {
  source = "../modules/random-generator"
}

module "vpc" {
  source = "../modules/vpc"
  # Pass Variables
  name = var.name
  vpcs = var.vpcs
  # Values fetched from the Modules
  random_string = module.random.random_string
}

module "subnet" {
  source = "../modules/subnet"

  # Pass Variables
  name                     = var.name
  region                   = var.region
  subnets                  = var.subnets
  subnet_cidrs             = var.subnet_cidrs
  private_ip_google_access = null
  # Values fetched from the Modules
  random_string = module.random.random_string
  vpcs          = module.vpc.vpc_networks
}

module "firewall" {
  source = "../modules/firewall"

  # Values fetched from the Modules
  random_string = module.random.random_string
  vpcs          = module.vpc.vpc_networks
}

###########
# HUB-FGT #
###########
# STATIC IP
module "hub_static_ip" {
  source = "../modules/static-ip"

  # Pass Variables
  name        = "${var.name}-hub-static-ip-${module.random.random_string}"
  region      = var.region
  # Values fetched from the Modules
  random_string = module.random.random_string
}

# Create log disk for active
resource "google_compute_disk" "hub_fgt_logdisk" {
  name = "hub-fgt-log-disk-${module.random.random_string}"
  size = 30
  type = "pd-standard"
  zone = var.zone
}

resource "google_compute_instance" "hub_fgt_instance" {
  name           = "${var.name}-hub-fgt-${module.random.random_string}"
  machine_type   = var.machine
  zone           = var.zone
  can_ip_forward = "true"
  tags           = ["hub-fgt"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  attached_disk {
    source = google_compute_disk.hub_fgt_logdisk.name
  }

  # Untrust Network
  network_interface {
    network    = module.vpc.vpc_networks[0]
    subnetwork = module.subnet.subnets[0]
    access_config {
      nat_ip = module.hub_static_ip.static_ip
    }
  }

  # Trust Network
  network_interface {
    network    = module.vpc.vpc_networks[1]
    subnetwork = module.subnet.subnets[1]
  }

  # Metadata which will deploy the license and configure the HA
  metadata = {
    user-data = data.template_file.setup-hub-fgt.rendered
    license   = var.license_file != null ? file(var.license_file) : null
  }

  # Service Account and Scope
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  // When Changing the machine_type, min_cpu_platform, service_account, or enable display on an instance requires stopping it
  allow_stopping_for_update = true
}

########################
# HUB - Windows Server #
########################
resource "google_compute_address" "hub_webserver_ip" {
  name         = "${var.name}-hub-ws-ip-${module.random.random_string}"
  subnetwork   = module.subnet.subnets[1]
  address      = cidrhost(var.subnet_cidrs[1], 10)
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_instance" "hub_windows_server" {
  name           = "${var.name}-hub-ws-${module.random.random_string}"
  zone           = var.zone
  machine_type   = var.machine
  can_ip_forward = "false"

  #tags
  tags = ["hub-windows-server"]

  boot_disk {
    initialize_params {
      image = var.windows_server_image
    }
  }

  # Trust Network
  network_interface {
    network    = module.vpc.vpc_networks[1]
    network_ip = google_compute_address.hub_webserver_ip.address
    subnetwork = module.subnet.subnets[1]
  }

  # Email will be the service account
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  depends_on = [google_compute_instance.hub_fgt_instance]
}

##############
# BRANCH-FGT #
##############
# STATIC IP
module "branch_static_ip" {
  source = "../modules/static-ip"

  # Pass Variables
  name        = "${var.name}-br-static-ip-${module.random.random_string}"
  region      = var.region
  # Values fetched from the Modules
  random_string = module.random.random_string
}

# Create log disk for active
resource "google_compute_disk" "br_fgt_logdisk" {
  name = "br-fgt-log-disk-${module.random.random_string}"
  size = 30
  type = "pd-standard"
  zone = var.zone
}

resource "google_compute_instance" "br_fgt_instance" {
  name           = "${var.name}-br-fgt-${module.random.random_string}"
  machine_type   = var.machine
  zone           = var.zone
  can_ip_forward = "true"
  tags           = ["br-fgt"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  attached_disk {
    source = google_compute_disk.br_fgt_logdisk.name
  }

  # Untrust Network
  network_interface {
    network    = module.vpc.vpc_networks[2]
    subnetwork = module.subnet.subnets[2]
    access_config {
      nat_ip = module.branch_static_ip.static_ip
    }
  }

  # Trust Network
  network_interface {
    network    = module.vpc.vpc_networks[3]
    subnetwork = module.subnet.subnets[3]
  }

  # Metadata which will deploy the license and configure the HA
  metadata = {
    user-data = data.template_file.setup-br-fgt.rendered
    license   = var.license_file != null ? file(var.license_file) : null
  }

  # Service Account and Scope
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  // When Changing the machine_type, min_cpu_platform, service_account, or enable display on an instance requires stopping it
  allow_stopping_for_update = true
}

###########################
# BRANCH - Windows Server #
###########################
resource "google_compute_address" "br_webserver_ip" {
  name         = "${var.name}-br-webserver-ip-${module.random.random_string}"
  subnetwork   = module.subnet.subnets[3]
  address      = cidrhost(var.subnet_cidrs[3], 10)
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_instance" "br_windows_server" {
  name           = "${var.name}-br-ws-${module.random.random_string}"
  zone           = var.zone
  machine_type   = var.machine
  can_ip_forward = "false"

  #tags
  tags = ["br-windows-server"]

  boot_disk {
    initialize_params {
      image = var.windows_server_image
    }
  }

  # Trust Network
  network_interface {
    network    = module.vpc.vpc_networks[3]
    network_ip = google_compute_address.br_webserver_ip.address
    subnetwork = module.subnet.subnets[3]
  }

  # Email will be the service account
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  depends_on = [google_compute_instance.br_fgt_instance]
}

############
# ZTNA-FGT #
############
# STATIC IP
module "ztna_static_ip" {
  source = "../modules/static-ip"

  # Pass Variables
  name        = "${var.name}-ztna-static-ip-${module.random.random_string}"
  region      = var.region
  # Values fetched from the Modules
  random_string = module.random.random_string
}

# Create log disk for active
resource "google_compute_disk" "ztna_fgt_logdisk" {
  name = "ztna-fgt-log-disk-${module.random.random_string}"
  size = 30
  type = "pd-standard"
  zone = var.zone
}

resource "google_compute_instance" "ztna_fgt_instance" {
  name           = "${var.name}-ztna-fgt-${module.random.random_string}"
  machine_type   = var.machine
  zone           = var.zone
  can_ip_forward = "true"
  tags           = ["ztna-fgt"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  attached_disk {
    source = google_compute_disk.ztna_fgt_logdisk.name
  }

  # Untrust Network
  network_interface {
    network    = module.vpc.vpc_networks[4]
    subnetwork = module.subnet.subnets[4]
    access_config {
      nat_ip = module.ztna_static_ip.static_ip
    }
  }

  # Trust Network
  network_interface {
    network    = module.vpc.vpc_networks[5]
    subnetwork = module.subnet.subnets[5]
  }

  # Metadata which will deploy the license and configure the HA
  metadata = {
    user-data = data.template_file.setup-ztna-fgt.rendered
    license   = var.license_file != null ? file(var.license_file) : null
  }

  # Service Account and Scope
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  // When Changing the machine_type, min_cpu_platform, service_account, or enable display on an instance requires stopping it
  allow_stopping_for_update = true
}

#########################
# ZTNA - Windows Server #
#########################
resource "google_compute_address" "ztna_webserver_ip" {
  name         = "${var.name}-ztna-webserver-ip-${module.random.random_string}"
  subnetwork   = module.subnet.subnets[5]
  address      = cidrhost(var.subnet_cidrs[5], 10)
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_instance" "ztna_windows_server" {
  name           = "${var.name}-ztna-ws-${module.random.random_string}"
  zone           = var.zone
  machine_type   = var.machine
  can_ip_forward = "false"

  #tags
  tags = ["ztna-windows-server"]

  boot_disk {
    initialize_params {
      image = var.windows_server_image
    }
  }

  # Trust Network
  network_interface {
    network    = module.vpc.vpc_networks[5]
    network_ip = google_compute_address.ztna_webserver_ip.address
    subnetwork = module.subnet.subnets[5]
  }

  # Email will be the service account
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  depends_on = [google_compute_instance.ztna_fgt_instance]
}
