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

locals {
  runbook_file_map = {
    for key, value in var.runbooks : key => "${var.runbookfolder}/${value.filename}"
  }
}

data "azurerm_resource_group" "rg" {
  name = var.resourcegroup
}

resource "azurerm_automation_account" "aa" {
  name                = var.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "Basic"
}

resource "azurerm_automation_module" "psmodule" {
  for_each = var.modules
  name                    = each.key
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name

  module_link {
    uri = each.value.link
  }
}

data "local_file" "runbook_file" {
  for_each = local.runbook_file_map
  filename = each.value
}

# output "runbook_file_list" {
#   value = local.runbook_file_list
# }

resource "azurerm_automation_runbook" "runbook" {
  for_each = var.runbooks
  name                    = each.key
  location                = data.azurerm_resource_group.rg.location
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  log_verbose             = each.value.log_verbose
  log_progress            = each.value.log_progress
  description             = each.value.description
  runbook_type            = each.value.runbook_type
  content = data.local_file.runbook_file[each.key].content
}

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