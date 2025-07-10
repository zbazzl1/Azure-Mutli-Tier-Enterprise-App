output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "admin_username_secret_id" {
  description = "ID of the admin username secret"
  value       = azurerm_key_vault_secret.admin_username.id
}

output "admin_password_secret_id" {
  description = "ID of the admin password secret"
  value       = azurerm_key_vault_secret.admin_password.id
}
