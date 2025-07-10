output "web_vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.web.id
}

output "app_vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.app.id
}
