variable "region" {
  type        = string
  default     = "us-east-1" 
}


variable "vpc_cni_enable_ipv4" {
  description = "Enable IPv4 support for VPC CNI"
  type        = bool
  default     = true
}

variable "vpc_cni_enable_ipv6" {
  description = "Enable IPv6 support for VPC CNI"
  type        = bool
  default     = false
}