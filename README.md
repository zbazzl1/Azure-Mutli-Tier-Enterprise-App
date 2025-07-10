# Azure-Mutli-Tier-Enterprise-App
Provisions a Multi Tier Enterprise App in Azure using Terraform and deploys using a Gitlab CI/CD pipeline.

This project provisions a multi-tier enterprise application in Microsoft Azure using Terraform and deploys it via a GitLab CI/CD pipeline. The application follows a secure, scalable architecture with networking, compute, database, DNS, Key Vault, storage, and monitoring components, all managed as Infrastructure as Code (IaC).

Table of Contents





Overview



Architecture



Components



GitLab CI/CD Pipeline



Troubleshooting





Overview

This project deploys a multi-tier enterprise application in Azure’s West Europe region within the rg-enterprise-app resource group. Key components include:





Networking: Virtual network (vnet-enterprise-app, 10.0.0.0/16), subnets (web, app, db, mgmt, AzureBastionSubnet), Application Gateway (app-gateway, WAF_v2), Bastion host (bastion), and NSGs.



Compute: Linux Virtual Machine Scale Sets (VMSS) for web (vmss-web, Ubuntu 20.04, Standard_D2s_v3, 2-6 instances) and app (vmss-app, Ubuntu 20.04, Standard_D4s_v3, 3-8 instances) tiers with autoscale settings.



Database: SQL Managed Instance (sql-managed-instance, 256 GB, 8 vCores) with a private endpoint in the db subnet.



DNS: Private DNS zone (example341073.com) with A records for the Application Gateway.



Key Vault: Key Vault (kv-enterprise-app) for storing secrets (admin-username, admin-password).



Storage: Storage account (stenterpriseapp, LRS) and Recovery Services Vault (backup-vault) for VM backups.



Monitoring: Log Analytics Workspace (log-analytics) with diagnostic settings and metric alerts for VMSS, Application Gateway, and SQL instance.

The infrastructure is defined using Terraform modules and deployed via a GitLab CI/CD pipeline, with state stored in an Azure Blob Storage backend (rg-tfstate, tfstateenterpriseapp, terraform container, prod.terraform.tfstate key).

Architecture

The application follows a multi-tier architecture:





Web Tier: vmss-web in the web subnet (10.0.1.0/24), accessible via the Application Gateway with HTTP/HTTPS listeners and WAF enabled. Autoscales based on CPU usage (70% increase, 30% decrease).



