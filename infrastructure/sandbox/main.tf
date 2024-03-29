# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.8.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "JPAA01"
    storage_account_name = "tfstatejpsbx"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_version = ">= 1.2.2"
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}


locals {
  definitions_path      = "../../data/aa-definitions"
  definitions_file_list = fileset(local.definitions_path, "*.yaml")

  definitions_list = flatten([
    for file in local.definitions_file_list : [
      for name, data in yamldecode(file("${local.definitions_path}/${file}")) : {
        name                = name
        subscription        = data.subscription
        resourcegroup       = data.resourcegroup
        identity_type       = data.identity_type
        identity_ids        = data.identity_ids
        tags                = try(data.tags, {})
        modules             = try(data.modules, {})
        runbook_root_folder = data.runbook_root_folder
        runbooks            = try(data.runbooks, {})
        schedules           = try(data.schedules, {})
        job_schedules       = try(data.job_schedules, {})
      }
    ]
  ])
  definitions_map = { for definition in local.definitions_list : definition.name => definition }
}

module "automationaccount" {
  for_each = local.definitions_map
  source   = "../modules/automationaccount"
  #   providers = {
  #     azurerm = azurerm.SUB-JPSBX
  #   }
  name                = each.value.name
  subscription        = each.value.subscription
  resourcegroup       = each.value.resourcegroup
  identity_type       = each.value.identity_type
  identity_ids        = each.value.identity_ids
  tags                = each.value.tags
  modules             = each.value.modules
  runbook_root_folder = each.value.runbook_root_folder
  runbooks            = each.value.runbooks
  schedules           = each.value.schedules
  job_schedules       = each.value.job_schedules

}


