terraform {
  required_providers {
    azurerm = {
      # /configuration_aliases = [  ]
      source  = "hashicorp/azurerm"
      version = "~> 3.8.0"
    }
  }
  # required_version = ">= 1.2.2"
}

data "azurerm_resource_group" "rg" {
  name     = var.resourcegroup
}

resource "azurerm_automation_account" "aa" {
  name                = var.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name = "Basic"
}

# data "local_file" "example" {
#   filename = "${path.module}/../../scripts/hello-world.ps1"
# }

# resource "azurerm_automation_runbook" "example" {
#   name                    = "Hello-World"
#   location                = data.azurerm_resource_group.example.location
#   resource_group_name     = data.azurerm_resource_group.example.name
#   automation_account_name = azurerm_automation_account.example.name
#   log_verbose             = "true"
#   log_progress            = "true"
#   description             = "This is an example runbook"
#   runbook_type            = "PowerShell"

#   content = data.local_file.example.content
# }

# resource "azurerm_automation_schedule" "example" {
#   name                    = "hw-automation-schedule"
#   resource_group_name     = data.azurerm_resource_group.example.name
#   automation_account_name = azurerm_automation_account.example.name
#   frequency               = "Week"
#   interval                = 1
#   timezone                = "Australia/Perth"
#   start_time              = "2022-11-12T02:00:00+08:00"
#   description             = "This is an example schedule"
#   week_days               = ["Friday"]
# }

# resource "azurerm_automation_job_schedule" "example" {
#   resource_group_name     = data.azurerm_resource_group.example.name
#   automation_account_name = azurerm_automation_account.example.name
#   schedule_name           = azurerm_automation_schedule.example.name
#   runbook_name            = azurerm_automation_runbook.example.name

#   parameters = {
#     resourcegroup = "tf-rgr-vm"
#     vmname        = "TF-VM-01"
#   }
# }

# resource "azurerm_automation_module" "example" {

#   name                    = "powershell-yaml"
#   resource_group_name     = data.azurerm_resource_group.example.name
#   automation_account_name = azurerm_automation_account.example.name

#   module_link {
#     uri = "https://www.powershellgallery.com/api/v2/package/powershell-yaml/0.4.3"
#   }
# }