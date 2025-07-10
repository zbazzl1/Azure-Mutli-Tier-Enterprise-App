variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "db_subnet_id" { type = string }
variable "tags" { type = map(string) }

variable "admin_username" {
  description = "Administrator username for SQL Managed Instance"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "Administrator password for SQL Managed Instance"
  type        = string
  sensitive   = true
}