Application Tier: vmss-app in the app subnet (10.0.2.0/24), handling business logic via URL path-based routing (/api/*). Autoscales based on memory usage (500 MB increase, 1 GB decrease).



Database Tier: SQL Managed Instance in the db subnet (10.0.3.0/24) with a private endpoint for secure access.



Management Tier: Bastion host in the AzureBastionSubnet (10.0.5.0/24) for secure VM access.



Security: Key Vault for secrets, NSGs for network security, DDoS protection, and WAF on the Application Gateway.



DNS: Private DNS zone with A records mapping to the Application Gateway’s public IP.



Storage: Storage account for data and Recovery Services Vault for daily VM backups (30-day retention).



Monitoring: Log Analytics Workspace with diagnostic logs (Administrative, Security, ApplicationGatewayAccessLog, SQLInsights) and alerts for CPU (80%), Application Gateway failed requests, and SQL storage (90% of 256 GB).

Components

Terraform Configuration

Root Module





Files: main.tf, variables.tf, terraform.tfvars, outputs.tf, .gitlab-ci.yml



Purpose: Configures the azurerm provider, Azure Blob Storage backend, and resource group (rg-enterprise-app). Orchestrates all modules and retrieves secrets from Key Vault.



Outputs: VNet ID, Application Gateway public IP, DNS zone name, and name servers.

Networking Module (modules/networking)





Files: main.tf, variables.tf, outputs.tf



Resources:





Virtual Network (vnet-enterprise-app, 10.0.0.0/16) with DDoS protection plan (ddos-protection).



Subnets: web (10.0.1.0/24), app (10.0.2.0/24), db (10.0.3.0/24), mgmt (10.0.4.0/24), AzureBastionSubnet (10.0.5.0/24).



Application Gateway (app-gateway, WAF_v2) with HTTP (port 80) and HTTPS (port 443, no SSL certificate) listeners, path-based routing (/api/* to app-backend).



Bastion host (bastion) with public IP (pip-bastion).



NSGs: web_nsg (allows HTTP/HTTPS), app_nsg (allows web-to-app traffic), db_nsg (allows app-to-db traffic on port 1433), mgmt_nsg (allows Bastion access on ports 3389, 22).



Outputs: VNet ID, subnet IDs (web, app, db), Application Gateway ID, and public IP.



Note: The NSG rules for web_nsg and mgmt_nsg use invalid destination_port_range (80,443, 3389,22). Update to destination_port_ranges (see Troubleshooting).

Compute Module (modules/compute)





Files: main.tf, variables.tf, outputs.tf



Resources:





Web VMSS (vmss-web, Ubuntu 20.04, Standard_D2s_v3, 2-6 instances) in web subnet with autoscale based on CPU (increase >70%, decrease <30%).



App VMSS (vmss-app, Ubuntu 20.04, Standard_D4s_v3, 3-8 instances) in app subnet with autoscale based on memory (increase <500 MB, decrease >1 GB).



Outputs: Web and app VMSS IDs.



Note: Uses Key Vault secrets for admin_username and admin_password.

Database Module (modules/database)





Files: main.tf, variables.tf, outputs.tf



Resources:





SQL Managed Instance (sql-managed-instance, GP_Gen5, 256 GB, 8 vCores) in db subnet.



Private endpoint (sql-private-endpoint) for secure access.



Outputs: SQL Managed Instance ID.



Note: Optional; can be disabled by commenting out in main.tf.

DNS Module (modules/dns)





Files: main.tf, variables.tf, outputs.tf



Resources:





Private DNS zone (example341073.com).



A records mapping to the Application Gateway’s public IP (TTL 300).



Outputs: DNS zone name and name servers.

Key Vault Module (modules/key_vault)





Files: main.tf, variables.tf, outputs.tf



Resources:





Key Vault (kv-enterprise-app, Standard SKU) with secrets (admin-username, admin-password).



Access policy for service principal (5523470a-cdf9-47d9-83a4-71b3c467bf5a) with Get, List, Set, Delete permissions.



Outputs: Key Vault ID, secret IDs for admin-username and admin-password.



Note: Ensure the service principal has Set permission (see Troubleshooting).

Storage Module (modules/storage)





Files: main.tf, variables.tf, outputs.tf



Resources:





Storage account (stenterpriseapp, Standard LRS) with 7-day blob deletion retention.



Recovery Services Vault (backup-vault, Standard SKU) with daily VM backup policy (30-day retention).



Outputs: Storage account ID.

Monitoring Module (modules/monitoring)





Files: main.tf, variables.tf, outputs.tf



Resources:





Log Analytics Workspace (log-analytics, PerGB2018 SKU, 30-day retention).



Diagnostic settings for VMSS (web-vmss-diagnostics, app-vmss-diagnostics), Application Gateway (app-gateway-diagnostics), and SQL instance (sql-diagnostics).



Metric alerts: CPU usage (>80% for VMSS), Application Gateway failed requests (>0), SQL storage (>90% of 256 GB).



Action group (alert-action-group) for notifications.



Outputs: Log Analytics Workspace ID.



Note: SQL diagnostics are optional; comment out if not needed.

GitLab CI/CD Pipeline





File: .gitlab-ci.yml



Image: hashicorp/terraform:latest



Stages: validate, plan, apply, destroy



Jobs:





terraform_validate: Runs terraform validate.



terraform_plan: Runs terraform plan, generates tfplan, and stores it as an artifact.



terraform_apply: Applies the plan (terraform apply --auto-approve tfplan) on the main branch (manual trigger).



terraform_destroy: Destroys infrastructure (terraform destroy) on the main branch (manual trigger).



Variables: Azure credentials (ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID, ARM_ACCESS_KEY) and Terraform variables (TF_VAR_*).
