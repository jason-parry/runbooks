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
    for key, value in var.runbooks : key => "${var.runbook_root_folder}/${value.filename}"
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

resource "azurerm_automation_schedule" "schedule" {
  for_each = var.schedules
  name                    = each.key
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  frequency               = each.value.frequency
  interval                = each.value.interval
  timezone                = each.value.timezone
  start_time              = each.value.start_time
  description             = each.value.description
  week_days               = each.value.week_days
}

resource "azurerm_automation_job_schedule" "job_schedule" {
  for_each = var.job_schedules
  resource_group_name     = data.azurerm_resource_group.rg.name
  automation_account_name = azurerm_automation_account.aa.name
  schedule_name           = each.value.schedule_name
  runbook_name            = each.value.runbook_name

  parameters = each.value.parameters
}