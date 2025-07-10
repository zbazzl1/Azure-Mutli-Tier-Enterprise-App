variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "web_subnet_id" { type = string }
variable "app_subnet_id" { type = string }
variable "tags" { type = map(string) }

variable "admin_username" {
  description = "Administrator username for VMSS"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Administrator password for VMSS"
  type        = string
  sensitive   = true
}
