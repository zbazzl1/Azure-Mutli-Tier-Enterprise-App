variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vmss_web_id" { type = string }
variable "vmss_app_id" { type = string }
variable "app_gateway_id" { type = string }
variable "sql_instance_id" { type = string }
variable "tags" { type = map(string) }
