variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}
variable "principal_id" {
  description = "Object ID of the principal (user/service principal) for Key Vault access"
  type        = string
}
variable "admin_username" {
  description = "Administrator username for secrets"
  type        = string
  sensitive   = true
}
variable "admin_password" {
  description = "Administrator password for secrets"
  type        = string
  sensitive   = true
}
variable "tags" { type = map(string) }
