credentials_file_path           = "<credentials_file_path>"
service_account                 = "<service_account_email>"
project                         = "<project>"
name                            = "fortisase"
region                          = "us-central1"
zone                            = "us-central1-c"
machine                         = "n2-standard-2"
# FortiGate Image name
# 7.4.0 PAYG is projects/fortigcp-project-001/global/images/fortinet-fgtondemand-740-20230512-001-w-license
image                           = "projects/fortigcp-project-001/global/images/fortinet-fgtondemand-740-20230512-001-w-license"
license_file                    = null
admin_port                      = 8443
# Windows
windows_server_image            = "projects/windows-cloud/global/images/windows-server-2019-dc-v20230809"  
windows_server_machine          = "n1-standard-1"
# VPCs
vpcs                            = ["hub-untrust-vpc", "hub-trust-vpc", "br-untrust-vpc","br-trust-vpc", "ztna-untrust-vpc", "ztna-trust-vpc"]
# Subnet
subnets                         = ["hub-untrust-subnet", "hub-trust-subnet", "br-untrust-subnet", "br-trust-subnet", "ztna-untrust-subnet", "ztna-trust-subnet"]
subnet_cidrs                    = ["10.15.0.0/24", "10.15.1.0/24", "10.25.0.0/24", "10.25.1.0/24", "10.35.0.0/24", "10.35.1.0/24"]
