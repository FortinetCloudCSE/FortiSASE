variable "credentials_file_path" {}
variable "service_account" {}
variable "project" {}
variable "region" {}
variable "zone" {}

variable "prefix" {}

# FortiGates
variable "fortigate_machine_type" {}
variable "fortigate_vm_image" {}

variable "fortigate_license_files" {}

variable "fgt_username" {
  type        = string
  default     = ""
  description = "FortiGate Username"
}
variable "fgt_password" {
  type        = string
  default     = ""
  description = "FortiGate Password"
}
variable "admin_port" {}

# Windows
variable "windows_vm_image" {}
variable "windows_machine_type" {}

# debug
variable "enable_output" {
  type        = bool
  default     = true
  description = "Debug"
}

