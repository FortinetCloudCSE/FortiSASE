variable "credentials_file_path" {}
variable "service_account" {}
variable "project" {}
variable "name" {}
variable "region" {}
variable "zone" {}
variable "machine" {}
variable "image" {}
variable "license_file" {}
variable "password" {
  type        = string
  default     = "fortinet"
  description = "FGT Password"
}
variable "admin_port" {}
# Windows
variable "windows_server_image" {}
variable "windows_server_machine" {}

# vpc module
variable "vpcs" {}
# subnet module
variable "subnets" {}
variable "subnet_cidrs" {}