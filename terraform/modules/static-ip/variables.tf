# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = "terraform-static-ip"
  description = "Name"
}

variable "random_string" {
  default     = "abc"
  description = "Random String"
}

variable "static_ip" {
  type        = string
  default     = "static_ip"
  description = "Static IP"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Region"
}
